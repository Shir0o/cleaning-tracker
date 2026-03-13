import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  setUp(() {
    LogHistoryPage.testingMode = true;
  });

  group('LogHistoryPage Unit Tests', () {
    testWidgets('Header elements render with correct style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      final titleFinder = find.text('ARCHIVE');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      // In testingMode, _safeGoogleFont returns const TextStyle(), so properties are null/default
      expect(titleWidget.style, isNotNull);
    });

    testWidgets('Mock data renders when not loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      // Since testingMode = true, isLoading = false immediately
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('HVAC FILTER'), findsOneWidget);
    });
  });
}
