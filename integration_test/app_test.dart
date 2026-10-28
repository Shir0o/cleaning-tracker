import 'package:cleaning_tracker/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart' as app;
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/settings_tab.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end: Dashboard to Settings to Log History', (
    WidgetTester tester,
  ) async {
    app.DashboardScreen.testingMode = true;
    LogHistoryPage.testingMode = true;
    await DatabaseService().deleteAllTasks();
    app.main();
    await tester.pumpAndSettle();

    // Verify we start on the dashboard
    expect(find.text('Due'), findsWidgets);

    // Open the Settings tab.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify we are on the Settings tab
    expect(find.text('Remind me about'), findsOneWidget);

    // Scroll down to find "Cleaning history" in case it's off-screen on small mock devices
    await tester.scrollUntilVisible(
      find.text('Cleaning history'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsTab),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Cleaning history'));
    await tester.pumpAndSettle();

    // Verify we reach the History
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);

    // Pop LogHistoryPage back to the Settings tab
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Return to the Due tab
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    // Verify back on Dashboard
    expect(find.text('Due'), findsWidgets);
  });
}
