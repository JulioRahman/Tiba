enum MenuBarIconStyle: Int, CaseIterable, Identifiable {
    case textOnly
    case countdown
    case nextTime
    case arc
    case arcCountdown
    case arcInitial
    case bars
    case barsCountdown

    var id: Int { rawValue }

    var displayName: String {
        displayName(language: .system)
    }

    func displayName(language: AppLanguage) -> String {
        switch self {
        case .textOnly:
            TibaLocalization.string("menubarStyle.textOnly", language: language)
        case .countdown:
            TibaLocalization.string("menubarStyle.countdown", language: language)
        case .nextTime:
            TibaLocalization.string("menubarStyle.nextTime", language: language)
        case .arc:
            TibaLocalization.string("menubarStyle.arc", language: language)
        case .arcCountdown:
            TibaLocalization.string("menubarStyle.arcCountdown", language: language)
        case .arcInitial:
            TibaLocalization.string("menubarStyle.arcInitial", language: language)
        case .bars:
            TibaLocalization.string("menubarStyle.bars", language: language)
        case .barsCountdown:
            TibaLocalization.string("menubarStyle.barsCountdown", language: language)
        }
    }
}
