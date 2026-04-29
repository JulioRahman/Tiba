import SwiftUI

struct MenuBarStyleSection: View {
    @Binding var iconStyleRaw: Int
    @Binding var customStatusLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Menu Bar", selection: $iconStyleRaw) {
                ForEach(MenuBarIconStyle.allCases) { style in
                    Text(style.displayName).tag(style.rawValue)
                }
            }
            .pickerStyle(.menu)

            TextField("Label", text: $customStatusLabel)
                .textFieldStyle(.roundedBorder)
                .disabled(MenuBarIconStyle(rawValue: iconStyleRaw) != .textOnly)
        }
    }
}
