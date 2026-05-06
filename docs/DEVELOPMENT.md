# Development Guide

This guide covers setting up the Cleaning Tracker development environment, configuring Google Drive sync, and running the project locally.

## 1. Prerequisites
- **Flutter SDK:** `>=3.11.0 <4.0.0` (see `pubspec.yaml`). Run `flutter doctor` to verify a clean toolchain.
- **JDK 17** for Android builds (Gradle and the Android plugin require it).
- **Android Studio** with the Android SDK + an emulator or physical device.
- **Xcode 15+** and CocoaPods (`sudo gem install cocoapods`) for iOS builds (macOS only).
- **Google Cloud Console** access — only required if you plan to test Drive sync.

## 2. Initial Setup
```bash
git clone <repo-url>
cd cleaning-tracker

# Fetch Flutter/Dart dependencies
flutter pub get

# Generate mocks for the unit-test suite
dart run build_runner build --delete-conflicting-outputs

# (iOS only) install CocoaPods dependencies
cd ios && pod install && cd ..
```

## 3. Running the App Locally

### Without Drive sync (default)
```bash
flutter run
```

When `GOOGLE_SERVER_CLIENT_ID` is not provided, [`lib/main.dart`](../lib/main.dart) substitutes the placeholder `dummy_client_id`. Google Sign-In will fail to initialize but every other feature — tasks, completions, notifications, theming, local persistence — works normally. This is the recommended path for most contributors.

### With Drive sync
```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

The same flag works with `flutter build apk`, `flutter build appbundle`, and `flutter build ios`.

### Common build commands
```bash
flutter build apk --debug                    # Android debug APK
flutter build apk --release                  # Android release APK (uses debug signing — see android/app/build.gradle.kts)
flutter build appbundle                      # Play Store bundle
flutter build ios --no-codesign              # iOS build without signing (CI-friendly)
dart run flutter_launcher_icons              # Regenerate platform launcher icons from assets/icon/app_icon.png
```

## 4. Google Cloud / Drive Sync Setup
The app uses [`google_sign_in`](https://pub.dev/packages/google_sign_in) `^7.2.0` and the Drive REST API to back up your data as a JSON file in the user's Drive. Setting this up requires creating OAuth 2.0 credentials in Google Cloud Console.

### 4.1 Create a project and enable the Drive API
1. Open the [Google Cloud Console](https://console.cloud.google.com/) and create (or select) a project.
2. In **APIs & Services → Library**, enable the **Google Drive API**.
3. In **APIs & Services → OAuth consent screen**, configure an *External* app. While the app is in **Testing** mode, add the Google account you'll sign in with as a *Test user* — otherwise sign-in will be blocked.
4. Add the scope `https://www.googleapis.com/auth/drive.file` (the only scope the app requests).

### 4.2 Create OAuth client IDs
You need **two** OAuth 2.0 client IDs from **APIs & Services → Credentials → Create credentials → OAuth client ID**:

| Type | Purpose | Where it goes |
| --- | --- | --- |
| **Web application** | Used as `serverClientId` so Google issues ID tokens the app can verify. | `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` |
| **Android** | Authorizes your debug/release Android builds. | None — Google links it to your build via the package name + SHA-1. |
| **iOS** *(only if building for iOS)* | Authorizes your iOS bundle. | `Info.plist` (see §4.4). |

**Android client:**
- Package name: `com.cleaningtracker.app` (see [`android/app/build.gradle.kts`](../android/app/build.gradle.kts)).
- SHA-1 fingerprint of the signing certificate. For local debug builds:
  ```bash
  # macOS / Linux
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey \
      -storepass android -keypass android | grep SHA1

  # Windows (PowerShell or cmd.exe)
  keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey ^
      -storepass android -keypass android | findstr SHA1
  ```
  Add additional SHA-1s for any release keystore you use.

**iOS client:**
- Bundle ID: `com.cleaningtracker.app` (or whatever you set in Xcode).

### 4.3 Pass the Web client ID at build time
```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=123456789-xxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
```

To avoid retyping it, copy the committed template:

```bash
cp dart_defines.example.json dart_defines.json    # gitignored
# edit dart_defines.json with your real Web client ID
flutter run --dart-define-from-file=dart_defines.json
```

Or export an alias:

```bash
alias ctrun='flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=$GOOGLE_SERVER_CLIENT_ID'
```

> **Never commit your client ID files, OAuth secrets, or `.env` files.** The Web client ID itself is not secret, but anything else from Google Cloud should stay local. See [SECURITY.md](../SECURITY.md).

### 4.4 iOS-specific wiring (optional)
The committed [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) does **not** yet declare a `GIDClientID` or reversed-client-ID URL scheme. A ready-to-paste snippet lives at [`ios/Runner/Info.plist.gid.example`](../ios/Runner/Info.plist.gid.example). If you build the iOS target with Drive sync, add:

```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Paste the "iOS URL scheme" / reversed client ID exactly as
           shown in Google Cloud Console — it already starts with
           "com.googleusercontent.apps." Do not add the prefix again. -->
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Both values come from the iOS OAuth client you created in §4.2 — Google Cloud shows them as **iOS client ID** and **iOS URL scheme**. Keep these edits local; do not commit personal client IDs.

## 5. Architecture & Standards
- **Coding style:** standard Dart/Flutter lints, configured in [`analysis_options.yaml`](../analysis_options.yaml).
- **TDD requirement:** every behavior change ships with tests (see [TESTING.md](TESTING.md)).
- **Service-oriented architecture:** business logic lives in `DatabaseService`, `NotificationService`, and `DriveService` — keep widgets focused on presentation. Details in [ARCHITECTURE.md](ARCHITECTURE.md).

## 6. Development Workflow
1. **Plan:** read the relevant service / widget code and design the change.
2. **Tests first:** add a failing unit, widget, scenario, or golden test (TDD).
3. **Implement:** write the minimum code to make the test pass.
4. **Validate:**
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   ```
5. **Commit:** prefer small, logical commits. Update goldens only when the visual change is intentional.

## 7. Golden Tests
Goldens live in `test/goldens/` and are committed so CI can detect visual regressions across machines.

```bash
flutter test test/*_golden_test.dart      # verify
flutter test --update-goldens             # regenerate after intentional UI changes
```

## 8. Troubleshooting
- **`PlatformException(sign_in_failed, ...)`** — usually a missing or wrong Android SHA-1, missing test user on the OAuth consent screen, or a mismatched `GOOGLE_SERVER_CLIENT_ID`. Re-check §4.
- **Mocks won't compile after editing a service** — re-run `dart run build_runner build --delete-conflicting-outputs`.
- **Goldens fail in CI but pass locally** — make sure you ran `flutter test --update-goldens` from a clean checkout and committed the regenerated PNGs.
- **iOS build fails with "Sandbox: rsync deny"** — Xcode 15+ enables `ENABLE_USER_SCRIPT_SANDBOXING` by default, which breaks Flutter's build phase scripts. In Xcode open `Runner.xcworkspace`, select the **Runner** target → **Build Settings**, search for `User Script Sandboxing`, and set it to **No**. Then re-run `cd ios && pod install` if you also changed native dependencies.
