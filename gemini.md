# Prompt Context for Gemini

When working on this project (`cleaning-tracker`), please follow these guidelines:

## Development Approach
- **Test-Driven Design (TDD)**: Whenever adding a new feature, modifying existing logic, or fixing a bug, employ a Test-Driven Development workflow.
  1. Write a failing test for the new functionality or fix.
  2. Implement the minimal amount of code required to make the test pass.
  3. Refactor the code while ensuring tests remain green.

## Code Quality
- Ensure new code is accompanied by corresponding unit, widget, golden, scenario, and integration tests in the `test/` or `integration_test/` directory.
- Verify tests pass using `flutter test` and the code aligns with rules in `flutter analyze`.

## Git Guidelines
- **Modularity**: Break up commits into logical, modular units. Avoid monolithic commits that combine unrelated changes or features.

## Repository Maintenance
- **Cleanup**: Proactively clean up temporary files, test artifacts (e.g., `test/failures/`), and other generated files that do not need to be pushed.
- **Gitignore**: Monitor for files that should not be tracked by the repository. If unsure, ask the user before adding them to `.gitignore`.
