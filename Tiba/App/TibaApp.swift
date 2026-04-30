import SwiftUI

@main
struct TibaApp: App {
    @StateObject private var store: PrayerStore
    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue

    init() {
        let store = PrayerStore()
        _store = StateObject(wrappedValue: store)
        store.start()
    }

    var body: some Scene {
        let appLanguage = AppLanguage.value(for: appLanguageRaw)

        MenuBarExtra {
            ContentView()
                .environmentObject(store)
                .environment(\.locale, appLanguage.locale)
                .frame(width: 340)
        } label: {
            MenuBarStatusLabel(state: store.state, language: appLanguage)
                .environment(\.locale, appLanguage.locale)
                .accessibilityLabel(store.accessibilityLabel(language: appLanguage))
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
