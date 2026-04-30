import SwiftUI

struct ScheduleSectionView: View {
    let state: PrayerLoadState
    @Binding var showImsak: Bool
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if case .ready(let snapshot) = state {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(snapshot.events) { event in
                        HStack {
                            Label(
                                event.prayer.displayName(language: language),
                                systemImage: event.prayer.symbolName
                            )
                            .foregroundStyle(
                                event.prayer == snapshot.nextEvent.prayer ? .primary : .secondary
                            )

                            Spacer()

                            Text(event.date, format: .dateTime.hour().minute())
                                .monospacedDigit()
                                .foregroundStyle(
                                    event.prayer == snapshot.nextEvent.prayer
                                        ? .primary : .secondary
                                )
                        }
                        .font(
                            event.prayer == snapshot.nextEvent.prayer
                                ? .body.weight(.semibold) : .body
                        )
                    }
                }
            }

            Toggle(
                TibaLocalization.string("settings.showImsak", language: language),
                isOn: $showImsak
            )
            .font(.callout)
        }
    }
}
