import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  setUp(() {
    LogHistoryPage.testingMode = true;
  });

  testWidgets('LogHistoryPage renders correctly with header and logs', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final task = Task(
      title: 'HVAC FILTER',
      interval: '90 DAYS',
      lastCompleted: now,
      completions: [
        now.subtract(const Duration(days: 90)),
        now,
      ],
    );

    SharedPreferences.setMockInitialValues({
      'tasks': [jsonEncode(task.toJson())],
    });

    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));
    await tester.pump(); // No need for long pump since testingMode = true

    // Verify header exists
    expect(find.text('HISTORY'), findsOneWidget);

    // Verify year dividers exist
    expect(find.text(now.year.toString()), findsOneWidget);

    // Verify log entries exist
    expect(find.text('HVAC FILTER'), findsNWidgets(2));
  });
  
  testWidgets('LogHistoryPage shows empty state when no completions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tasks': []});

    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));
    await tester.pump();

    expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);
  });
}
