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

    // Verify empty state message exists
    expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);

    // Verify year dividers do not exist
    expect(find.text('2024'), findsNothing);
    expect(find.text('2023'), findsNothing);

    // Verify log entries do not exist
    expect(find.text('HVAC FILTER'), findsNothing);
    expect(find.text('SMOKE DETECTOR BATTERIES'), findsNothing);
    expect(find.text('FURNACE MAINTENANCE'), findsNothing);

  });
}
