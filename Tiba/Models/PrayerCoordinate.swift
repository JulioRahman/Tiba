import Foundation

struct PrayerCoordinate: Codable, Equatable {
    var latitude: Double
    var longitude: Double

    var isValid: Bool {
        (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    var cacheKey: String {
        let roundedLatitude = (latitude * 1_000).rounded() / 1_000
        let roundedLongitude = (longitude * 1_000).rounded() / 1_000
        return String(format: "%.3f_%.3f", roundedLatitude, roundedLongitude)
    }
}
