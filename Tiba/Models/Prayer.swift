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
