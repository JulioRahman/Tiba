import SwiftUI

struct LocationSettingsTab: View {
    @EnvironmentObject private var store: PrayerStore
    private let settingsRefreshDebounce = 0.3

    @AppStorage(TibaDefaults.appLanguage)
    private var appLanguageRaw = AppLanguage.system.rawValue
    @AppStorage(TibaDefaults.useManualLocation)
    private var useManualLocation = false
    @AppStorage(TibaDefaults.manualLatitude)
    private var manualLatitude = TibaDefaults.defaultManualLatitude
    @AppStorage(TibaDefaults.manualLongitude)
    private var manualLongitude = TibaDefaults.defaultManualLongitude
    @AppStorage(TibaDefaults.calculationMethod)
    private var calculationMethod = TibaDefaults.defaultCalculationMethod
    @AppStorage(TibaDefaults.latitudeAdjustmentMethod)
    private var latitudeAdjustmentMethod = TibaDefaults.defaultLatitudeAdjustmentMethod
    @AppStorage(TibaDefaults.asrSchool)
    private var asrSchool = TibaDefaults.defaultAsrSchool

    var body: some View {
        let language = AppLanguage.value(for: appLanguageRaw)

        Form {
            LocationSettingsSection(
                useManualLocation: $useManualLocation,
                manualLatitude: $manualLatitude,
                manualLongitude: $manualLongitude,
                calculationMethod: $calculationMethod,
                latitudeAdjustmentMethod: $latitudeAdjustmentMethod,
                asrSchool: $asrSchool,
                language: language
            )

            Button {
                store.requestLocation()
            } label: {
                Label(
                    TibaLocalization.string("settings.detect", language: language),
                    systemImage: "location"
                )
            }
        }
        .formStyle(.grouped)
        .onChange(of: useManualLocation) { _ in refresh() }
        .onChange(of: manualLatitude) { _ in refresh() }
        .onChange(of: manualLongitude) { _ in refresh() }
        .onChange(of: calculationMethod) { _ in refresh() }
        .onChange(of: latitudeAdjustmentMethod) { _ in refresh() }
        .onChange(of: asrSchool) { _ in refresh() }
    }

    private func refresh() {
        store.refresh(force: true, debounce: settingsRefreshDebounce)
    }
}
