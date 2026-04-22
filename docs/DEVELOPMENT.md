# Development Guide

This guide describes how to set up the development environment for the Cleaning Tracker app.

## 1. Prerequisites
- **Flutter SDK:** >= 3.11.0
- **Android Studio / Xcode:** For mobile builds.
- **Google Cloud Console Account:** For Drive API configuration.

## 2. Getting Started
```bash
# Clone the repository
git clone <repo-url>
cd cleaning-tracker

# Fetch dependencies
flutter pub get

# Generate mocks for tests
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Architecture & Standards
- **Coding Style:** Follow standard Dart/Flutter linting rules defined in `analysis_options.yaml`.
- **TDD Requirement:** All changes *must* be accompanied by relevant tests (unit, widget, golden).
- **Service-Oriented Architecture:** Logic should be kept in dedicated services (Database, Notification, Drive) and not within UI widgets.

## 4. Environment Secrets
The app requires a Google Server Client ID for Google Sign-In and Drive Sync. This value is provided at build time using the `--dart-define` flag:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_GOOGLE_SERVER_CLIENT_ID
```

For development, if no flag is provided, the app defaults to `dummy_client_id` (see `lib/main.dart`).

## 5. Development Workflow
1. **Research & Plan:** Analyze the task and design your approach.
2. **Implement Tests First:** Create failing tests (TDD).
3. **Coding Phase:** Write the feature or fix.
4. **Validation:** Ensure `flutter analyze` and `flutter test` both pass.
5. **Commit:** Use modular, logical commits.

## 6. Testing with Goldens
To update or verify screenshots (Golden tests), use the following command:
```bash
flutter test --update-goldens
```
Goldens are stored in `test/goldens/` and must be checked into the repository to ensure UI consistency across different machines and CI environments.
