import SwiftUI

struct StatusSectionView: View {
    let state: PrayerLoadState
    let language: AppLanguage

    var body: some View {
        switch state {
        case .ready(let snapshot):
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(snapshot.nextEvent.prayer.displayName(language: language))
                        .font(.title2.weight(.semibold))

                    Spacer()

                    Text(snapshot.countdownText(language: language))
                        .font(.title3.monospacedDigit().weight(.medium))
                }

                Text(snapshot.nextEvent.date, format: .dateTime.weekday(.wide).hour().minute())
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

        case .locating:
            Label(
                TibaLocalization.string("status.detectingLocation", language: language),
                systemImage: "location"
            )
            .font(.headline)

        case .loading, .idle:
            Label(
                TibaLocalization.string("status.loadingPrayerTimes", language: language),
                systemImage: "clock"
            )
            .font(.headline)

        case .needsLocation(let message):
            Label(message.localized(language: language), systemImage: "location.slash")
                .font(.headline)
                .foregroundStyle(.secondary)

        case .failed(let message):
            Label(message.localized(language: language), systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
