# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Primary users are homeowners and renters managing recurring household maintenance, HVAC systems, and deep-cleaning schedules. They need a proactive system to prevent unnoticed deterioration of living spaces and appliances without requiring cumbersome daily task entry.

## Product Purpose

Cleaning Tracker helps users maintain healthy living spaces by monitoring recurring maintenance and cleaning tasks. Success means users have clarity on what systems are healthy, degrading, or urgent at a glance, preventing chore buildup and costly neglect.

## Positioning

Unlike generic to-do checklists or cloud-dependent chore trackers, Cleaning Tracker is a private, offline-first mobile maintenance tracker with an aggregate Home Health Score, urgency degradation states, and adaptive interval suggestions based on actual completion habits.

## Operating Context

- Mobile environments (smartphones on Android and iOS).
- High-friction contexts: quick lookups while cleaning or inspecting home equipment (HVAC closets, kitchens, bathrooms).
- Offline-first operation with optional private backup to personal Google Drive.
- Periodic push notifications scheduled locally for upcoming maintenance lead times.

## Capabilities and Constraints

- **Platform & Stack:** Flutter (Dart `>=3.11.0 <4.0.0`), Material 3, SQLite (`sqflite`), local notifications (`flutter_local_notifications`).
- **Urgency Levels:** Operational (>85% health), Degrading (25%–85% health), Critical (<25% health), and Overdue (<=0% health).
- **Core Features:** Status Dashboard with aggregate Home Health Score; customizable task intervals (daily, weekly, monthly, custom days); adaptive smart interval suggestions (calculated from 3+ completions); category resets; task snooze; preset library; full completion log history.
- **Privacy & Storage:** Offline-first local database. No mandatory account creation or proprietary cloud servers. Optional manual/background sync to Google Drive via `cleaning_tracker_backup.json`.
- **Haptic & Visual Feedback:** Tactile feedback on completions; system-aware Light and Dark modes.

## Brand Commitments

- **Name:** Cleaning Tracker.
- **Voice:** Pragmatic, functional, calm, and reliable. Avoids patronizing or guilt-inducing chore copy.
- **Tone & Identity:** High clarity and contrast, purposeful utility.

## Evidence on Hand

- Fully functional Flutter codebase across `lib/` (dashboard, detail, add task, settings, log history, presets, privacy policy).
- Local SQLite database migrations and schema in `lib/database_service.dart`.
- Unit, widget, golden, and integration test suites in `test/` and `integration_test/`.
- Project documentation in `docs/` (`ARCHITECTURE.md`, `FEATURES.md`, `DATABASE.md`, `DEVELOPMENT.md`, `TESTING.md`).
- Note: No proprietary server-side backend or cloud telemetry exists.

## Product Principles

1. **Local-First & Private:** The app works completely offline without accounts or tracking; cloud sync is user-owned (personal Google Drive).
2. **Urgency at a Glance:** The Home Health Score and color-coded status states communicate what needs attention immediately without reading through long lists.
3. **Adaptive, Not Rigid:** Maintenance schedules adapt to real human habits through intelligent interval suggestions and non-destructive snooze options.
4. **Frictionless Completion:** Completing tasks, snoozing, or resetting categories requires minimal taps in physical, wet-hands environments.

## Accessibility & Inclusion

- High-contrast visual cues and readable typography (`GoogleFonts.nunito`).
- Full support for system-wide Light and Dark themes.
- Touch target sizes and tactile haptic feedback suitable for mobile operation.
