# Architecture Overview

This document describes the high-level architecture of the Cleaning Tracker application.

## Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Database:** [SQLite](https://pub.dev/packages/sqflite) via `sqflite`
- **Local Storage:** [SharedPreferences](https://pub.dev/packages/shared_preferences) (for settings and flags)
- **Cloud Backup:** [Google Drive API](https://developers.google.com/drive) via `googleapis`
- **Notifications:** [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Design System:** Custom neobrutalist aesthetic with high-contrast colors, bold borders, and simple geometric surfaces.

## Core Services

### 1. DatabaseService (`lib/database_service.dart`)
Handles all local persistence using SQLite. 
- Manages `tasks` and `completions` tables.
- Includes logic for migrating legacy data from `SharedPreferences`.
- Provides a `testingMode` to prevent file I/O during unit tests.

### 2. NotificationService (`lib/notification_service.dart`)
Manages local reminders.
- Schedules notifications based on task due dates.
- Parses user preferences for "Notify Before" and "Reminder Time".
- Uses `timezone` package to handle local time accurately.

### 3. DriveService (`lib/drive_service.dart`)
Handles cloud synchronization and backup.
- Integrates with Google Sign-In for authentication.
- Backs up the entire app state (settings + database) as a single JSON file on Google Drive.
- Triggers background sync when the app lifecycle state changes to `paused`.

## Data Flow
1. **User Interaction:** User completes a task on the UI.
2. **Persistence:** `DatabaseService` records the completion and updates the task's `lastCompleted` timestamp.
3. **Local Sync:** `NotificationService` is called to reschedule reminders for that task.
4. **Cloud Sync:** When the app is backgrounded, `DriveService` packages the database and settings into a JSON backup and uploads it to Google Drive.

## UI/UX Pattern
The app follows a standard Flutter `StatefulWidget` pattern for most screens. 
- **Theming:** A global `ValueNotifier<ThemeMode>` is used to switch between Light, Dark, and System themes.
- **Navigation:** Standard Navigator 1.0.
