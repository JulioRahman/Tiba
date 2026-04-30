enum MenuBarIconStyle: Int, CaseIterable, Identifiable {
    case textOnly
    case countdown
    case nextTime
    case arc
    case arcCountdown
    case arcInitial
    case bars
    case barsCountdown

    nonisolated var id: Int { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .textOnly: "Text Only"
        case .countdown: "Countdown"
        case .nextTime: "Next Time"
        case .arc: "Arc"
        case .arcCountdown: "Arc + Countdown"
        case .arcInitial: "Arc + Initial"
        case .bars: "Bars"
        case .barsCountdown: "Bars + Countdown"
        }
    }
}
