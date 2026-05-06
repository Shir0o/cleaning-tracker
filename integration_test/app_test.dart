import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart' as app;
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end: Dashboard to Settings to Log History', (
    WidgetTester tester,
  ) async {
    app.DashboardScreen.testingMode = true;
    LogHistoryPage.testingMode = true;
    app.main();
    await tester.pumpAndSettle();

    // Verify we start on the dashboard (STATUS)
    expect(find.text('STATUS'), findsOneWidget);

    // Tap settings icon. The Icon sits inside an InkWell that absorbs the
    // pointer, so target the InkWell ancestor for a clean hit-test.
    await tester.tap(
      find.ancestor(
        of: find.byIcon(Icons.settings),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    // Verify we are on settings page
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);

    // Scroll down to find the "VIEW HISTORY" button in case it's off-screen on small mock devices
    await tester.ensureVisible(find.text('VIEW HISTORY'));
    await tester.tap(find.text('VIEW HISTORY'));
    await tester.pumpAndSettle();

    // Verify we reach the History
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);
  });
}
