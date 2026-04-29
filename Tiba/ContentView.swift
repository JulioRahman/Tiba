//
//  ContentView.swift
//  Tiba
//
//  Created by Julio Rahman on 29/04/26.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PrayerStore

    @AppStorage(TibaDefaults.useManualLocation)
    private var useManualLocation = false
    @AppStorage(TibaDefaults.manualLatitude)
    private var manualLatitude = TibaDefaults.defaultManualLatitude
    @AppStorage(TibaDefaults.manualLongitude)
    private var manualLongitude = TibaDefaults.defaultManualLongitude
    @AppStorage(TibaDefaults.calculationMethod)
    private var calculationMethod = TibaDefaults.defaultCalculationMethod
    @AppStorage(TibaDefaults.menuBarIconStyle)
    private var iconStyleRaw = MenuBarIconStyle.pieCountdown.rawValue
    @AppStorage(TibaDefaults.customStatusLabel)
    private var customStatusLabel = "Tiba"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            statusSection

            Divider()

            scheduleSection

            Divider()

            iconSection

            Divider()

            locationSection

            Divider()

            footer
        }
        .padding(16)
        .onAppear {
            store.start()
        }
        .onChange(of: useManualLocation) { _ in
            refreshFromSettings()
        }
        .onChange(of: manualLatitude) { _ in
            refreshFromSettings()
        }
        .onChange(of: manualLongitude) { _ in
            refreshFromSettings()
        }
        .onChange(of: calculationMethod) { _ in
            refreshFromSettings()
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        switch store.state {
        case .ready(let snapshot):
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(snapshot.nextEvent.prayer.displayName)
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Text(snapshot.countdownText)
                        .font(.title3.monospacedDigit().weight(.medium))
                }

                Text(snapshot.nextEvent.date, format: .dateTime.weekday(.wide).hour().minute())
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

        case .locating:
            Label("Detecting location", systemImage: "location")
                .font(.headline)

        case .loading, .idle:
            Label("Loading prayer times", systemImage: "clock")
                .font(.headline)

        case .needsLocation(let message):
            Label(message, systemImage: "location.slash")
                .font(.headline)
                .foregroundStyle(.secondary)

        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var scheduleSection: some View {
        if case .ready(let snapshot) = store.state {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(snapshot.events) { event in
                    HStack {
                        Label(event.prayer.displayName, systemImage: event.prayer.symbolName)
                            .foregroundStyle(
                                event.prayer == snapshot.nextEvent.prayer ? .primary : .secondary
                            )
                        Spacer()
                        Text(event.date, format: .dateTime.hour().minute())
                            .monospacedDigit()
                            .foregroundStyle(
                                event.prayer == snapshot.nextEvent.prayer ? .primary : .secondary
                            )
                    }
                    .font(
                        event.prayer == snapshot.nextEvent.prayer ? .body.weight(.semibold) : .body
                    )
                }
            }
        }
    }

    private var iconSection: some View {
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

    private var locationSection: some View {
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

    private var footer: some View {
        HStack {
            Button {
                store.requestLocation()
            } label: {
                Label("Detect", systemImage: "location")
            }

            Button {
                Task {
                    await store.refresh()
                }
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

    private func refreshFromSettings() {
        Task {
            await store.refresh(force: true)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PrayerStore.preview)
}
