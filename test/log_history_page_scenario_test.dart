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
      expect(find.text('HVAC FILTER'), findsWidgets);

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
      expect(find.text('2023'), findsOneWidget);
    });

    testWidgets('User scrolls through the archive list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      // Initially top elements should be visible
      expect(find.text('ARCHIVE'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);

      // HVAC Filter should be visible
      expect(find.text('HVAC FILTER'), findsWidgets);

      // Attempt scroll (though our list is short, making sure it's scrollable)
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Bottom elements should be available/visible
      expect(find.text('11.05'), findsOneWidget);
      expect(find.text('GUTTER CLEANING'), findsOneWidget);
    });
  });
}
