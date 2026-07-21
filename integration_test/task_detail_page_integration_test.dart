import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cleaning_tracker/main.dart' as app;
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
    expect(find.text('Due'), findsWidgets);

    // Tap add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Tap Create Custom Task button
    await tester.tap(find.text('Create Custom Task'));
    await tester.pumpAndSettle();

    // Type name in custom task name field
    await tester.enterText(find.byType(TextField), 'HVAC FILTER');
    await tester.pumpAndSettle();

    // Save task
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle();

    // Verify back on Dashboard and task exists
    expect(find.text('HVAC FILTER'), findsOneWidget);

    // Find and tap the TaskCard (HVAC FILTER)
    final hvacFilterCard = find.text('HVAC FILTER');
    expect(hvacFilterCard, findsOneWidget);

    await tester.tap(hvacFilterCard);
    await tester.pumpAndSettle();

    // Verify we are on the Task Detail view
    expect(find.text('MARK AS DONE'), findsOneWidget);

    // Tap the back button
    final backButton = find.byIcon(Icons.arrow_back);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify we are back on Dashboard
    expect(find.text('Due'), findsWidgets);
  });
}
