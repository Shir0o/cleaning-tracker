import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/settings_page.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SettingsPage.testingMode = true;
    LogHistoryPage.testingMode = true;
    DashboardScreen.testingMode = true;
    TaskCard.testingMode = true;
    SharedPreferences.setMockInitialValues({});
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
    expect(find.text('SIGN IN TO SYNC'), findsOneWidget);
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

  testWidgets('Settings page selection dialog updates value', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify initial value
    expect(find.text('LIGHT'), findsOneWidget);

    // Tap the Interface Theme row
    await tester.tap(find.text('INTERFACE THEME'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('INTERFACE THEME'), findsWidgets);
    expect(find.text('DARK'), findsOneWidget);

    // Tap DARK option
    await tester.tap(find.text('DARK'));
    await tester.pumpAndSettle();

    // Verify dialog is closed and value is updated
    expect(find.text('DARK'), findsOneWidget);
  });

  testWidgets('Settings page shows all notify before options', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Tap the Notify before expiry row
    await tester.tap(find.text('NOTIFY BEFORE EXPIRY'));
    await tester.pumpAndSettle();

    // Verify dialog title is shown
    expect(find.text('NOTIFY BEFORE'), findsWidgets);

    // Verify all options are present
    final options = [
      'SAME DAY',
      '1 DAY',
      '2 DAYS',
      '3 DAYS',
      '4 DAYS',
      '5 DAYS',
      '1 WEEK',
      '2 WEEKS',
    ];

    for (final option in options) {
      if (option == '2 DAYS') {
        expect(find.text(option), findsWidgets); // Found in list and on background page
      } else {
        expect(find.text(option), findsOneWidget);
      }
    }
  });
}
