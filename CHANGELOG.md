# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **App Redesign:** Full redesign of the app matching specification in `Cleaning task tracker app.zip` (`Cleaning Tracker.dc.html`), featuring Nunito typography, Sage Green & Organic Clay color palette (`#3a7d5c`, `#e9efe5` / `#12140f`), room-specific color themes (Kitchen, Bathroom, Bedroom, Living room, Laundry), 4-tab bottom navigation (`Due`, `Rooms`, `Stats`, `More`), circular cleanliness score ring gauge, quick snooze options (+1d, +3d, +1w), and interactive overlays for task creation and details.
- **Runtime Configuration:** Load `GOOGLE_SERVER_CLIENT_ID` dynamically from `.env` at runtime.

### Fixed
- **Build System:** Migrated to modern Kotlin Gradle plugin and fixed missing `.env` asset error.
- **Dependencies:** Resolved open Dependabot security and maintenance dependency updates.
- **Notification Reliability:** Fixed notification icon silhouettes, boot survival re-arm, cold-start initialization, and overdue task notification handling.

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
