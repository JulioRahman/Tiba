import AppKit
import SwiftUI

struct OpenSettingsButton: View {
    let language: AppLanguage

    var body: some View {
        Group {
            if #available(macOS 14.0, *) {
                SettingsLink {
                    icon
                }
                .buttonStyle(.borderless)
            } else {
                Button {
                    NSApp.activate(ignoringOtherApps: true)
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    icon
                }
                .buttonStyle(.borderless)
            }
        }
        .help(TibaLocalization.string("settings.openSettings", language: language))
    }

    private var icon: some View {
        Image(systemName: "gearshape")
    }
}
