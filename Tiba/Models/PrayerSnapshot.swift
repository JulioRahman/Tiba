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
        if minutesRemaining == 0 {
            return "Now"
        }

        let hours = minutesRemaining / 60
        let minutes = minutesRemaining % 60

        if hours == 0 {
            return "\(minutes)m"
        }

        if minutes == 0 {
            return "\(hours)h"
        }

        return "\(hours)h \(minutes)m"
    }

    nonisolated var compactCountdownText: String {
        if minutesRemaining == 0 {
            return "now"
        }

        if minutesRemaining >= 60 {
            return "\(minutesRemaining / 60)h"
        }

        return "\(minutesRemaining)m"
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
