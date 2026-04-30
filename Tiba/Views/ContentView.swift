import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PrayerStore

    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue

    var body: some View {
        let appLanguage = AppLanguage.value(for: appLanguageRaw)

        VStack(alignment: .leading, spacing: 10) {
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
        .frame(width: 200, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
