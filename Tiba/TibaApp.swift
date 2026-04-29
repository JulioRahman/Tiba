//
//  TibaApp.swift
//  Tiba
//
//  Created by Julio Rahman on 29/04/26.
//

import SwiftUI

@main
struct TibaApp: App {
    @StateObject private var store: PrayerStore

    init() {
        let store = PrayerStore()
        _store = StateObject(wrappedValue: store)
        store.start()
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
                .frame(width: 340)
        } label: {
            MenuBarStatusLabel(state: store.state)
                .accessibilityLabel(store.accessibilityLabel)
        }
        .menuBarExtraStyle(.window)
    }
}
