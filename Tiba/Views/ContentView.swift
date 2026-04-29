import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PrayerStore

    @AppStorage(TibaDefaults.useManualLocation)
    private var useManualLocation = false
    @AppStorage(TibaDefaults.manualLatitude)
    private var manualLatitude = TibaDefaults.defaultManualLatitude
    @AppStorage(TibaDefaults.manualLongitude)
    private var manualLongitude = TibaDefaults.defaultManualLongitude
    @AppStorage(TibaDefaults.calculationMethod)
    private var calculationMethod = TibaDefaults.defaultCalculationMethod
    @AppStorage(TibaDefaults.menuBarIconStyle)
    private var iconStyleRaw = MenuBarIconStyle.pieCountdown.rawValue
    @AppStorage(TibaDefaults.customStatusLabel)
    private var customStatusLabel = "Tiba"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            StatusSectionView(state: store.state)

            Divider()

            ScheduleSectionView(state: store.state)

            Divider()

            MenuBarStyleSection(
                iconStyleRaw: $iconStyleRaw,
                customStatusLabel: $customStatusLabel
            )

            Divider()

            LocationSettingsSection(
                useManualLocation: $useManualLocation,
                manualLatitude: $manualLatitude,
                manualLongitude: $manualLongitude,
                calculationMethod: $calculationMethod
            )

            Divider()

            MenuFooterView(
                onDetect: {
                    store.requestLocation()
                },
                onRefresh: {
                    Task {
                        await store.refresh()
                    }
                }
            )
        }
        .padding(16)
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
    }

    private func refreshFromSettings() {
        Task {
            await store.refresh(force: true)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PrayerStore.preview)
}
