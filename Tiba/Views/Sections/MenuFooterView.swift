import AppKit
import SwiftUI

struct MenuFooterView: View {
    let onDetect: () -> Void
    let onRefresh: () -> Void
    let language: AppLanguage

    var body: some View {
        HStack {
            Button {
                onDetect()
            } label: {
                Image(systemName: "location")
            }
            .help(TibaLocalization.string("settings.detect", language: language))

            Button {
                onRefresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help(TibaLocalization.string("settings.refresh", language: language))

            Spacer()

            OpenSettingsButton(language: language)

            Button {
                NSApp.terminate(nil)
            } label: {
                Label(
                    TibaLocalization.string("settings.quit", language: language),
                    systemImage: "power"
                )
            }
        }
        .controlSize(.small)
    }
}
