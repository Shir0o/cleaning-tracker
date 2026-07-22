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

    // Tap add button (center nav bar FAB)
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    // Tap 'WASH DISHES' preset card in Add Task overlay
    await tester.tap(find.text('WASH DISHES'));
    await tester.pumpAndSettle();

    // Verify preset task (WASH DISHES) exists on Dashboard
    expect(find.text('WASH DISHES'), findsOneWidget);

    // Find and tap the TaskCard (WASH DISHES)
    await tester.tap(find.text('WASH DISHES'));
    await tester.pumpAndSettle();

    // Verify we are on the Task Detail view
    expect(find.text('MARK AS DONE'), findsOneWidget);

    // Tap the back button to close Task Detail view
    final backButton = find.byIcon(Icons.arrow_back);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify back on Dashboard
    expect(find.text('Due'), findsWidgets);
  });
}
