import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  group('LogHistoryPage Scenario Tests', () {
    testWidgets('User scales text up and down, layout still constrains', (
      WidgetTester tester,
    ) async {
      // Scenario: User changes system text scale factor
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: LogHistoryPage(),
          ),
        ),
      );

      // Verify header and items are still found
      expect(find.text('ARCHIVE'), findsOneWidget);
      expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);

      // Scale down
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(0.8)),
            child: LogHistoryPage(),
          ),
        ),
      );

      expect(find.text('ARCHIVE'), findsOneWidget);
      expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);
    });
  });
}
