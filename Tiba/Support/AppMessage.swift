import Foundation

enum AppMessage: Equatable {
    case invalidLocation
    case invalidManualLocation
    case allowLocationOrEnterCoordinates
    case locationUnavailable
    case locationServicesDisabled
    case locationAccessNotAvailable
    case locationStatusUnsupported
    case aladhanInvalidURL
    case aladhanBadStatusCode(Int)
    case aladhanMissingPrayerTime(Prayer)
    case aladhanInvalidPrayerTime(Prayer, String)
    case raw(String)

    nonisolated func localized(language: AppLanguage) -> String {
        switch self {
        case .invalidLocation:
            TibaLocalization.string("error.invalidLocation", language: language)
        case .invalidManualLocation:
            TibaLocalization.string("error.invalidManualLocation", language: language)
        case .allowLocationOrEnterCoordinates:
            TibaLocalization.string("error.allowLocationOrEnterCoordinates", language: language)
        case .locationUnavailable:
            TibaLocalization.string("error.locationUnavailable", language: language)
        case .locationServicesDisabled:
            TibaLocalization.string("error.locationServicesDisabled", language: language)
        case .locationAccessNotAvailable:
            TibaLocalization.string("error.locationAccessNotAvailable", language: language)
        case .locationStatusUnsupported:
            TibaLocalization.string("error.locationStatusUnsupported", language: language)
        case .aladhanInvalidURL:
            TibaLocalization.string("error.aladhan.invalidURL", language: language)
        case .aladhanBadStatusCode(let code):
            TibaLocalization.string("error.aladhan.badStatusCode", language: language, code)
        case .aladhanMissingPrayerTime(let prayer):
            TibaLocalization.string(
                "error.aladhan.missingPrayerTime",
                language: language,
                prayer.displayName(language: language)
            )
        case .aladhanInvalidPrayerTime(let prayer, let value):
            TibaLocalization.string(
                "error.aladhan.invalidPrayerTime",
                language: language,
                prayer.displayName(language: language),
                value
            )
        case .raw(let message):
            message
        }
    }
}
