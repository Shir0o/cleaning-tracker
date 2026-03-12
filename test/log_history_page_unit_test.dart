import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  group('LogHistoryPage Unit Tests', () {
    testWidgets('Header elements render with correct style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      final titleFinder = find.text('ARCHIVE');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.color, equals(Colors.black));
      expect(titleWidget.style?.fontSize, equals(32));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(titleWidget.style?.letterSpacing, equals(-0.5));
    });

    testWidgets('Empty state renders when no logs available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      final emptyFinder = find.text('NO HISTORY AVAILABLE');
      expect(emptyFinder, findsOneWidget);

      final emptyWidget = tester.widget<Text>(emptyFinder);
      expect(emptyWidget.style?.color, equals(const Color(0xFF8A8A8A)));
      expect(emptyWidget.style?.fontSize, equals(18));
      expect(emptyWidget.style?.fontWeight, equals(FontWeight.bold));
    });
  });
}
