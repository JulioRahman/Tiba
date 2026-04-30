enum Prayer: String, CaseIterable, Codable, Identifiable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        displayName(language: .system)
    }

    nonisolated func displayName(language: AppLanguage) -> String {
        switch self {
        case .fajr:
            TibaLocalization.string("prayer.fajr", language: language)
        case .dhuhr:
            TibaLocalization.string("prayer.dhuhr", language: language)
        case .asr:
            TibaLocalization.string("prayer.asr", language: language)
        case .maghrib:
            TibaLocalization.string("prayer.maghrib", language: language)
        case .isha:
            TibaLocalization.string("prayer.isha", language: language)
        }
    }

    nonisolated var initial: String {
        initial(language: .system)
    }

    nonisolated func initial(language: AppLanguage) -> String {
        switch self {
        case .fajr:
            TibaLocalization.string("prayer.fajr.initial", language: language)
        case .dhuhr:
            TibaLocalization.string("prayer.dhuhr.initial", language: language)
        case .asr:
            TibaLocalization.string("prayer.asr.initial", language: language)
        case .maghrib:
            TibaLocalization.string("prayer.maghrib.initial", language: language)
        case .isha:
            TibaLocalization.string("prayer.isha.initial", language: language)
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
