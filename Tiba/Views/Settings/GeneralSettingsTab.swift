import SwiftUI

struct GeneralSettingsTab: View {
    @EnvironmentObject private var store: PrayerStore

    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue
    @AppStorage(TibaDefaults.showImsak)
    private var showImsak = false

    var body: some View {
        let language = AppLanguage.value(for: appLanguageRaw)

        Form {
            LanguageSectionView(appLanguageRaw: $appLanguageRaw)

            Toggle(
                TibaLocalization.string("settings.showImsak", language: language),
                isOn: $showImsak
            )
        }
        .formStyle(.grouped)
        .onChange(of: showImsak) { _ in
            store.timelineVisibilityChanged()
        }
    }
}
