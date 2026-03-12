import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  testWidgets('LogHistoryPage renders correctly with header and logs', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

    // Verify header exists
    expect(find.text('ARCHIVE'), findsOneWidget);

    // Verify year dividers exist
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);

    // Verify some specific log entries exist from the mockup
    expect(
      find.text('HVAC FILTER'),
      findsWidgets,
    ); // Due to uppercase CSS, checking uppercase or exact case
    expect(find.text('SMOKE DETECTOR BATTERIES'), findsOneWidget);
    expect(find.text('FURNACE MAINTENANCE'), findsOneWidget);

    expect(find.text('10.24'), findsOneWidget);
    expect(find.text('RESET'), findsWidgets);
  });
}
