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
Prerequisites:
- Flutter SDK compatible with the version in `pubspec.yaml`
- Android Studio and/or Xcode for mobile builds
- A Google Cloud project if you want to test Drive sync

Install dependencies and run the app:

```bash
flutter pub get
flutter run
```

Run with Google Drive sync enabled:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_GOOGLE_SERVER_CLIENT_ID
```

Run checks:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
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
