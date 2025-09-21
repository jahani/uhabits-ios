# Loop Habit Tracker for iOS

The `ios/LoopHabitTracker` directory contains the SwiftUI implementation of the Loop Habit Tracker iOS application. The project is described using an [XcodeGen](https://github.com/yonaskolb/XcodeGen) manifest (`project.yml`). To generate an Xcode project:

1. Install XcodeGen (`brew install xcodegen`).
2. From the repository root run:
   ```bash
   cd ios/LoopHabitTracker
   xcodegen generate
   ```
3. Open the generated `LoopHabitTracker.xcodeproj` in Xcode and run on iOS 17+.

## Feature coverage

The iOS codebase mirrors the structure of the original Android project while adopting SwiftUI patterns:

- Habit list with score rings, streak indicators and quick completion toggle.
- Habit detail screen with charts, history grid, statistics and editable notes.
- Persistence backed by JSON files (`habits.json`) with sample bootstrap data.
- Modular feature folders for list, detail, creation and settings flows.
- Placeholders for reminders, data export, widgets and backups to clearly mark the remaining work needed for parity with Android.
- Asset catalog entries (app icon, accent colors) are stubbed so the build succeeds; replace the placeholder icon names with real artwork before publishing to the App Store.

## Roadmap placeholders

Some Android features require native iOS services and will be delivered in follow-up iterations. The UI already reserves their location:

- Reminder configuration toggles, waiting for UserNotifications integration.
- CSV/SQLite export entry points, pending share sheet wiring.
- Widget preview cards earmarked for WidgetKit.
- Backup and restore buttons in the settings screen to be connected to Files/CloudKit flows.

Each placeholder view describes the missing functionality so future contributors know exactly where to continue.
