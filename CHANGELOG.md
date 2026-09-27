# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0](https://github.com/Shir0o/cleaning-tracker/compare/v1.1.3...v1.2.0) (2026-09-27)


### Features

* add category to tasks and group dashboard by category ([aacbfd3](https://github.com/Shir0o/cleaning-tracker/commit/aacbfd33527ea5ac7a3c8b3296f651af6cad6b34))
* Add custom interval option to AddTaskPage ([0266fd8](https://github.com/Shir0o/cleaning-tracker/commit/0266fd81d6a8c6e98f265585a5ca9679b55ffa90))
* add in-app notification toggle and clean up settings UI ([6d4eff3](https://github.com/Shir0o/cleaning-tracker/commit/6d4eff33cdf0af00d2d5078417b70f2ff509ec8b))
* add presets page and hook it up to new system page ([a6b7b67](https://github.com/Shir0o/cleaning-tracker/commit/a6b7b67fac6407849ca5cacf84ab7ab61ec3d5cc))
* Add Presets Page and integrate with Add Task Flow ([9d713b3](https://github.com/Shir0o/cleaning-tracker/commit/9d713b348372309162cbffcbfd2b33406b331e62))
* Add Settings Page UI and Google Drive / Permissions logic ([39ab2b5](https://github.com/Shir0o/cleaning-tracker/commit/39ab2b57152f52a4cf54dc9ec6547a6d64cf2005))
* add test notification button in settings ([9b2d6c7](https://github.com/Shir0o/cleaning-tracker/commit/9b2d6c75b3c2e84c5df32b6b58c54ddd9d2199d0))
* Add Unified Log History Screen with comprehensive TDD test suites ([0af5398](https://github.com/Shir0o/cleaning-tracker/commit/0af53983c455145ba5f2aa555b6491a27b29d476))
* **config:** load GOOGLE_SERVER_CLIENT_ID from .env at runtime ([#25](https://github.com/Shir0o/cleaning-tracker/issues/25)) ([b7acfc0](https://github.com/Shir0o/cleaning-tracker/commit/b7acfc0a093ef8c0a08b4bbaf5cea564bfdd01e5))
* display cleanliness in red when it reaches 0% or below ([00285e5](https://github.com/Shir0o/cleaning-tracker/commit/00285e598c06e50e5b426864f7743527df56fdf5))
* enhance status and due date fields with system integrity theme ([43038b8](https://github.com/Shir0o/cleaning-tracker/commit/43038b8a1fb609179b07bd0a8eca87faa0b79067))
* implement Adaptive Intervals (Smart Suggestions) (v1.1.2) ([d3aafff](https://github.com/Shir0o/cleaning-tracker/commit/d3aaffffc5ebaef68d147f2bfd163f41285886e6))
* implement app redesign and backfill CHANGELOG.md ([#41](https://github.com/Shir0o/cleaning-tracker/issues/41)) ([2860db4](https://github.com/Shir0o/cleaning-tracker/commit/2860db448eddb4dba3382681a2fc454c28efb47b))
* implement DriveService with background silent sign-in and lifecycle-triggered sync ([bd6c062](https://github.com/Shir0o/cleaning-tracker/commit/bd6c062b1a85664df44293f30aec75697efc6760))
* implement Google Drive backup on exit and improve preset interval handling ([d847726](https://github.com/Shir0o/cleaning-tracker/commit/d84772658106a4c8390484afb74862893e259197))
* implement local notification system ([770f24c](https://github.com/Shir0o/cleaning-tracker/commit/770f24cb5c8645dcd0fa08a9be1d05ccaddeac95))
* implement Restore from Backup functionality (v1.1.1) ([6e231e6](https://github.com/Shir0o/cleaning-tracker/commit/6e231e6369d8767176c3580495cf50a3e45fb5f3))
* implement silent Google Sign-In on home page and startup ([29faba1](https://github.com/Shir0o/cleaning-tracker/commit/29faba16e71c19600d5e4e326ab6aa6f99aacf83))
* implement task completion history and archive view ([40ebfa7](https://github.com/Shir0o/cleaning-tracker/commit/40ebfa797fde271b35b45ebe57638229ec942296))
* implement Task Detail Page and fix font loading issues in tests ([090bde6](https://github.com/Shir0o/cleaning-tracker/commit/090bde6514be85d7569826687a8c1f984e6f21be))
* Implement toggleable dark theme mode ([8a90dc8](https://github.com/Shir0o/cleaning-tracker/commit/8a90dc8f390b9219364b6988d6174d76c39b16bb))
* Implement toggleable dark theme mode ([1f3e6cc](https://github.com/Shir0o/cleaning-tracker/commit/1f3e6cc37cd2ebfa530e3f90b04e7c30fe2d52f7))
* implement truly silent background Google Sign-In on home page ([d22bd96](https://github.com/Shir0o/cleaning-tracker/commit/d22bd967afc56d5aaaf9b924bff6f7bfd6052d1d))
* implement V1 release features including dashboard health score, urgent task sorting, batch category reset, task snooze, and privacy policy ([071b247](https://github.com/Shir0o/cleaning-tracker/commit/071b247399ecf01ebd47b1d3c449198761dd0823))
* make system detail page fully functional with dynamic tracking and editing ([8378e82](https://github.com/Shir0o/cleaning-tracker/commit/8378e82f010a48a5d10186eedde993aa9fa8e678))
* make system permission notification button functional ([bd57400](https://github.com/Shir0o/cleaning-tracker/commit/bd57400425a4763cf92556e0126b09c647c2c7ff))
* migrate data storage from SharedPreferences to sqflite ([11eac6e](https://github.com/Shir0o/cleaning-tracker/commit/11eac6e6738b74198d94ae06352338ffd0d3c783))
* remove all preset items and start with empty state ([706dd60](https://github.com/Shir0o/cleaning-tracker/commit/706dd60f2d7db52b8f2a30183f7f2337c1283495))
* remove system permission row and auto-request permission on toggle ([5fc47ef](https://github.com/Shir0o/cleaning-tracker/commit/5fc47ef79d8dfb57ed9c296f31de7c2c892d1a44))
* remove test notification button and clean up unused code ([0fc93fc](https://github.com/Shir0o/cleaning-tracker/commit/0fc93fc4be6bb10396d21b34d7e6c2915bc0c2de))
* replace circle loaders with skeleton loaders and min animation timer ([6f5d5c4](https://github.com/Shir0o/cleaning-tracker/commit/6f5d5c4fae77f674d3c70b07aa32bc329d842576))
* replace existing presets with comprehensive home cleaning list categorized by section ([04a39dd](https://github.com/Shir0o/cleaning-tracker/commit/04a39dd643b0cd328b9480334c51e5c5d9d2f2af))
* restore silent background Google Sign-In ([b73e588](https://github.com/Shir0o/cleaning-tracker/commit/b73e5889ad204ff1dc349219f05e5f1b234b32dc))
* rethink task tracking with continuous health and draining progress bars ([8e69b29](https://github.com/Shir0o/cleaning-tracker/commit/8e69b29470711ee0636d22efc61ad381936a7b80))
* update app launcher icons using flutter_launcher_icons ([c41cf24](https://github.com/Shir0o/cleaning-tracker/commit/c41cf246ba0855c44f2a4cfaafb75da7a281c385))
* update unique Application ID to com.cleaningtracker.app ([6ce00a5](https://github.com/Shir0o/cleaning-tracker/commit/6ce00a55d7b551c76fa8c1c822751b5b56d0c97c))


### Bug Fixes

* CI build errors related to missing secrets.dart ([3691602](https://github.com/Shir0o/cleaning-tracker/commit/3691602bce52b11c5a59e6ecabf58bb8aa977ca6))
* ensure Google Drive sign-in status and sync preference are retained across app restarts ([e4d00d0](https://github.com/Shir0o/cleaning-tracker/commit/e4d00d0b54b23c3e026116e465a0c390b8269b69))
* **integration tests:** make all_tests.dart green, re-enable as blocking check ([#22](https://github.com/Shir0o/cleaning-tracker/issues/22)) ([e688aed](https://github.com/Shir0o/cleaning-tracker/commit/e688aedce15c03a6f250f47fe0fd2c10c5a8e093))
* migrate to modern kotlin gradle plugin and resolve missing env asset error ([#33](https://github.com/Shir0o/cleaning-tracker/issues/33)) ([540d35c](https://github.com/Shir0o/cleaning-tracker/commit/540d35ca7efe66e5f330ea3046454ab0fd0a19b1))
* **notifications:** declare scheduled-notification receivers in AndroidManifest ([#45](https://github.com/Shir0o/cleaning-tracker/issues/45)) ([3125f23](https://github.com/Shir0o/cleaning-tracker/commit/3125f23aa673668a0386ec3dfbd34b5d5b22198e))
* **notifications:** icon silhouette, boot survival, cold-start re-arm, overdue handling ([#24](https://github.com/Shir0o/cleaning-tracker/issues/24)) ([55ce7b3](https://github.com/Shir0o/cleaning-tracker/commit/55ce7b354b36bbba9848fb33d54a00feb27ba438))
* **notifications:** request permissions, fix scheduling, add diagnostics ([#19](https://github.com/Shir0o/cleaning-tracker/issues/19)) ([9eeabf9](https://github.com/Shir0o/cleaning-tracker/commit/9eeabf9dbb97b1e938c6ffebcc7944c2d7aec35f))
* resolve golden test failures and preserve styles in tests ([aef2501](https://github.com/Shir0o/cleaning-tracker/commit/aef250111573c11ccb409a457308ca13a523a864))
* resolve Google Drive sync authentication and data export issues ([97267ae](https://github.com/Shir0o/cleaning-tracker/commit/97267ae52674a08975cfaddb1a92545ad65e51c7))
* resolve horizontal pixel overflow in TaskCard ([a685d3f](https://github.com/Shir0o/cleaning-tracker/commit/a685d3fc822f77cc81b20d1050fdefd91f39bb46))
* restore Google Sign-In configuration after merge conflict ([8ab7e12](https://github.com/Shir0o/cleaning-tracker/commit/8ab7e12f7e4e851ab5b25eb0726b31a3d3624fcd))
* restore googleServerClientId from secrets.dart to fix sign-in ([fa24ff8](https://github.com/Shir0o/cleaning-tracker/commit/fa24ff8f1d048077ced59d606f63b67a001aba44))
* update golden test paths and implement TolerantGoldenFileComparator for CI stability ([a4d35bf](https://github.com/Shir0o/cleaning-tracker/commit/a4d35bf16e3f92d6e454778ee108db976c383923))
* update golden tests to account for minor pixel differences ([95caeeb](https://github.com/Shir0o/cleaning-tracker/commit/95caeebdeeca24d6d5bee750b7bd44177d1ece45))
* use Ahem font for golden tests to ensure cross-platform consistency ([5a2d6bb](https://github.com/Shir0o/cleaning-tracker/commit/5a2d6bb922cb22ecb763b932211791dd241965f8))
* use fallback google client id to fix CI builds ([32fcd99](https://github.com/Shir0o/cleaning-tracker/commit/32fcd99d4668f0eb4f832052512c490061af25ba))


### Refactoring

* replace quick specs with notes field in TaskDetail ([9d282e6](https://github.com/Shir0o/cleaning-tracker/commit/9d282e6953542c1af34b692ae89003efc76ee5cb))

## [Unreleased]

### Added
- **Release Automation:** Configured `release-please` for automated versioning and changelog management, GitHub Actions workflows for PR title linting and building signed release APK/AAB artifacts on tag push, Fastlane Play Console internal testing track upload, conditional release keystore signing in Gradle, and `RELEASING.md` documentation.
- **App Redesign:** Full redesign of the app matching specification in `Cleaning task tracker app.zip` (`Cleaning Tracker.dc.html`), featuring Nunito typography, Sage Green & Organic Clay color palette (`#3a7d5c`, `#e9efe5` / `#12140f`), room-specific color themes (Kitchen, Bathroom, Bedroom, Living room, Laundry), 4-tab bottom navigation (`Due`, `Rooms`, `Stats`, `More`), circular cleanliness score ring gauge, quick snooze options (+1d, +3d, +1w), and interactive overlays for task creation and details.
- **Runtime Configuration:** Load `GOOGLE_SERVER_CLIENT_ID` dynamically from `.env` at runtime.

### Fixed
- **Build System:** Migrated to modern Kotlin Gradle plugin and fixed missing `.env` asset error.
- **Dependencies:** Resolved open Dependabot security and maintenance dependency updates.
- **Notification Reliability:** Fixed notification icon silhouettes, boot survival re-arm, cold-start initialization, and overdue task notification handling.
- **Notification Delivery:** Declared the `flutter_local_notifications` scheduled-notification and boot receivers in the Android manifest. The plugin ships no receivers of its own; without them Android silently drops the scheduled-reminder alarm broadcast, so reminders only ever appeared via the immediate-fire fallback when the app was opened.

### Added
- **Test Coverage:** Added 54 new unit tests covering `Task` model edge cases (interval parsing, snoozed branches, JSON round-trip, suggested interval thresholds), `DatabaseService` (`getTasks`, `deleteTask`, `addCompletion`, `deleteAllTasks`, `migrateFromSharedPreferences`), `DriveService` (sync early-return, create-new branch, payload key filtering, backup timestamp, restore error paths), and `NotificationService` (notifyBefore parsing variants, cancel id fallback, uninitialized rescheduleAll, test notification, exact-alarm retry, PlatformException rethrow).

## [1.1.3] - 2026-05-07

### Fixed
- **Notification Permissions:** Request notification permissions before scheduling reminders.
- **Notification Scheduling:** Improved reminder scheduling reliability and diagnostics.

### Added
- **Open Source Readiness:** Added license, security, contribution, and development documentation.

### Changed
- **Application ID:** Updated the Android application ID to `com.cleaningtracker.app`.
- **Launcher Icons:** Refreshed generated app launcher icons.
- **Drive Restore Performance:** Optimized backup restore inserts with batched database writes.

## [1.1.2] - 2026-04-02

### Added
- **Adaptive Intervals (Smart Suggestions):** Analyzes task history to suggest optimal cleaning intervals based on actual performance.
- **Smart Unit Tests:** New test suite for validating interval calculation logic.

## [1.1.1] - 2026-04-02

### Added
- **Restore from Backup:** Seamlessly restore tasks, completion history, and settings from Google Drive.
- **Data Persistence:** Added `deleteAllTasks` to `DatabaseService` for clean state restoration.

### Improved
- **Settings UI:** Added a dedicated "Restore from Backup" action in the Data & Sync section.
- **Documentation:** Added comprehensive project documentation suite in `docs/`.

## [1.1.0] - 2026-03-29

### Added
- **Home Health Score:** Cleanliness percentage metric on the main dashboard.
- **Priority Actions:** Automatic sorting to highlight urgent tasks requiring immediate attention.
- **Batch Category Reset:** Mark all tasks in a category as completed with a single tap.
- **Task Snooze:** Delay tasks for 1 day, 3 days, 1 week, or 2 weeks without affecting history.
- **Privacy Policy:** Integrated legal documentation page in Settings.
- **Haptic Feedback:** Physical tactile confirmation upon completing tasks.

### Fixed
- **Notification Data Source:** Migrated `NotificationService` from `SharedPreferences` to SQLite.
- **Database Architecture:** Optimized task queries and implemented v2 schema migration.
- **Test Stability:** Fixed global test failures by implementing clean test mode in database service.
