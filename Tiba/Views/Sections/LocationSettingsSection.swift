import SwiftUI

struct LocationSettingsSection: View {
    @Binding var useManualLocation: Bool
    @Binding var manualLatitude: Double
    @Binding var manualLongitude: Double
    @Binding var calculationMethod: Int
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(
                TibaLocalization.string("settings.manualLocation", language: language),
                isOn: $useManualLocation
            )

            HStack(spacing: 8) {
                TextField(
                    TibaLocalization.string("settings.latitude", language: language),
                    value: $manualLatitude,
                    format: .number.precision(.fractionLength(4))
                )
                .textFieldStyle(.roundedBorder)

                TextField(
                    TibaLocalization.string("settings.longitude", language: language),
                    value: $manualLongitude,
                    format: .number.precision(.fractionLength(4))
                )
                .textFieldStyle(.roundedBorder)
            }
            .disabled(!useManualLocation)

            Picker(
                TibaLocalization.string("settings.calculation", language: language),
                selection: $calculationMethod
            ) {
                ForEach(CalculationMethodOption.all) { method in
                    Text(method.displayName(language: language)).tag(method.storageValue)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
