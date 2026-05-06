# Contributing

Thanks for your interest in improving Cleaning Tracker. This project welcomes bug fixes, documentation improvements, tests, and focused feature work.

## Development Setup
1. Install Flutter and confirm your environment with:

```bash
flutter doctor
```

2. Fetch dependencies:

```bash
flutter pub get
```

3. Generate mocks when needed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:

```bash
flutter run
```

Drive sync is optional. Without it, the app runs locally with all non-cloud features enabled. To exercise sign-in and Drive backup, follow the Google Cloud setup in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md#4-google-cloud--drive-sync-setup) and pass your Web OAuth client ID at run time:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

## Quality Checks
Before opening a pull request, run:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

For UI changes, run the relevant golden tests. Update goldens only when the visual change is intentional:

```bash
flutter test --update-goldens
```

## Pull Requests
- Keep changes focused and explain the user-facing impact.
- Add or update tests for behavior changes.
- Update docs when setup, architecture, or workflows change.
- Do not commit secrets, signing keys, local build output, or generated cache directories.

## Coding Style
Follow the lints in `analysis_options.yaml` and the architecture documented in `docs/ARCHITECTURE.md`. Keep business logic in services where possible and keep widgets focused on presentation and interaction.
