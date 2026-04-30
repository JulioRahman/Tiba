import Foundation

struct PrayerSnapshot: Equatable {
    let now: Date
    let events: [PrayerEvent]
    let nextEvent: PrayerEvent
    let previousEvent: PrayerEvent?

    nonisolated var remaining: TimeInterval {
        max(nextEvent.date.timeIntervalSince(now), 0)
    }

    nonisolated var minutesRemaining: Int {
        max(Int(ceil(remaining / 60)), 0)
    }

    nonisolated var countdownText: String {
        countdownText(language: .system)
    }

    nonisolated func countdownText(language: AppLanguage) -> String {
        if minutesRemaining == 0 {
            return TibaLocalization.string("countdown.now", language: language)
        }

        let hours = minutesRemaining / 60
        let minutes = minutesRemaining % 60
        let hourUnit = TibaLocalization.string("countdown.hour.abbreviation", language: language)
        let minuteUnit = TibaLocalization.string("countdown.minute.abbreviation", language: language)

        if hours == 0 {
            return "\(minutes)\(minuteUnit)"
        }

        if minutes == 0 {
            return "\(hours)\(hourUnit)"
        }

        return "\(hours)\(hourUnit) \(minutes)\(minuteUnit)"
    }

    nonisolated var compactCountdownText: String {
        compactCountdownText(language: .system)
    }

    nonisolated func compactCountdownText(language: AppLanguage) -> String {
        if minutesRemaining == 0 {
            return TibaLocalization.string("countdown.now.compact", language: language)
        }

        let hourUnit = TibaLocalization.string("countdown.hour.abbreviation", language: language)
        let minuteUnit = TibaLocalization.string("countdown.minute.abbreviation", language: language)

        if minutesRemaining >= 60 {
            return "\(minutesRemaining / 60)\(hourUnit)"
        }

        return "\(minutesRemaining)\(minuteUnit)"
    }

    nonisolated var progress: Double {
        guard let previousDate = previousEvent?.date else {
            return 0
        }

        let total = nextEvent.date.timeIntervalSince(previousDate)
        guard total > 0 else {
            return 0
        }

        let elapsed = now.timeIntervalSince(previousDate)
        return min(max(elapsed / total, 0), 1)
    }
}
