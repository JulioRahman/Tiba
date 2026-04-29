enum MenuBarIconStyle: Int, CaseIterable, Identifiable {
    case textOnly
    case countdown
    case nextTime
    case pie
    case pieCountdown
    case pieInitial
    case bars
    case barsCountdown

    nonisolated var id: Int { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .textOnly: "Text Only"
        case .countdown: "Countdown"
        case .nextTime: "Next Time"
        case .pie: "Pie"
        case .pieCountdown: "Pie + Countdown"
        case .pieInitial: "Pie + Initial"
        case .bars: "Bars"
        case .barsCountdown: "Bars + Countdown"
        }
    }
}
