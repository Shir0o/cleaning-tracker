# Database Schema

The Cleaning Tracker uses a local SQLite database for efficient task management and history tracking.

## 1. Tables

### `tasks`
The primary table for all trackable systems.
| Column | Type | Description |
| --- | --- | --- |
| `id` | `INTEGER` | Primary key, autoincremented. |
| `title` | `TEXT` | Name of the task or system. |
| `interval` | `TEXT` | Frequency string (e.g., '2 WEEKS'). |
| `lastCompleted` | `TEXT` | ISO 8601 timestamp of the last completion. |
| `category` | `TEXT` | String identifier for grouping. |
| `notes` | `TEXT` | Optional additional details. |
| `snoozedUntil` | `TEXT` | ISO 8601 timestamp of the snooze end date. |

### `completions`
Records the full history of each task.
| Column | Type | Description |
| --- | --- | --- |
| `id` | `INTEGER` | Primary key, autoincremented. |
| `task_id` | `INTEGER` | Foreign key referencing `tasks.id`. |
| `date` | `TEXT` | ISO 8601 timestamp of the completion date. |

- **Constraint:** `ON DELETE CASCADE` is used for `task_id` to ensure completion history is removed when a task is deleted.

## 2. Migrations

The database is versioned to support seamless app updates.
- **v1:** Initial schema (`tasks` without `snoozedUntil`).
- **v2:** Added `snoozedUntil` column to the `tasks` table.

### Data Migration from SharedPreferences
A one-time migration process is implemented in `DatabaseService` to transition legacy data from `SharedPreferences` (where it was stored as a list of JSON strings) into the SQLite tables.
- **Flag:** `migration_complete` (bool) in `SharedPreferences`.

## 3. Data Integrity
- **ISO 8601:** All dates are stored as UTF-8 strings in ISO 8601 format for easy parsing and sorting.
- **Testing Mode:** `DatabaseService.testingMode` allows developers to run tests without creating actual database files, preventing file-system side effects during unit testing.
