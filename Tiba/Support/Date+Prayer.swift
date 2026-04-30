import Foundation

extension Date {
    func prayerDayKey(calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    func aladhanPathDate(calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return String(
            format: "%02d-%02d-%04d",
            components.day ?? 0,
            components.month ?? 0,
            components.year ?? 0
        )
    }

    func addingDays(_ days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
}
