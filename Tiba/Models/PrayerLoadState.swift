enum PrayerLoadState: Equatable {
    case idle
    case locating
    case loading
    case ready(PrayerSnapshot)
    case needsLocation(AppMessage)
    case failed(AppMessage)

    nonisolated var snapshot: PrayerSnapshot? {
        if case .ready(let snapshot) = self {
            return snapshot
        }

        return nil
    }
}
