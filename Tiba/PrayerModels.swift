import Foundation

enum TibaDefaults {
    static let useManualLocation = "useManualLocation"
    static let manualLatitude = "manualLatitude"
    static let manualLongitude = "manualLongitude"
    static let calculationMethod = "calculationMethod"
    static let menuBarIconStyle = "menuBarIconStyle"
    static let customStatusLabel = "customStatusLabel"

    static let defaultManualLatitude = -6.2088
    static let defaultManualLongitude = 106.8456
    static let defaultCalculationMethod = -1
}

enum Prayer: String, CaseIterable, Codable, Identifiable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .fajr: "Fajr"
        case .dhuhr: "Dhuhr"
        case .asr: "Asr"
        case .maghrib: "Maghrib"
        case .isha: "Isha"
        }
    }

    nonisolated var initial: String {
        switch self {
        case .fajr: "F"
        case .dhuhr: "D"
        case .asr: "A"
        case .maghrib: "M"
        case .isha: "I"
        }
    }

    nonisolated var symbolName: String {
        switch self {
        case .fajr: "sunrise"
        case .dhuhr: "sun.max"
        case .asr: "sun.horizon"
        case .maghrib: "sunset"
        case .isha: "moon.stars"
        }
    }
}

enum MenuBarIconStyle: Int, CaseIterable, Identifiable {
    case textOnly
    case countdown
    case nextTime
    case pie
    case pieCountdown
    case pieInitial
    case bars
    case barsCountdown

    nonisolated var id: Int { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .textOnly: "Text Only"
        case .countdown: "Countdown"
        case .nextTime: "Next Time"
        case .pie: "Pie"
        case .pieCountdown: "Pie + Countdown"
        case .pieInitial: "Pie + Initial"
        case .bars: "Bars"
        case .barsCountdown: "Bars + Countdown"
        }
    }
}

struct CalculationMethodOption: Identifiable, Hashable {
    let storageValue: Int
    let displayName: String

    nonisolated var id: Int { storageValue }
    nonisolated var queryValue: Int? { storageValue >= 0 ? storageValue : nil }

    nonisolated static let all: [CalculationMethodOption] = [
        .init(storageValue: -1, displayName: "Automatic"),
        .init(storageValue: 2, displayName: "ISNA"),
        .init(storageValue: 3, displayName: "Muslim World League"),
        .init(storageValue: 4, displayName: "Umm Al-Qura"),
        .init(storageValue: 11, displayName: "Singapore"),
        .init(storageValue: 20, displayName: "Kemenag RI"),
    ]

    nonisolated static func queryValue(for storageValue: Int) -> Int? {
        all.first(where: { $0.storageValue == storageValue })?.queryValue
    }
}

struct PrayerCoordinate: Codable, Equatable {
    var latitude: Double
    var longitude: Double

    nonisolated var isValid: Bool {
        (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    nonisolated var cacheKey: String {
        let roundedLatitude = (latitude * 1_000).rounded() / 1_000
        let roundedLongitude = (longitude * 1_000).rounded() / 1_000
        return String(format: "%.3f_%.3f", roundedLatitude, roundedLongitude)
    }
}

struct PrayerEvent: Codable, Equatable, Identifiable {
    let prayer: Prayer
    let date: Date

    nonisolated var id: String {
        "\(prayer.rawValue)-\(date.timeIntervalSince1970)"
    }
}

struct PrayerSchedule: Codable, Equatable {
    let dateKey: String
    let coordinate: PrayerCoordinate
    let calculationMethod: Int?
    let timezone: String?
    let events: [PrayerEvent]
}

struct PrayerSnapshot: Equatable {
    let now: Date
    let events: [PrayerEvent]
    let nextEvent: PrayerEvent
    let previousEvent: PrayerEvent?

    nonisolated var remaining: TimeInterval {
        max(nextEvent.date.timeIntervalSince(now), 0)
    }

    nonisolated var minutesRemaining: Int {
        max(Int(ceil(remaining / 60)), 0)
    }

    nonisolated var countdownText: String {
        if minutesRemaining == 0 {
            return "Now"
        }

        let hours = minutesRemaining / 60
        let minutes = minutesRemaining % 60

        if hours == 0 {
            return "\(minutes)m"
        }

        if minutes == 0 {
            return "\(hours)h"
        }

        return "\(hours)h \(minutes)m"
    }

    nonisolated var compactCountdownText: String {
        if minutesRemaining == 0 {
            return "now"
        }

        if minutesRemaining >= 60 {
            return "\(minutesRemaining / 60)h"
        }

        return "\(minutesRemaining)m"
    }

    nonisolated var progress: Double {
        guard let previousDate = previousEvent?.date else {
            return 0
        }

        let total = nextEvent.date.timeIntervalSince(previousDate)
        guard total > 0 else {
            return 0
        }

        let elapsed = now.timeIntervalSince(previousDate)
        return min(max(elapsed / total, 0), 1)
    }
}

enum PrayerLoadState: Equatable {
    case idle
    case locating
    case loading
    case ready(PrayerSnapshot)
    case needsLocation(String)
    case failed(String)

    nonisolated var snapshot: PrayerSnapshot? {
        if case .ready(let snapshot) = self {
            return snapshot
        }

        return nil
    }
}

extension Date {
    nonisolated func prayerDayKey(calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    nonisolated func aladhanPathDate(calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return String(
            format: "%02d-%02d-%04d",
            components.day ?? 0,
            components.month ?? 0,
            components.year ?? 0
        )
    }

    nonisolated func addingDays(_ days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
}
