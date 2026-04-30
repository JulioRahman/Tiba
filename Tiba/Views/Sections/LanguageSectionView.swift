import SwiftUI

struct LanguageSectionView: View {
    @Binding var appLanguageRaw: String

    var body: some View {
        let language = AppLanguage.value(for: appLanguageRaw)

        Picker(
            TibaLocalization.string("settings.language", language: language),
            selection: $appLanguageRaw
        ) {
            ForEach(AppLanguage.allCases) { option in
                Text(option.displayName(language: language)).tag(option.rawValue)
            }
        }
        .pickerStyle(.menu)
    }
}
