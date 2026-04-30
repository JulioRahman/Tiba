import AppKit
import Combine
import CoreLocation
import Foundation

@MainActor
final class PrayerStore: ObservableObject {
    @Published private(set) var state: PrayerLoadState = .idle

    let locationProvider: LocationProvider

    private let client: AladhanClient
    private let cache: PrayerScheduleCache
    private var cancellables: Set<AnyCancellable> = []
    private var todaysSchedule: PrayerSchedule?
    private var tomorrowSchedule: PrayerSchedule?
    private var timer: Timer?
    private var didStart = false
    private var isLoadingTomorrow = false
    private var refreshTask: Task<Void, Never>?

    init(
        locationProvider: LocationProvider = LocationProvider(),
        client: AladhanClient = AladhanClient(),
        cache: PrayerScheduleCache = PrayerScheduleCache()
    ) {
        self.locationProvider = locationProvider
        self.client = client
        self.cache = cache

        locationProvider.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)

        locationProvider.$coordinate
            .compactMap(\.self)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
            .store(in: &cancellables)

        locationProvider.$authorizationStatus
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateLocationStateIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    var accessibilityLabel: String {
        switch state {
        case .ready(let snapshot):
            "Tiba, \(snapshot.nextEvent.prayer.displayName) in \(snapshot.countdownText)"
        case .locating:
            "Tiba, detecting location"
        case .loading:
            "Tiba, loading prayer times"
        case .needsLocation(let message):
            "Tiba, \(message)"
        case .failed(let message):
            "Tiba, \(message)"
        case .idle:
            "Tiba"
        }
    }

