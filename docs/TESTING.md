# Testing Strategy

This project mandates a **Test-Driven Design (TDD)** approach for all new features and bug fixes. No change is considered complete without accompanying verification logic.

## 1. Test Categories

### Unit Tests
- **Location:** `test/`
- **Scope:** Individual classes and logic (e.g., `Task` health calculations, `DriveService` JSON serialization).
- **Tools:** `dart:test`, `mockito`, `mocktail`.

### Widget Tests
- **Location:** `test/`
- **Scope:** UI component behavior and interaction (e.g., `AddTaskPage` form validation, button taps).
- **Tools:** `flutter_test`.

### Golden Tests
- **Location:** `test/goldens/`
- **Scope:** Visual regression testing.
- **Tools:** `golden_toolkit`.
- **Mandate:** Always verify UI changes against standard device configurations to prevent accidental visual regressions.

### Scenario Tests
- **Location:** `test/`
- **Scope:** Full feature workflows in a controlled environment (e.g., adding a task and then verifying it appears on the dashboard).
- **Tools:** `flutter_test`.

### Integration Tests
- **Location:** `integration_test/`
- **Scope:** Real-world usage scenarios on physical devices or emulators, exercising the full database and service stack.

## 2. Running Tests
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/task_detail_page_test.dart

# Update goldens
flutter test --update-goldens
```

## 3. TDD Workflow
1. **Identify Requirement:** Determine the new behavior or fix needed.
2. **Write Failing Test:** Create a test case that reproduces the issue or validates the new feature.
3. **Execute:** Run the test to confirm it fails.
4. **Implement:** Write the minimal code needed to pass the test.
5. **Verify:** Run the test again to ensure it passes.
6. **Refactor:** Clean up the code while maintaining a "green" (passing) status.

## 4. Continuous Integration (CI)
The project uses GitHub Actions for automated testing.
- **Workflow:** `.github/workflows/pr_build.yml`
- **Triggers:** Every Pull Request and push to `main`.
- **Actions:** Runs `flutter analyze` and `flutter test`.
