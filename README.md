# Tiba

Tiba is a native macOS menu bar app for prayer times.

The app keeps the next prayer immediately visible in the menu bar, with a focus on glanceable visual status instead of opening a full schedule app. The name comes from Bahasa Indonesia: "tiba" means "to arrive" or "it's time".

## Status

Tiba is an early prototype. The current build covers the core loop:

- macOS `MenuBarExtra` app
- countdown to the next prayer
- Aladhan prayer-time lookup
- daily response cache
- CoreLocation auto-detection
- manual latitude/longitude override
- several menu bar display styles

## Menu Bar Styles

The menu bar label can be switched between:

- text only
- countdown in minutes or hours
- next prayer time
- progress arc
- progress arc with countdown
- progress arc with prayer initial
- five-bar prayer indicator
- five-bar indicator with countdown

The default is `Pie + Countdown`.

## Data Source

Prayer times are fetched from the [Aladhan API](https://aladhan.com/prayer-times-api).

Tiba requests timings by date and coordinates, then stores the result in the local cache. For normal use, it should only need one API request per day for the current location and calculation method.

## Privacy

Tiba uses CoreLocation only to calculate local prayer times.

Location data is used on-device to request prayer times from Aladhan. Cached prayer schedules are stored locally in the user's cache directory. Manual coordinates can be used instead of location access.

## Requirements

- macOS 13 Ventura or later
- Apple Silicon Mac
- Xcode with SwiftUI, AppKit, and CoreLocation support

The project is intentionally macOS-only and native. There is no iOS, Catalyst, or multiplatform target.

## Development

Open the project in Xcode:

```bash
open Tiba.xcodeproj
```

Or build from the command line:

```bash
xcodebuild -scheme Tiba -project Tiba.xcodeproj -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

## Project Direction

The immediate goal is to make the menu bar item excellent:

- more refined arc and bar variants
- better active-prayer visual language
- smarter light/dark appearance
- notification support
- monthly prayer schedule
- configurable calculation settings
- packaging and release flow

Monetization is not a priority yet. The project currently leans open source, with premium customization or donations as possible future options.

## Development Transparency

This project uses AI-assisted development as part of the workflow. The intent is not to hide that: AI helps with implementation, iteration, and code review, while the app direction, product taste, and final decisions remain human-owned.

## License

Tiba is released under the MIT License. See [LICENSE](LICENSE) for details.
