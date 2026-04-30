import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PrayerStore

    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue

    var body: some View {
        let appLanguage = AppLanguage.value(for: appLanguageRaw)

        VStack(alignment: .leading, spacing: 14) {
            StatusSectionView(state: store.state, language: appLanguage)

            Divider()

            ScheduleSectionView(state: store.state, language: appLanguage)

            Divider()

            MenuFooterView(
                onDetect: {
                    store.requestLocation()
                },
                onRefresh: {
                    store.refresh()
                },
                language: appLanguage
            )
        }
        .padding(16)
        .environment(\.locale, appLanguage.locale)
        .onAppear {
            store.start()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PrayerStore.preview)
}
