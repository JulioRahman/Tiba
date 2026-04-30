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
                Label(
                    TibaLocalization.string("settings.detect", language: language),
                    systemImage: "location"
                )
            }

            Button {
                onRefresh()
            } label: {
                Label(
                    TibaLocalization.string("settings.refresh", language: language),
                    systemImage: "arrow.clockwise"
                )
            }

            Spacer()

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
