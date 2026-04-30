import Foundation

protocol PrayerSettingsProviding {
    var useManualLocation: Bool { get set }
    var manualLatitude: Double { get }
    var manualLongitude: Double { get }
    var calculationMethod: Int { get }
    var latitudeAdjustmentMethod: Int { get }
    var asrSchool: Int { get }
    var showImsak: Bool { get }
}

enum PrayerSettings {
    static var live: any PrayerSettingsProviding {
        UserDefaultsPrayerSettings()
    }
}

struct UserDefaultsPrayerSettings: PrayerSettingsProviding {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var useManualLocation: Bool {
        get {
            userDefaults.bool(forKey: TibaDefaults.useManualLocation)
        }
        nonmutating set {
            userDefaults.set(newValue, forKey: TibaDefaults.useManualLocation)
        }
    }

    var manualLatitude: Double {
        userDefaults.object(forKey: TibaDefaults.manualLatitude) as? Double
            ?? TibaDefaults.defaultManualLatitude
    }

    var manualLongitude: Double {
        userDefaults.object(forKey: TibaDefaults.manualLongitude) as? Double
            ?? TibaDefaults.defaultManualLongitude
    }

    var calculationMethod: Int {
        userDefaults.object(forKey: TibaDefaults.calculationMethod) as? Int
            ?? TibaDefaults.defaultCalculationMethod
    }

    var latitudeAdjustmentMethod: Int {
        userDefaults.object(forKey: TibaDefaults.latitudeAdjustmentMethod) as? Int
            ?? TibaDefaults.defaultLatitudeAdjustmentMethod
    }

    var asrSchool: Int {
        userDefaults.object(forKey: TibaDefaults.asrSchool) as? Int
            ?? TibaDefaults.defaultAsrSchool
    }

    var showImsak: Bool {
        userDefaults.bool(forKey: TibaDefaults.showImsak)
    }
}
