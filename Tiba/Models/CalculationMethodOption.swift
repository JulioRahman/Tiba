import Foundation

struct CalculationMethodOption: Identifiable, Hashable {
    let storageValue: Int
    let displayNameKey: String
    let method: Int?
    let methodSettings: String?
    let shafaq: String?

    nonisolated var id: Int { storageValue }
    nonisolated var displayName: String { displayName(language: .system) }

    nonisolated func displayName(language: AppLanguage) -> String {
        TibaLocalization.string(displayNameKey, language: language)
    }

    nonisolated func calculationSettings(
        asrSchool: Int,
        latitudeAdjustmentMethod: Int
    ) -> PrayerCalculationSettings {
        PrayerCalculationSettings(
            method: method,
            methodSettings: methodSettings,
            shafaq: shafaq,
            latitudeAdjustmentMethod: latitudeAdjustmentMethod,
            asrSchool: asrSchool
        )
    }

    nonisolated static let all: [CalculationMethodOption] = [
        .automatic,
        .aladhanMethod(20, displayNameKey: "calculation.kemenagRI"),
        .init(
            storageValue: 99,
            displayNameKey: "calculation.muhammadiyah",
            method: 99,
            methodSettings: "18,null,18",
            shafaq: nil
        ),
        .aladhanMethod(0, displayNameKey: "calculation.jafari"),
        .aladhanMethod(1, displayNameKey: "calculation.karachi"),
        .aladhanMethod(2, displayNameKey: "calculation.isna"),
        .aladhanMethod(3, displayNameKey: "calculation.muslimWorldLeague"),
        .aladhanMethod(4, displayNameKey: "calculation.ummAlQura"),
        .aladhanMethod(5, displayNameKey: "calculation.egypt"),
        .aladhanMethod(7, displayNameKey: "calculation.tehran"),
        .aladhanMethod(8, displayNameKey: "calculation.gulf"),
        .aladhanMethod(9, displayNameKey: "calculation.kuwait"),
        .aladhanMethod(10, displayNameKey: "calculation.qatar"),
        .aladhanMethod(11, displayNameKey: "calculation.singapore"),
        .aladhanMethod(12, displayNameKey: "calculation.france"),
        .aladhanMethod(13, displayNameKey: "calculation.diyanetTurkey"),
        .aladhanMethod(14, displayNameKey: "calculation.russia"),
        .init(
            storageValue: 15,
            displayNameKey: "calculation.moonsighting",
            method: 15,
            methodSettings: nil,
            shafaq: "general"
        ),
        .aladhanMethod(16, displayNameKey: "calculation.dubai"),
        .aladhanMethod(17, displayNameKey: "calculation.jakim"),
        .aladhanMethod(18, displayNameKey: "calculation.tunisia"),
        .aladhanMethod(19, displayNameKey: "calculation.algeria"),
        .aladhanMethod(21, displayNameKey: "calculation.morocco"),
        .aladhanMethod(22, displayNameKey: "calculation.portugal"),
        .aladhanMethod(23, displayNameKey: "calculation.jordan"),
    ]

    nonisolated static func calculationSettings(
        for storageValue: Int,
        latitudeAdjustmentMethod: Int,
        asrSchool: Int
    ) -> PrayerCalculationSettings {
        let option = all.first(where: { $0.storageValue == storageValue }) ?? .automatic
        return option.calculationSettings(
            asrSchool: asrSchool,
            latitudeAdjustmentMethod: LatitudeAdjustmentMethodOption.queryValue(
                for: latitudeAdjustmentMethod
            )
        )
    }

    private nonisolated static var automatic: CalculationMethodOption {
        .init(
            storageValue: -1,
            displayNameKey: "calculation.automatic",
            method: nil,
            methodSettings: nil,
            shafaq: nil
        )
    }

    private nonisolated static func aladhanMethod(
        _ method: Int,
        displayNameKey: String
    ) -> CalculationMethodOption {
        .init(
            storageValue: method,
            displayNameKey: displayNameKey,
            method: method,
            methodSettings: nil,
            shafaq: nil
        )
    }
}

struct LatitudeAdjustmentMethodOption: Identifiable, Hashable {
    let storageValue: Int
    let displayNameKey: String

    nonisolated var id: Int { storageValue }
    nonisolated var displayName: String { displayName(language: .system) }

    nonisolated func displayName(language: AppLanguage) -> String {
        TibaLocalization.string(displayNameKey, language: language)
    }

    nonisolated static let all: [LatitudeAdjustmentMethodOption] = [
        .init(storageValue: 1, displayNameKey: "latitudeAdjustment.middleOfNight"),
        .init(storageValue: 2, displayNameKey: "latitudeAdjustment.oneSeventh"),
        .init(storageValue: 3, displayNameKey: "latitudeAdjustment.angleBased"),
    ]

    nonisolated static func queryValue(for storageValue: Int) -> Int {
        all.first(where: { $0.storageValue == storageValue })?.storageValue
            ?? TibaDefaults.defaultLatitudeAdjustmentMethod
    }
}

struct AsrSchoolOption: Identifiable, Hashable {
    let storageValue: Int
    let displayNameKey: String

    nonisolated var id: Int { storageValue }
    nonisolated var displayName: String { displayName(language: .system) }

    nonisolated func displayName(language: AppLanguage) -> String {
        TibaLocalization.string(displayNameKey, language: language)
    }

    nonisolated static let all: [AsrSchoolOption] = [
        .init(storageValue: 0, displayNameKey: "asr.standard"),
        .init(storageValue: 1, displayNameKey: "asr.hanafi"),
    ]

    static func queryValue(for storageValue: Int) -> Int {
        all.first(where: { $0.storageValue == storageValue })?.storageValue
            ?? TibaDefaults.defaultAsrSchool
    }
}

struct PrayerCalculationSettings: Codable, Equatable, Hashable {
    let method: Int?
    let methodSettings: String?
    let shafaq: String?
    let latitudeAdjustmentMethod: Int
    let asrSchool: Int

    nonisolated var cacheKey: String {
        [
            "method-\(method.map(String.init) ?? "auto")",
            "settings-\(methodSettings?.replacingOccurrences(of: ",", with: "-") ?? "default")",
            "shafaq-\(shafaq ?? "default")",
            "latadj-\(latitudeAdjustmentMethod)",
            "school-\(asrSchool)",
        ]
        .joined(separator: "_")
    }
}
