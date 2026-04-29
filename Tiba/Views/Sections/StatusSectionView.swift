import SwiftUI

struct StatusSectionView: View {
    let state: PrayerLoadState

    var body: some View {
        switch state {
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
}
