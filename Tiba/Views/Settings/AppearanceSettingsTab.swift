import SwiftUI

struct AppearanceSettingsTab: View {
    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue
    @AppStorage(TibaDefaults.menuBarIconStyle)
    private var iconStyleRaw = MenuBarIconStyle.arcCountdown.rawValue
    @AppStorage(TibaDefaults.customStatusLabel)
    private var customStatusLabel = ""

    var body: some View {
        let language = AppLanguage.value(for: appLanguageRaw)

        Form {
            MenuBarStyleSection(
                iconStyleRaw: $iconStyleRaw,
                customStatusLabel: $customStatusLabel,
                language: language
            )
        }
        .formStyle(.grouped)
    }
}
