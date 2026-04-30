import SwiftUI

struct ScheduleSectionView: View {
    let state: PrayerLoadState
    let language: AppLanguage

    var body: some View {
        if case .ready(let snapshot) = state {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(snapshot.events) { event in
                    let isNextPrayer = event.prayer == snapshot.nextEvent.prayer

                    HStack {
                        Image(systemName: event.prayer.symbolName)
                            .frame(width: 24, alignment: .center)

                        Text(event.prayer.displayName(language: language))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(event.date, format: .dateTime.hour().minute())
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                    .font(isNextPrayer ? .body.weight(.semibold) : .body)
                    .foregroundStyle(isNextPrayer ? .primary : .secondary)
                }
            }
        }
    }
}
