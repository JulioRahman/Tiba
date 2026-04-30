import SwiftUI

struct SettingsView: View {
    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue

    var body: some View {
        let language = AppLanguage.value(for: appLanguageRaw)

        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label(
                        TibaLocalization.string("settings.tab.general", language: language),
                        systemImage: "gearshape"
                    )
                }

            AppearanceSettingsTab()
                .tabItem {
                    Label(
                        TibaLocalization.string("settings.tab.appearance", language: language),
                        systemImage: "menubar.rectangle"
                    )
                }

            LocationSettingsTab()
                .tabItem {
                    Label(
                        TibaLocalization.string("settings.tab.location", language: language),
                        systemImage: "location"
                    )
                }
        }
        .frame(width: 480, height: 360)
        .environment(\.locale, language.locale)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PrayerStore.preview)
}
