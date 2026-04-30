import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PrayerStore
    private let settingsRefreshDebounce = 0.3

    @AppStorage(TibaDefaults.useManualLocation)
    private var useManualLocation = false
    @AppStorage(TibaDefaults.manualLatitude)
    private var manualLatitude = TibaDefaults.defaultManualLatitude
    @AppStorage(TibaDefaults.manualLongitude)
    private var manualLongitude = TibaDefaults.defaultManualLongitude
    @AppStorage(TibaDefaults.calculationMethod)
    private var calculationMethod = TibaDefaults.defaultCalculationMethod
    @AppStorage(TibaDefaults.asrSchool)
    private var asrSchool = TibaDefaults.defaultAsrSchool
    @AppStorage(TibaDefaults.menuBarIconStyle)
    private var iconStyleRaw = MenuBarIconStyle.arcCountdown.rawValue
    @AppStorage(TibaDefaults.customStatusLabel)
    private var customStatusLabel = "Tiba"
    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue

    var body: some View {
        let appLanguage = AppLanguage.value(for: appLanguageRaw)

        VStack(alignment: .leading, spacing: 14) {
            StatusSectionView(state: store.state, language: appLanguage)

            Divider()

            ScheduleSectionView(state: store.state, language: appLanguage)

            Divider()

            LanguageSectionView(appLanguageRaw: $appLanguageRaw)

            Divider()

            MenuBarStyleSection(
                iconStyleRaw: $iconStyleRaw,
                customStatusLabel: $customStatusLabel,
                language: appLanguage
            )

            Divider()

            LocationSettingsSection(
                useManualLocation: $useManualLocation,
                manualLatitude: $manualLatitude,
                manualLongitude: $manualLongitude,
                calculationMethod: $calculationMethod,
                asrSchool: $asrSchool,
                language: appLanguage
            )

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
        .onChange(of: useManualLocation) { _ in
            refreshFromSettings()
        }
        .onChange(of: manualLatitude) { _ in
            refreshFromSettings()
        }
        .onChange(of: manualLongitude) { _ in
            refreshFromSettings()
        }
        .onChange(of: calculationMethod) { _ in
            refreshFromSettings()
        }
        .onChange(of: asrSchool) { _ in
            refreshFromSettings()
        }
    }

    private func refreshFromSettings() {
        store.refresh(force: true, debounce: settingsRefreshDebounce)
    }
}

#Preview {
    ContentView()
        .environmentObject(PrayerStore.preview)
}
