# Features

The Cleaning Tracker app provides a set of tools to monitor and manage household systems and cleaning tasks efficiently.

## 1. Status Dashboard
The main screen provides an overview of all tracked "systems."
- **Home Health Score:** A percentage at the top representing the overall cleanliness of all systems.
- **Priority Actions:** Tasks with <25% health are automatically promoted to the top for immediate visibility.
- **Category Grouping:** Tasks are grouped into logical categories (e.g., HVAC, BEDROOM, KITCHEN).
- **Neobrutalist UI:** Clean, bold typography and high-contrast borders for accessibility and style.

## 2. Task Tracking
Detailed tracking for individual cleaning and maintenance tasks.
- **Custom Intervals:** Support for Daily, Weekly, Monthly, and custom day intervals.
- **Adaptive Intervals (Smart Suggestions):** The app analyzes your completion history. If you consistently complete a task faster or slower than scheduled (based on at least 3 completions), it will suggest a "Smart Suggestion" to adjust the interval to match your actual habits.
- **Task Health & Status:** Each task is color-coded based on its urgency:
  - **OPERATIONAL:** >85% health.
  - **DEGRADING:** 25% to 85% health.
  - **CRITICAL:** <25% health.
  - **OVERDUE:** 0% or negative health.
- **History Logging:** A complete history of completions for each task is recorded in the `completions` table.

## 3. Smart Actions
- **Category Reset:** A one-tap action to mark all tasks in a category as completed.
- **Task Snooze:** Allows users to delay a task (for 1 day, 3 days, 1 week, or 2 weeks) without affecting the permanent completion history.
- **Presets:** Quick-start templates for common household tasks.

## 4. Notifications & Reminders
- **Customizable Alerts:** Users can choose how far in advance they want to be notified (e.g., 2 days before).
- **Daily Reminder Time:** Specify a preferred time for alerts to trigger (e.g., 9:00 AM).
- **Auto-Update:** Reminders are automatically rescheduled whenever a task is completed or modified.

## 5. Cloud Sync & Backup
- **Google Drive Integration:** Securely back up local data to a private JSON file (`cleaning_tracker_backup.json`) on the user's personal Google Drive.
- **Silent Sign-In:** Seamlessly reconnects to the user's account for ongoing synchronization.
- **Background Sync:** Automatically uploads a backup whenever the app is backgrounded.
- **Data Restoration:** Easily restore your entire app state (tasks, history, and settings) from Google Drive when moving to a new device.

## 6. Personalization
- **Theme Modes:** Light and Dark modes with full system support.
- **Haptic Feedback:** Physical tactile response for task completions and significant UI actions.
- **Privacy Policy:** Integrated legal compliance for store distribution.
