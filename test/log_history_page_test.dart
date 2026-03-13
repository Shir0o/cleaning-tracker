import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  setUp(() {
    LogHistoryPage.testingMode = true;
  });

  testWidgets('LogHistoryPage renders correctly with header and logs', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

    // Verify header exists
    expect(find.text('ARCHIVE'), findsOneWidget);

    // Verify mock data exists
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('HVAC FILTER'), findsOneWidget);

  });
}
