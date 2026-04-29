import SwiftUI

struct LocationSettingsSection: View {
    @Binding var useManualLocation: Bool
    @Binding var manualLatitude: Double
    @Binding var manualLongitude: Double
    @Binding var calculationMethod: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Manual Location", isOn: $useManualLocation)

            HStack(spacing: 8) {
                TextField(
                    "Latitude",
                    value: $manualLatitude,
                    format: .number.precision(.fractionLength(4))
                )
                .textFieldStyle(.roundedBorder)

                TextField(
                    "Longitude",
                    value: $manualLongitude,
                    format: .number.precision(.fractionLength(4))
                )
                .textFieldStyle(.roundedBorder)
            }
            .disabled(!useManualLocation)

            Picker("Calculation", selection: $calculationMethod) {
                ForEach(CalculationMethodOption.all) { method in
                    Text(method.displayName).tag(method.storageValue)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
