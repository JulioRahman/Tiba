struct CalculationMethodOption: Identifiable, Hashable {
    let storageValue: Int
    let displayNameKey: String

    nonisolated var id: Int { storageValue }
    nonisolated var queryValue: Int? { storageValue >= 0 ? storageValue : nil }
    nonisolated var displayName: String { displayName(language: .system) }

    nonisolated func displayName(language: AppLanguage) -> String {
        TibaLocalization.string(displayNameKey, language: language)
    }

    nonisolated static let all: [CalculationMethodOption] = [
        .init(storageValue: -1, displayNameKey: "calculation.automatic"),
        .init(storageValue: 2, displayNameKey: "calculation.isna"),
        .init(storageValue: 3, displayNameKey: "calculation.muslimWorldLeague"),
        .init(storageValue: 4, displayNameKey: "calculation.ummAlQura"),
        .init(storageValue: 11, displayNameKey: "calculation.singapore"),
        .init(storageValue: 20, displayNameKey: "calculation.kemenagRI"),
    ]

    nonisolated static func queryValue(for storageValue: Int) -> Int? {
        all.first(where: { $0.storageValue == storageValue })?.queryValue
    }
}
