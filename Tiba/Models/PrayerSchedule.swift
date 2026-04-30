import Foundation

struct PrayerEvent: Codable, Equatable, Identifiable {
    let prayer: Prayer
    let date: Date

    var id: String {
        "\(prayer.rawValue)-\(date.timeIntervalSince1970)"
    }
}

struct PrayerSchedule: Codable, Equatable {
    let dateKey: String
    let coordinate: PrayerCoordinate
    let calculationSettings: PrayerCalculationSettings
    let timezone: String?
    let events: [PrayerEvent]
}
