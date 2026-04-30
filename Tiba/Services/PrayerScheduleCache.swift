import Foundation

struct PrayerScheduleCache {
    private let retentionDays = 30
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
        try? removeExpiredSchedules()

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

        try? removeExpiredSchedules()
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

    private func removeExpiredSchedules(now: Date = Date()) throws {
        let directory = cacheDirectoryURL()
        guard fileManager.fileExists(atPath: directory.path) else {
            return
        }

        let calendar = Calendar(identifier: .gregorian)
        let cutoffDate =
            calendar.date(
                byAdding: .day,
                value: -retentionDays,
                to: calendar.startOfDay(for: now)
            ) ?? now

        let fileURLs = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey]
        )

        for fileURL in fileURLs {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard resourceValues?.isRegularFile == true else {
                continue
            }

            guard let cacheDate = cacheDate(from: fileURL.lastPathComponent) else {
                continue
            }

            if cacheDate < cutoffDate {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }

    private func cacheDate(from fileName: String) -> Date? {
        guard fileName.hasSuffix(".json") else {
            return nil
        }

        let prefix = String(fileName.prefix(10))
        guard prefix.count == 10,
            fileName.dropFirst(10).first == "_"
        else {
            return nil
        }

        let parts = prefix.split(separator: "-")
        guard parts.count == 3,
            let year = Int(parts[0]),
            let month = Int(parts[1]),
            let day = Int(parts[2])
        else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else {
            return nil
        }

        let resolvedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        guard resolvedComponents.year == components.year,
            resolvedComponents.month == components.month,
            resolvedComponents.day == components.day
        else {
            return nil
        }

        return date
    }
}
