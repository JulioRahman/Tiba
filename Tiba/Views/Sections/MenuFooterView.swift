import AppKit
import SwiftUI

struct MenuFooterView: View {
    let onDetect: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack {
            Button {
                onDetect()
            } label: {
                Label("Detect", systemImage: "location")
            }

            Button {
                onRefresh()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            Spacer()

            Button {
                NSApp.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
        }
        .controlSize(.small)
    }
}
