# Release Notes - v1.1.2

## [1.1.2] - 2026-04-02

### Added
- **Adaptive Intervals (Smart Suggestions):** The app now analyzes your task history and suggests optimal cleaning intervals based on your actual performance.
- **Smart Unit Tests:** New test suite for validating interval calculation logic.

## [1.1.1] - 2026-04-02

### Added
- **Restore from Backup:** Seamlessly restore your tasks, completion history, and settings from Google Drive.
- **Data Persistence:** Added `deleteAllTasks` to `DatabaseService` for clean state restoration.

### Improved
- **Settings UI:** Added a dedicated "Restore from Backup" action in the Data & Sync section.
- **Documentation:** Comprehensive new documentation suite in the `docs/` directory covering Architecture, Features, Testing, and more.

## [1.1.0] - 2026-03-29

### Added
- **Home Health Score:** An overall cleanliness percentage at the top of the dashboard.
- **Priority Actions:** Automatic sorting that highlights tasks requiring immediate attention (Health < 25%).
- **Batch Category Reset:** Mark all tasks in a category as completed with a single tap.
- **Task Snooze:** Delay tasks for 1 day, 3 days, 1 week, or 2 weeks without affecting history.
- **Privacy Policy:** Integrated legal documentation in the Settings page for store compliance.
- **Haptic Feedback:** Physical confirmation when completing tasks for a more tactile experience.

### Fixed
- **Notification Data Source:** Migrated `NotificationService` from `SharedPreferences` to SQLite to ensure alerts work correctly after the database migration.
- **Database Architecture:** Optimized task queries and implemented a robust v2 schema migration.
- **Test Stability:** Fixed global test failures by implementing a clean testing mode for the database.

---
*Note: This version marks the first major feature update for the Cleaning Tracker project.*
