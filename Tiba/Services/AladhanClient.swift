import Foundation

enum AladhanClientError: LocalizedError {
    case invalidURL
    case badStatusCode(Int)
    case missingPrayerTime(Prayer)
    case invalidPrayerTime(Prayer, String)

    var errorDescription: String? {
        message.localized(language: .system)
    }

    var message: AppMessage {
        switch self {
        case .invalidURL:
            .aladhanInvalidURL
        case .badStatusCode(let code):
            .aladhanBadStatusCode(code)
        case .missingPrayerTime(let prayer):
            .aladhanMissingPrayerTime(prayer)
        case .invalidPrayerTime(let prayer, let value):
            .aladhanInvalidPrayerTime(prayer, value)
        }
    }
}

struct AladhanClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchSchedule(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings
    ) async throws -> PrayerSchedule {
        guard
            let url = requestURL(
                for: date,
                coordinate: coordinate,
                calculationSettings: calculationSettings
            )
        else {
            throw AladhanClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
            !(200...299).contains(httpResponse.statusCode)
        {
            throw AladhanClientError.badStatusCode(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(AladhanTimingsResponse.self, from: data)
        let timezone = decoded.data.meta?.timezone

        let events = try Prayer.allCases.map { prayer in
            guard let rawTime = decoded.data.timings.value(for: prayer) else {
                throw AladhanClientError.missingPrayerTime(prayer)
            }

            guard
                let parsedDate = parsePrayerDate(
                    rawTime,
                    prayerDate: date,
                    timezoneIdentifier: timezone
                )
            else {
                throw AladhanClientError.invalidPrayerTime(prayer, rawTime)
            }

            return PrayerEvent(prayer: prayer, date: parsedDate)
        }
        .sorted { $0.date < $1.date }

        return PrayerSchedule(
            dateKey: date.prayerDayKey(),
            coordinate: coordinate,
            calculationSettings: calculationSettings,
            timezone: timezone,
            events: events
        )
    }

    private func requestURL(
        for date: Date,
        coordinate: PrayerCoordinate,
        calculationSettings: PrayerCalculationSettings
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.aladhan.com"
        components.path = "/v1/timings/\(date.aladhanPathDate())"

        var queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "iso8601", value: "true"),
            URLQueryItem(
                name: "latitudeAdjustmentMethod",
                value: String(calculationSettings.latitudeAdjustmentMethod)
            ),
        ]

        if let method = calculationSettings.method {
            queryItems.append(URLQueryItem(name: "method", value: String(method)))
        }

        if let methodSettings = calculationSettings.methodSettings {
            queryItems.append(URLQueryItem(name: "methodSettings", value: methodSettings))
        }

        if let shafaq = calculationSettings.shafaq {
            queryItems.append(URLQueryItem(name: "shafaq", value: shafaq))
        }

        queryItems.append(
            URLQueryItem(name: "school", value: String(calculationSettings.asrSchool))
        )

        components.queryItems = queryItems
        return components.url
    }

    private func parsePrayerDate(
        _ rawValue: String,
        prayerDate: Date,
        timezoneIdentifier: String?
    ) -> Date? {
        let trimmed =
            rawValue
            .replacingOccurrences(of: #" \(.+\)$"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: trimmed) {
            return date
        }

        let parts = trimmed.split(separator: ":")
        guard parts.count >= 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1].prefix(2))
        else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        if let timezoneIdentifier, let timezone = TimeZone(identifier: timezoneIdentifier) {
            calendar.timeZone = timezone
        }

        let baseComponents = calendar.dateComponents([.year, .month, .day], from: prayerDate)
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = baseComponents.year
        components.month = baseComponents.month
        components.day = baseComponents.day
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components)
    }
}

private struct AladhanTimingsResponse: Decodable {
    let data: Payload

    struct Payload: Decodable {
        let timings: Timings
        let meta: Meta?
    }

    struct Meta: Decodable {
        let timezone: String?
    }

    struct Timings: Decodable {
        let imsak: String?
        let fajr: String?
        let sunrise: String?
        let dhuhr: String?
        let asr: String?
        let maghrib: String?
        let isha: String?

        enum CodingKeys: String, CodingKey {
            case imsak = "Imsak"
            case fajr = "Fajr"
            case sunrise = "Sunrise"
            case dhuhr = "Dhuhr"
            case asr = "Asr"
            case maghrib = "Maghrib"
            case isha = "Isha"
        }

        func value(for prayer: Prayer) -> String? {
            switch prayer {
            case .imsak: imsak
            case .fajr: fajr
            case .sunrise: sunrise
            case .dhuhr: dhuhr
            case .asr: asr
            case .maghrib: maghrib
            case .isha: isha
            }
        }
    }
}
