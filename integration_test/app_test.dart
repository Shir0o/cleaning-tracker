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

    // Tap settings icon
    await tester.tap(
      find.byType(Icon).first,
    ); // Settings icon is the first action icon usually, let's target by it or tooltip. The app doesn't have an IconData strictly addressable here by text. Let's find something more direct.
    // Wait for that to fail if it isn't specifically Icons.settings, we know Dashboard has settings icon setup.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify we are on settings page
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);

    // Scroll down to find the "VIEW ALL LOGS" button in case it's off-screen on small mock devices
    await tester.ensureVisible(find.text('VIEW ALL LOGS'));
    await tester.tap(find.text('VIEW ALL LOGS'));
    await tester.pumpAndSettle();

    // Verify we reach the Archive
    expect(find.text('ARCHIVE'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
  });
}
