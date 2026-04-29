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
        calculationMethod: Int?
    ) throws -> PrayerSchedule? {
        let url = cacheFileURL(
            dateKey: date.prayerDayKey(),
            coordinate: coordinate,
            calculationMethod: calculationMethod
        )

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(PrayerSchedule.self, from: data)
    }

    func save(_ schedule: PrayerSchedule) throws {
        let directory = cacheDirectoryURL()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = cacheFileURL(
            dateKey: schedule.dateKey,
            coordinate: schedule.coordinate,
            calculationMethod: schedule.calculationMethod
        )

        let data = try encoder.encode(schedule)
        try data.write(to: url, options: [.atomic])
    }

    private func cacheFileURL(
        dateKey: String,
        coordinate: PrayerCoordinate,
        calculationMethod: Int?
    ) -> URL {
        let methodKey = calculationMethod.map(String.init) ?? "auto"
        return cacheDirectoryURL()
            .appendingPathComponent("\(dateKey)_\(coordinate.cacheKey)_\(methodKey).json")
    }

    private func cacheDirectoryURL() -> URL {
        fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tiba", isDirectory: true)
            .appendingPathComponent("PrayerSchedules", isDirectory: true)
    }
}
