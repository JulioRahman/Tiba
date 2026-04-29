enum PrayerLoadState: Equatable {
    case idle
    case locating
    case loading
    case ready(PrayerSnapshot)
    case needsLocation(String)
    case failed(String)

    nonisolated var snapshot: PrayerSnapshot? {
        if case .ready(let snapshot) = self {
            return snapshot
        }

        return nil
    }
}
