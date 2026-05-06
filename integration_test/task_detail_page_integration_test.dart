import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cleaning_tracker/main.dart' as app;
import 'package:cleaning_tracker/task_detail_page.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tap TaskCard to go to TaskDetailPage, then tap back', (
    tester,
  ) async {
    app.DashboardScreen.testingMode = true;
    app.main();
    await tester.pumpAndSettle();

    // Verify we are on Dashboard
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('NO SYSTEMS TRACKED'), findsOneWidget);

    // Tap add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Type name — the AddTaskPage has multiple TextFields (name, category,
    // interval). Target the first one explicitly.
    await tester.enterText(find.byType(TextField).first, 'HVAC FILTER');
    await tester.pumpAndSettle();

    // Initialize tracker
    await tester.tap(find.text('INITIALIZE TRACKER'));
    await tester.pumpAndSettle();

    // Verify back on Dashboard and task exists
    expect(find.text('HVAC FILTER'), findsOneWidget);

    // Find and tap the TaskCard (HVAC FILTER)
    final hvacFilterCard = find.text('HVAC FILTER');
    expect(hvacFilterCard, findsOneWidget);

    await tester.tap(hvacFilterCard);
    await tester.pumpAndSettle();

    // Verify we are on the TaskDetailPage
    expect(find.byType(TaskDetailPage), findsOneWidget);
    expect(find.text('CLEANLINESS'), findsOneWidget);

    // Tap the back button
    final backButton = find.byIcon(Icons.arrow_back);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify we are back on Dashboard
    expect(find.text('STATUS'), findsOneWidget);
  });
}
