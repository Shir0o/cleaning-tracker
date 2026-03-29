# Release Notes - v1.1.0

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
