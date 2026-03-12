import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/settings_page.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SettingsPage.testingMode = true;
    LogHistoryPage.testingMode = true;
    DashboardScreen.testingMode = true;
    TaskCard.testingMode = true;
  });

  testWidgets('SettingsPage renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify headers and sections exist
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);
    expect(
      find.text('01. Notification Preferences'.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('02. Global Preferences'.toUpperCase()), findsOneWidget);
    expect(find.text('03. Data & Sync'.toUpperCase()), findsOneWidget);
    expect(find.text('04. History'.toUpperCase()), findsOneWidget);

    // Verify key elements exist
    expect(find.text('Notify before expiry'.toUpperCase()), findsOneWidget);
    expect(find.text('Daily reminder'.toUpperCase()), findsOneWidget);
    expect(find.text('Interface Theme'.toUpperCase()), findsOneWidget);
    expect(find.text('Start of Week'.toUpperCase()), findsOneWidget);
    expect(find.text('Sync with Google Drive'.toUpperCase()), findsOneWidget);
    expect(find.text('FORCE BACKUP NOW'), findsOneWidget);
    expect(find.text('VIEW ALL LOGS'), findsOneWidget);
  });

  testWidgets('Dashboard settings icon navigates to SettingsPage', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CleaningTrackerApp());

    // Verify Settings icon is present
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Tap the settings icon
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify we are on the Settings Page
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);
  });

  testWidgets('Settings page "VIEW ALL LOGS" navigates to LogHistoryPage', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify the view all logs button is present
    expect(find.text('VIEW ALL LOGS'), findsOneWidget);

    // Tap the view all logs button
    await tester.ensureVisible(find.text('VIEW ALL LOGS'));
    await tester.tap(find.text('VIEW ALL LOGS'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify we are on the Log History Page
    expect(find.text('ARCHIVE'), findsOneWidget);
  });
}
