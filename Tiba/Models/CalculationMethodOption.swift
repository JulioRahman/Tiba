struct CalculationMethodOption: Identifiable, Hashable {
    let storageValue: Int
    let displayName: String

    nonisolated var id: Int { storageValue }
    nonisolated var queryValue: Int? { storageValue >= 0 ? storageValue : nil }

    nonisolated static let all: [CalculationMethodOption] = [
        .init(storageValue: -1, displayName: "Automatic"),
        .init(storageValue: 2, displayName: "ISNA"),
        .init(storageValue: 3, displayName: "Muslim World League"),
        .init(storageValue: 4, displayName: "Umm Al-Qura"),
        .init(storageValue: 11, displayName: "Singapore"),
        .init(storageValue: 20, displayName: "Kemenag RI"),
    ]

    nonisolated static func queryValue(for storageValue: Int) -> Int? {
        all.first(where: { $0.storageValue == storageValue })?.queryValue
    }
}
