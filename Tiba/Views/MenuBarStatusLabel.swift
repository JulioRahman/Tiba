import Foundation
import SwiftUI

struct MenuBarStatusLabel: View {
    let state: PrayerLoadState
    let language: AppLanguage

    @AppStorage(TibaDefaults.menuBarIconStyle)
    private var iconStyleRaw = MenuBarIconStyle.arcCountdown.rawValue
    @AppStorage(TibaDefaults.customStatusLabel)
    private var customStatusLabel = ""

    var body: some View {
        switch state {
        case .ready(let snapshot):
            readyLabel(snapshot)
        case .locating:
            compactStatusLabel(systemImage: "location", text: "…")
        case .loading, .idle:
            HStack(spacing: 4) {
                ProgressView()
                    .controlSize(.mini)
                    .scaleEffect(0.62)
                    .frame(width: 10, height: 10)
                Text("…")
                    .font(statusFont)
            }
        case .needsLocation:
            compactStatusLabel(
                systemImage: "location.slash",
                text: TibaLocalization.string("status.setLocation", language: language)
            )
        case .failed:
            compactStatusLabel(
                systemImage: "exclamationmark.triangle",
                text: TibaLocalization.string("status.error", language: language)
            )
        }
    }

    @ViewBuilder
    private func readyLabel(_ snapshot: PrayerSnapshot) -> some View {
        let style = MenuBarIconStyle(rawValue: iconStyleRaw) ?? .arcCountdown

        switch style {
        case .textOnly:
            textOnlyLabel(snapshot)

        case .countdown:
            Text(snapshot.compactCountdownText(language: language))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()

        case .nextTime:
            Text(snapshot.nextEvent.date, format: .dateTime.hour().minute())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()

        case .arc:
            ProgressArc(progress: snapshot.progress)
                .frame(width: 17, height: 17)

        case .arcCountdown:
            HStack(spacing: 4) {
                ProgressArc(progress: snapshot.progress)
                    .frame(width: 15, height: 15)
                Text(snapshot.compactCountdownText(language: language))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

        case .arcInitial:
            ZStack {
                ProgressArc(progress: snapshot.progress)
                    .frame(width: 18, height: 18)
                Text(snapshot.nextEvent.prayer.initial(language: language))
                    .font(.system(size: 8, weight: .bold, design: .rounded))
            }

        case .bars:
            PrayerBarsView(
                activePrayer: snapshot.nextEvent.prayer,
                prayers: snapshot.events.map(\.prayer)
            )
            .frame(width: 26, height: 17)

        case .barsCountdown:
            HStack(spacing: 4) {
                PrayerBarsView(
                    activePrayer: snapshot.nextEvent.prayer,
                    prayers: snapshot.events.map(\.prayer)
                )
                .frame(width: 26, height: 17)
                Text(snapshot.compactCountdownText(language: language))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
        }
    }

    @ViewBuilder
    private func textOnlyLabel(_ snapshot: PrayerSnapshot) -> some View {
        let trimmedLabel = customStatusLabel.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedLabel.isEmpty {
            HStack(spacing: 3) {
                Text(snapshot.nextEvent.prayer.displayName(language: language))
                Text(snapshot.nextEvent.date, format: .dateTime.hour().minute())
                    .monospacedDigit()
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
        } else {
            Text(trimmedLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
    }

    private func compactStatusLabel(systemImage: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .imageScale(.small)
            Text(text)
                .font(statusFont)
        }
    }

    private var statusFont: Font {
        .system(size: 12, weight: .semibold, design: .rounded)
    }
}

private struct ProgressArc: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.28), lineWidth: 2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.primary, style: StrokeStyle(lineWidth: 2.3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

private struct PrayerBarsView: View {
    let activePrayer: Prayer
    let prayers: [Prayer]

    var body: some View {
        HStack(alignment: .bottom, spacing: 1.5) {
            ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                let isActive = prayer == activePrayer
                RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                    .fill(isActive ? Color.primary : Color.secondary.opacity(0.42))
                    .frame(
                        width: isActive ? 3.5 : 2,
                        height: isActive ? 15 : inactiveHeight(for: index)
                    )
            }
        }
    }

    private func inactiveHeight(for index: Int) -> CGFloat {
        guard prayers.count > 1 else {
            return 10
        }

        let progress = CGFloat(index) / CGFloat(prayers.count - 1)
        return 6 + (progress * 8)
    }
}

// MARK: - Previews

private func previewSnapshot() -> PrayerSnapshot {
    let now = Date()
    let calendar = Calendar.current
    let offsets = [-15, 45, 80, 360, 540, 720, 840]
    let events = zip(Prayer.allCases, offsets).compactMap { prayer, offset in
        calendar.date(byAdding: .minute, value: offset, to: now)
            .map { PrayerEvent(prayer: prayer, date: $0) }
    }
    return PrayerSnapshot(
        now: now,
        events: events,
        nextEvent: events[1],
        previousEvent: events[0]
    )
}

private func previewDefaults(style: MenuBarIconStyle, customLabel: String = "") -> UserDefaults {
    let suite = "MenuBarStatusLabel.Preview.\(style.rawValue).\(customLabel.hashValue)"
    let defaults = UserDefaults(suiteName: suite) ?? .standard
    defaults.set(style.rawValue, forKey: TibaDefaults.menuBarIconStyle)
    defaults.set(customLabel, forKey: TibaDefaults.customStatusLabel)
    return defaults
}

private struct PreviewRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .leading)
            content()
            Spacer()
        }
    }
}

#Preview("Ready states") {
    let snapshot = previewSnapshot()
    return VStack(alignment: .leading, spacing: 10) {
        ForEach(MenuBarIconStyle.allCases, id: \.rawValue) { style in
            PreviewRow(title: String(describing: style)) {
                MenuBarStatusLabel(state: .ready(snapshot), language: .english)
                    .defaultAppStorage(previewDefaults(style: style))
            }
        }
        Divider()
        PreviewRow(title: "textOnly + custom") {
            MenuBarStatusLabel(state: .ready(snapshot), language: .english)
                .defaultAppStorage(previewDefaults(style: .textOnly, customLabel: "🕌 Tiba"))
        }
    }
    .padding(16)
    .frame(width: 360)
}

#Preview("Non-ready states") {
    VStack(alignment: .leading, spacing: 10) {
        PreviewRow(title: "idle") {
            MenuBarStatusLabel(state: .idle, language: .english)
        }
        PreviewRow(title: "loading") {
            MenuBarStatusLabel(state: .loading, language: .english)
        }
        PreviewRow(title: "locating") {
            MenuBarStatusLabel(state: .locating, language: .english)
        }
        PreviewRow(title: "needsLocation") {
            MenuBarStatusLabel(
                state: .needsLocation(.allowLocationOrEnterCoordinates),
                language: .english
            )
        }
        PreviewRow(title: "failed") {
            MenuBarStatusLabel(
                state: .failed(.locationUnavailable),
                language: .english
            )
        }
    }
    .padding(16)
    .frame(width: 360)
}

#Preview("Ready – dark") {
    let snapshot = previewSnapshot()
    return VStack(alignment: .leading, spacing: 10) {
        ForEach(MenuBarIconStyle.allCases, id: \.rawValue) { style in
            PreviewRow(title: String(describing: style)) {
                MenuBarStatusLabel(state: .ready(snapshot), language: .english)
                    .defaultAppStorage(previewDefaults(style: style))
            }
        }
    }
    .padding(16)
    .frame(width: 360)
    .preferredColorScheme(.dark)
}
