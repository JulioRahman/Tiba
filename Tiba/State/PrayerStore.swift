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

        locationProvider.$errorMessage
            .compactMap(\.self)
            .sink { [weak self] message in
                Task { @MainActor in
                    self?.state = .needsLocation(message)
                }
            }
            .store(in: &cancellables)
    }

    func accessibilityLabel(language: AppLanguage) -> String {
        switch state {
        case .ready(let snapshot):
            TibaLocalization.string(
                "accessibility.ready",
                language: language,
                snapshot.nextEvent.prayer.displayName(language: language),
                snapshot.countdownText(language: language)
            )
        case .locating:
            TibaLocalization.string("accessibility.locating", language: language)
        case .loading:
            TibaLocalization.string("accessibility.loading", language: language)
        case .needsLocation(let message):
            TibaLocalization.string(
                "accessibility.message",
                language: language,
                message.localized(language: language)
            )
        case .failed(let message):
            TibaLocalization.string(
                "accessibility.message",
                language: language,
                message.localized(language: language)
            )
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

    func timelineVisibilityChanged() {
        Task {
            await recompute(now: Date())
        }
    }

    private func performRefresh(force: Bool = false) async {
        guard let coordinate = selectedCoordinate else {
            updateLocationStateIfNeeded()
            return
        }

        guard coordinate.isValid else {
            state = .needsLocation(.invalidLocation)
            return
        }

        if state.snapshot == nil {
            state = .loading
        }

        let calculationSettings = selectedCalculationSettings()

        do {
            let loadedToday = try await loadSchedule(
                for: Date(),
                coordinate: coordinate,
                calculationSettings: calculationSettings,
                force: force
            )
            try Task.checkCancellation()

            let loadedTomorrow = try? await loadCachedSchedule(
                for: Date().addingDays(1),
                coordinate: coordinate,
                calculationSettings: calculationSettings
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
            state = .failed(message(for: error))
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

        var allEvents = activeEvents(from: todaysSchedule)
        let activeTomorrowEvents = tomorrowSchedule.map { activeEvents(from: $0) }
        if let tomorrowSchedule {
            allEvents.append(contentsOf: activeEvents(from: tomorrowSchedule))
        }

        allEvents.sort { $0.date < $1.date }

        guard let nextEvent = allEvents.first(where: { $0.date > now }) else {
            await loadTomorrowIfNeeded()
            return
        }

        let visibleEvents = activeEvents(from: todaysSchedule)
        let previousEvent = allEvents.last(where: { $0.date <= now })
        state = .ready(
            PrayerSnapshot(
                now: now,
                events: visibleEvents,
                nextEvent: nextEvent,
                previousEvent: previousEvent
            )
        )

        if nextEvent.date == activeTomorrowEvents?.first?.date {
            await loadTomorrowIfNeeded()
        }
    }

    private func activeEvents(from schedule: PrayerSchedule) -> [PrayerEvent] {
        schedule.events
            .filter { event in
                switch event.prayer {
                case .imsak:
                    UserDefaults.standard.bool(forKey: TibaDefaults.showImsak)
                default:
                    true
                }
            }
            .sorted { $0.date < $1.date }
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
                calculationSettings: selectedCalculationSettings(),
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
            state = .failed(message(for: error))
        }
    }

    private func loadSchedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings,
        force: Bool
    ) async throws -> PrayerSchedule {
        if !force,
            let cached = try? await loadCachedSchedule(
                for: date,
                coordinate: coordinate,
                calculationSettings: calculationSettings
            )
        {
            try Task.checkCancellation()
            return cached
        }

        let schedule = try await client.fetchSchedule(
            for: date,
            coordinate: coordinate,
            calculationSettings: calculationSettings
        )
        try Task.checkCancellation()

        try cache.save(schedule)
        return schedule
    }

    private func loadCachedSchedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings
    ) async throws -> PrayerSchedule? {
        try cache.schedule(
            for: date,
            coordinate: coordinate,
            calculationSettings: calculationSettings
        )
    }

    private func selectedCalculationSettings() -> PrayerCalculationSettings {
        let methodRawValue =
            UserDefaults.standard.object(forKey: TibaDefaults.calculationMethod) as? Int
            ?? TibaDefaults.defaultCalculationMethod
        let asrSchoolRawValue =
            UserDefaults.standard.object(forKey: TibaDefaults.asrSchool) as? Int
            ?? TibaDefaults.defaultAsrSchool
        let asrSchool = AsrSchoolOption.queryValue(for: asrSchoolRawValue)
        return CalculationMethodOption.calculationSettings(
            for: methodRawValue,
            asrSchool: asrSchool
        )
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
            state = .needsLocation(.invalidManualLocation)
            return
        }

        if let errorMessage = locationProvider.errorMessage {
            state = .needsLocation(errorMessage)
            return
        }

        switch locationProvider.authorizationStatus {
        case .notDetermined:
            state = .locating
        case .authorized, .authorizedAlways:
            state = .locating
        case .denied, .restricted:
            state = .needsLocation(.allowLocationOrEnterCoordinates)
        @unknown default:
            state = .needsLocation(.locationUnavailable)
        }
    }

    private func message(for error: Error) -> AppMessage {
        if let error = error as? AladhanClientError {
            return error.message
        }

        return .raw(error.localizedDescription)
    }
}

extension PrayerStore {
    static var preview: PrayerStore {
        let store = PrayerStore()
        let now = Date()
        let calendar = Calendar.current
        let events =
            zip(Prayer.allCases, [0, 45, 80, 360, 540, 720, 840]).compactMap { prayer, offset in
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
