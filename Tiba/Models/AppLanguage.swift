import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case indonesian = "id"

    var id: String { rawValue }

    nonisolated var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .english:
            Locale(identifier: "en")
        case .indonesian:
            Locale(identifier: "id")
        }
    }

    nonisolated var localizationCode: String? {
        switch self {
        case .system:
            nil
        case .english:
            "en"
        case .indonesian:
            "id"
        }
    }

    func displayName(language: AppLanguage) -> String {
        switch self {
        case .system:
            TibaLocalization.string("language.system", language: language)
        case .english:
            TibaLocalization.string("language.english", language: language)
        case .indonesian:
            TibaLocalization.string("language.indonesian", language: language)
        }
    }

    static func value(for rawValue: String) -> AppLanguage {
        AppLanguage(rawValue: rawValue) ?? .system
    }
}
