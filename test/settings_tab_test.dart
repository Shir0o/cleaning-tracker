import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/notification_service.dart';
import 'package:cleaning_tracker/settings_tab.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() => const MaterialApp(home: Scaffold(body: SettingsTab()));

void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    LogHistoryPage.testingMode = true;
    PrivacyPolicyPage.testingMode = true;
    DashboardScreen.testingMode = true;
    TaskCard.testingMode = true;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.light;
  });

  testWidgets('renders every section and room', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    for (final header in ['Remind me about', 'Appearance', 'Backup', 'About']) {
      expect(find.text(header), findsOneWidget);
    }
    expect(find.text('Reminders'), findsNWidgets(2)); // header + row
    for (final room in roomThemes) {
      expect(find.text(room.name), findsOneWidget);
    }
    expect(find.text('9:00 AM'), findsOneWidget);
    expect(find.text('2 days early'), findsOneWidget);
    expect(find.text('Sign in to back up'), findsOneWidget);
    expect(find.text('Start of Week'), findsNothing);
  });

  testWidgets('dashboard Settings tab shows SettingsTab', (tester) async {
    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsTab), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('turning a room off saves it as muted', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final kitchenSwitch = find.descendant(
      of: find.ancestor(of: find.text('Kitchen'), matching: find.byType(Row)),
      matching: find.byType(Switch),
    );
    await tester.tap(kitchenSwitch.first);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(mutedRoomsPrefKey), ['KITCHEN']);

    await tester.tap(kitchenSwitch.first);
    await tester.pumpAndSettle();
    expect(prefs.getStringList(mutedRoomsPrefKey), isEmpty);
  });

  testWidgets('loads muted rooms from preferences', (tester) async {
    SharedPreferences.setMockInitialValues({
      mutedRoomsPrefKey: ['BATHROOM'],
    });
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    Switch switchFor(String room) => tester.widget<Switch>(
      find
          .descendant(
            of: find.ancestor(of: find.text(room), matching: find.byType(Row)),
            matching: find.byType(Switch),
          )
          .first,
    );
    expect(switchFor('Bathroom').value, isFalse);
    expect(switchFor('Kitchen').value, isTrue);
  });

  testWidgets('Dark button applies and saves the theme', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeNotifier.value, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('interfaceTheme'), 'DARK');
  });

  testWidgets('Heads-up picker lists every option and saves the pick', (
    tester,
  ) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Heads-up'));
    await tester.pumpAndSettle();

    for (final label in [
      'Same day',
      '1 day',
      '2 days',
      '3 days',
      '4 days',
      '5 days',
      '1 week',
      '2 weeks',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('1 week'));
    await tester.pumpAndSettle();

    expect(find.text('1 week early'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('notifyBeforeExpiry'), '1 WEEK');
  });

  testWidgets('Time picker saves the reminder time', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7:00 PM'));
    await tester.pumpAndSettle();

    expect(find.text('7:00 PM'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('dailyReminderTime'), '07:00 PM');
  });

  testWidgets('Cleaning history opens LogHistoryPage', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cleaning history'));
    await tester.pumpAndSettle();

    expect(find.byType(LogHistoryPage), findsOneWidget);
  });

  testWidgets('Privacy policy opens PrivacyPolicyPage', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
  });
}