    func start() {
        guard !didStart else {
            return
        }

        didStart = true
        locationProvider.requestCurrentLocation()

        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.tick()
            }
        }

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.tick()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: Notification.Name.NSSystemTimeZoneDidChange)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.tick()
                }
            }
            .store(in: &cancellables)

        refresh()
    }

    func requestLocation() {
        UserDefaults.standard.set(false, forKey: TibaDefaults.useManualLocation)
        locationProvider.requestCurrentLocation()
    }

    func refresh(force: Bool = false, debounce: TimeInterval = 0) {
        refreshTask?.cancel()

        let delay = max(0, debounce)
        refreshTask = Task { [weak self] in
            if delay > 0 {
                do {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else {
                return
            }

            await self?.performRefresh(force: force)
        }
    }

    private func performRefresh(force: Bool = false) async {
        guard let coordinate = selectedCoordinate else {
            updateLocationStateIfNeeded()
            return
        }

        guard coordinate.isValid else {
            state = .needsLocation("Invalid location")
            return
        }

        if state.snapshot == nil {
            state = .loading
        }

        let method = selectedCalculationMethod()

        do {
            let loadedToday = try await loadSchedule(
                for: Date(),
                coordinate: coordinate,
                calculationMethod: method,
                force: force
            )
            try Task.checkCancellation()

            let loadedTomorrow = try? await loadCachedSchedule(
                for: Date().addingDays(1),
                coordinate: coordinate,
                calculationMethod: method
            )
            try Task.checkCancellation()

            todaysSchedule = loadedToday
            tomorrowSchedule = loadedTomorrow
            await recompute(now: Date())
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else {
                return
            }
            state = .failed(error.localizedDescription)
        }
    }

    private func tick() async {
        let now = Date()

        if todaysSchedule?.dateKey != now.prayerDayKey() {
            refresh()
            return
        }

        await recompute(now: now)
    }

    private func recompute(now: Date) async {
        guard let todaysSchedule else {
            updateLocationStateIfNeeded()
            return
        }

        var allEvents = todaysSchedule.events
        if let tomorrowSchedule {
            allEvents.append(contentsOf: tomorrowSchedule.events)
        }

        allEvents.sort { $0.date < $1.date }

        guard let nextEvent = allEvents.first(where: { $0.date > now }) else {
            await loadTomorrowIfNeeded()
            return
        }

        let visibleEvents = todaysSchedule.events.sorted { $0.date < $1.date }
        let previousEvent = allEvents.last(where: { $0.date <= now })
        state = .ready(
            PrayerSnapshot(
                now: now,
                events: visibleEvents,
                nextEvent: nextEvent,
                previousEvent: previousEvent
            )
        )

        if nextEvent.date == tomorrowSchedule?.events.first?.date {
            await loadTomorrowIfNeeded()
        }
    }

    private func loadTomorrowIfNeeded() async {
        guard !Task.isCancelled else {
            return
        }

        guard !isLoadingTomorrow else {
            return
        }

        guard let coordinate = selectedCoordinate, coordinate.isValid else {
            updateLocationStateIfNeeded()
            return
        }

        if tomorrowSchedule != nil {
            return
        }

        isLoadingTomorrow = true
        defer { isLoadingTomorrow = false }

        do {
            let schedule = try await loadSchedule(
                for: Date().addingDays(1),
                coordinate: coordinate,
                calculationMethod: selectedCalculationMethod(),
                force: false
            )
            try Task.checkCancellation()

            tomorrowSchedule = schedule
            await recompute(now: Date())
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else {
                return
            }
            state = .failed(error.localizedDescription)
        }
    }

    private func loadSchedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationMethod: Int?,
        force: Bool
    ) async throws -> PrayerSchedule {
        if !force,
            let cached = try? await loadCachedSchedule(
                for: date,
                coordinate: coordinate,
                calculationMethod: calculationMethod
            )
        {
            try Task.checkCancellation()
            return cached
        }

        let schedule = try await client.fetchSchedule(
            for: date,
            coordinate: coordinate,
            calculationMethod: calculationMethod
        )
        try Task.checkCancellation()

        try cache.save(schedule)
        return schedule
    }

    private func loadCachedSchedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationMethod: Int?
    ) async throws -> PrayerSchedule? {
        try cache.schedule(
            for: date,
            coordinate: coordinate,
            calculationMethod: calculationMethod
        )
    }

    private func selectedCalculationMethod() -> Int? {
        let rawValue =
            UserDefaults.standard.object(forKey: TibaDefaults.calculationMethod) as? Int
            ?? TibaDefaults.defaultCalculationMethod
        return CalculationMethodOption.queryValue(for: rawValue)
    }

    private var selectedCoordinate: PrayerCoordinate? {
        if UserDefaults.standard.bool(forKey: TibaDefaults.useManualLocation) {
            return PrayerCoordinate(
                latitude: UserDefaults.standard.object(forKey: TibaDefaults.manualLatitude)
                    as? Double
                    ?? TibaDefaults.defaultManualLatitude,
                longitude: UserDefaults.standard.object(forKey: TibaDefaults.manualLongitude)
                    as? Double
                    ?? TibaDefaults.defaultManualLongitude
            )
        }

        return locationProvider.coordinate
    }

    private func updateLocationStateIfNeeded() {
        guard selectedCoordinate == nil else {
            return
        }

        if UserDefaults.standard.bool(forKey: TibaDefaults.useManualLocation) {
            state = .needsLocation("Invalid manual location")
            return
        }

        switch locationProvider.authorizationStatus {
        case .notDetermined:
            state = .locating
        case .authorized, .authorizedAlways:
            state = .locating
        case .denied, .restricted:
            state = .needsLocation("Allow location or enter coordinates")
        @unknown default:
            state = .needsLocation("Location unavailable")
        }
    }
}

extension PrayerStore {
    static var preview: PrayerStore {
        let store = PrayerStore()
        let now = Date()
        let calendar = Calendar.current
        let events = zip(Prayer.allCases, [0, 180, 330, 470, 610]).compactMap { prayer, offset in
            calendar.date(byAdding: .minute, value: offset, to: now).map {
                PrayerEvent(prayer: prayer, date: $0)
            }
        }

        store.state = .ready(
            PrayerSnapshot(
                now: now,
                events: events,
                nextEvent: events[1],
                previousEvent: events[0]
            )
        )
        return store
    }
}
