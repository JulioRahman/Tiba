import Foundation

enum TibaLocalization {
    nonisolated static func string(
        _ key: String,
        language: AppLanguage,
        _ arguments: CVarArg...
    ) -> String {
        let format = bundle(for: language).localizedString(forKey: key, value: nil, table: nil)
        guard !arguments.isEmpty else {
            return format
        }

        return String(format: format, locale: language.locale, arguments: arguments)
    }

    private nonisolated static func bundle(for language: AppLanguage) -> Bundle {
        guard let localizationCode = language.localizationCode,
            let path = Bundle.main.path(forResource: localizationCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }
}
