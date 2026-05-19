# Cleaning Tracker

A Flutter app for tracking recurring household cleaning and maintenance tasks.

## Overview
Cleaning Tracker helps you keep up with household systems and chores such as HVAC filters, kitchen maintenance, bathroom cleaning, and bedroom resets. It tracks each task's interval, history, and current status so you can see what is healthy, degrading, or overdue at a glance.

## Key Features
- **Status Dashboard:** Visual overview of all tracked systems with an overall "Home Health Score."
- **Task Tracking:** Custom intervals, status levels (Operational, Degrading, Critical), and full completion history.
- **Smart Reminders:** Intelligent notifications based on due dates and user-defined lead times.
- **Cloud Sync:** Secure backups to Google Drive via JSON files.
- **Snooze Support:** Flexibility to delay tasks without losing your tracking history.

## Tech Stack
- Flutter and Dart
- SQLite via `sqflite`
- Local notifications via `flutter_local_notifications`
- Google Sign-In and Google Drive backup support
- Unit, widget, integration, and golden tests

## Getting Started

### Prerequisites
- **Flutter SDK** `>=3.11.0 <4.0.0` (matches the constraint in `pubspec.yaml`). Verify with `flutter doctor`.
- **JDK 17** for Android builds.
- **Android Studio** (with an Android SDK + emulator) and/or **Xcode 14.3+** for iOS builds (deployment target iOS 13.0).
- A **Google Cloud project** *only* if you want to exercise Drive sync. The app runs fully offline without it.

### Install and run
```bash
git clone https://github.com/Shir0o/cleaning-tracker.git
cd cleaning-tracker
flutter pub get

# Copy the env template (required — `.env` is bundled as an asset)
cp .env.example .env

# Generate test mocks (only required if you'll run the test suite)
dart run build_runner build --delete-conflicting-outputs

# Run on an attached device or emulator (Drive sync disabled)
flutter run
```

With an empty `GOOGLE_SERVER_CLIENT_ID` in `.env`, the app falls back to a placeholder client ID (see [`lib/main.dart`](lib/main.dart)). All local features — tasks, completions, reminders, theming — work; only Google Sign-In and Drive backup are inert.

### Run with Drive sync
1. Follow the Google Cloud setup in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md#4-google-cloud--drive-sync-setup) to create OAuth credentials.
2. Set the **Web** OAuth client ID in your local `.env`:

```bash
# .env (gitignored)
GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

3. Run normally:

```bash
flutter run
```

`.env` is loaded at runtime via `flutter_dotenv`. For CI or release builds you can still override at compile time with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`, which takes precedence over `.env`. The same flag works with `flutter build apk`, `flutter build appbundle`, and `flutter build ios`.

### Quality checks
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test                                  # unit, widget, golden, scenario
flutter test integration_test                 # requires a connected device/emulator
flutter test --update-goldens                 # only when intentional UI changes
```

## Documentation Index
- [Architecture](docs/ARCHITECTURE.md): Technical stack, services, and data flow.
- [Features](docs/FEATURES.md): Deep dive into user-facing functionality.
- [Testing Strategy](docs/TESTING.md): TDD mandate, test categories, and workflows.
- [Database Schema](docs/DATABASE.md): Table definitions and migration logic.
- [Development Guide](docs/DEVELOPMENT.md): Setup instructions, dependencies, and environment configuration.
- [Release Notes](RELEASE.md): Version history and changelog.

## Contributing
Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, testing expectations, and pull request guidelines.

## Security
Please do not open public issues for vulnerabilities or sensitive data exposure. See [SECURITY.md](SECURITY.md) for the reporting process.

## License
Cleaning Tracker is released under the [MIT License](LICENSE).
