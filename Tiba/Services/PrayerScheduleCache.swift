import Foundation

struct PrayerScheduleCache {
    private let fileManager: FileManager
    private let decoder = JSONDecoder()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func schedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings
    ) throws -> PrayerSchedule? {
        let url = cacheFileURL(
            dateKey: date.prayerDayKey(),
            coordinate: coordinate,
            calculationSettings: calculationSettings
        )

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        let schedule = try decoder.decode(PrayerSchedule.self, from: data)
        guard isComplete(schedule) else {
            return nil
        }

        return schedule
    }

    func save(_ schedule: PrayerSchedule) throws {
        let directory = cacheDirectoryURL()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = cacheFileURL(
            dateKey: schedule.dateKey,
            coordinate: schedule.coordinate,
            calculationSettings: schedule.calculationSettings
        )

        let data = try encoder.encode(schedule)
        try data.write(to: url, options: [.atomic])
    }

    private func cacheFileURL(
        dateKey: String,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings
    ) -> URL {
        return cacheDirectoryURL()
            .appendingPathComponent(
                "\(dateKey)_\(coordinate.cacheKey)_\(calculationSettings.cacheKey).json"
            )
    }

    private func cacheDirectoryURL() -> URL {
        fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tiba", isDirectory: true)
            .appendingPathComponent("PrayerSchedules", isDirectory: true)
    }

    private func isComplete(_ schedule: PrayerSchedule) -> Bool {
        let availablePrayers = Set(schedule.events.map(\.prayer))
        return Prayer.allCases.allSatisfy { availablePrayers.contains($0) }
    }
}
