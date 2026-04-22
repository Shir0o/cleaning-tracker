import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/settings_page.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SettingsPage.testingMode = true;
    LogHistoryPage.testingMode = true;
    PrivacyPolicyPage.testingMode = true;
    DashboardScreen.testingMode = true;
    TaskCard.testingMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsPage renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify headers and sections exist
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);
    expect(find.text('Notification Preferences'.toUpperCase()), findsOneWidget);
    expect(find.text('Global Preferences'.toUpperCase()), findsOneWidget);
    expect(find.text('Data & Sync'.toUpperCase()), findsOneWidget);
    expect(find.text('History'.toUpperCase()), findsOneWidget);

    // Verify key elements exist
    expect(find.text('Enable Notifications'.toUpperCase()), findsOneWidget);
    expect(find.text('Notify before expiry'.toUpperCase()), findsOneWidget);
    expect(find.text('Daily reminder'.toUpperCase()), findsOneWidget);
    expect(find.text('Interface Theme'.toUpperCase()), findsOneWidget);
    expect(find.text('Start of Week'.toUpperCase()), findsOneWidget);
    expect(find.text('Sync with Google Drive'.toUpperCase()), findsOneWidget);
    expect(find.text('SIGN IN TO SYNC'), findsOneWidget);
    expect(find.text('VIEW HISTORY'), findsOneWidget);
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

  testWidgets('Settings page "VIEW HISTORY" navigates to LogHistoryPage', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify the view history button is present
    expect(find.text('VIEW HISTORY'), findsOneWidget);

    // Tap the view history button
    await tester.ensureVisible(find.text('VIEW HISTORY'));
    await tester.tap(find.text('VIEW HISTORY'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify we are on the Log History Page
    expect(find.text('HISTORY'), findsOneWidget);
  });

  testWidgets('Settings page "PRIVACY POLICY" navigates to PrivacyPolicyPage', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    // Verify the privacy policy button is present
    expect(find.text('PRIVACY POLICY'), findsOneWidget);

    // Tap the privacy policy button
    await tester.ensureVisible(find.text('PRIVACY POLICY'));
    await tester.tap(find.text('PRIVACY POLICY'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify we are on the Privacy Policy Page
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text('PRIVACY POLICY'), findsWidgets);
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
        expect(
          find.text(option),
          findsWidgets,
        ); // Found in list and on background page
      } else {
        expect(find.text(option), findsOneWidget);
      }
    }
  });
}
