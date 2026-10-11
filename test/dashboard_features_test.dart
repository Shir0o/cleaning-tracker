import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/database_service.dart';

void main() {
  setUp(() {
    DashboardScreen.testingMode = true;
    DatabaseService.testingMode = true;
    DatabaseService.mockTasks = [];
  });

  tearDown(() {
    DatabaseService.mockTasks = null;
  });

  testWidgets('Dashboard shows overall health score and priority actions', (
    WidgetTester tester,
  ) async {
    // We can't easily mock the DatabaseService.getTasks return value without changing its architecture
    // or using a library like get_it. For this test, we will verify the UI elements exist.

    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    // Verify "HOME HEALTH" text exists
    expect(find.text('HOME HEALTH'), findsOneWidget);

    // Since DatabaseService returns [] in testing mode, overall health should be 100% (default for empty)
    expect(find.text('100%'), findsOneWidget);

    // Verify "NO SYSTEMS TRACKED" since tasks are empty
    expect(find.text('NO SYSTEMS TRACKED'), findsOneWidget);
  });

  testWidgets('Add preset stays open for batch adding and shows checkmark when added', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    // Tap the floating '+' add task button
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsWidgets);
    await tester.tap(addButton.first);
    await tester.pumpAndSettle();

    // Verify Add overlay is open
    expect(find.text('Add a task'), findsOneWidget);

    // Initial state: presets show '+' icon
    expect(find.text('WASH DISHES'), findsOneWidget);

    // Tap to add WASH DISHES
    await tester.tap(find.text('WASH DISHES'));
    await tester.pumpAndSettle();

    // Verify overlay stays open (does not return to home)
    expect(find.text('Add a task'), findsOneWidget);

    // Verify checkmark appears for added task
    expect(find.byIcon(Icons.check), findsAtLeastNWidgets(1));

    // Can add another task without leaving (WIPE COUNTERS & SINK)
    expect(find.text('WIPE COUNTERS & SINK'), findsOneWidget);
    await tester.tap(find.text('WIPE COUNTERS & SINK'));
    await tester.pumpAndSettle();

    // Still on Add a task overlay with both tasks showing checkmark
    expect(find.text('Add a task'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsAtLeastNWidgets(2));
  });

  testWidgets('Switching tab from bottom nav dismisses the add overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    // Open Add overlay
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton.first);
    await tester.pumpAndSettle();
    expect(find.text('Add a task'), findsOneWidget);

    // Tap Rooms tab in bottom navigation
    await tester.tap(find.text('Rooms'));
    await tester.pumpAndSettle();

    // Add overlay should be dismissed and Rooms tab content visible
    expect(find.text('Add a task'), findsNothing);
    // 'Rooms' appears in both the header and bottom nav item
    expect(find.text('Rooms'), findsNWidgets(2));
  });
}

