import SwiftUI

struct MenuBarStyleSection: View {
    @Binding var iconStyleRaw: Int
    @Binding var customStatusLabel: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker(
                TibaLocalization.string("settings.menuBar", language: language),
                selection: $iconStyleRaw
            ) {
                ForEach(MenuBarIconStyle.allCases) { style in
                    Text(style.displayName(language: language)).tag(style.rawValue)
                }
            }
            .pickerStyle(.menu)

            TextField(
                TibaLocalization.string("settings.label", language: language),
                text: $customStatusLabel
            )
            .textFieldStyle(.roundedBorder)
            .disabled(MenuBarIconStyle(rawValue: iconStyleRaw) != .textOnly)
        }
    }
}
