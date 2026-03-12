import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';

void main() {
  group('LogHistoryPage Unit Tests', () {
    testWidgets('Header elements render with correct style', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      final titleFinder = find.text('ARCHIVE');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.color, equals(Colors.black));
      expect(titleWidget.style?.fontSize, equals(32));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(titleWidget.style?.letterSpacing, equals(-0.5));
    });

    testWidgets('Year dividers render with correct style', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

      final yearFinder = find.text('2024');
      expect(yearFinder, findsOneWidget);

      final yearWidget = tester.widget<Text>(yearFinder);
      expect(yearWidget.style?.color, equals(Colors.black));
      expect(yearWidget.style?.fontSize, equals(24));
      expect(yearWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(yearWidget.style?.height, equals(1.0));
    });

    testWidgets('Log record elements render with correct styles', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));

       final dateFinder = find.text('10.24');
       expect(dateFinder, findsOneWidget);

       final dateWidget = tester.widget<Text>(dateFinder);
       expect(dateWidget.style?.fontSize, equals(14));
       expect(dateWidget.style?.color, equals(Colors.black));

       final titleFinder = find.text('HVAC FILTER'); // uppercase
       expect(titleFinder, findsWidgets);

       final titleWidget = tester.widget<Text>(titleFinder.first);
       expect(titleWidget.style?.fontSize, equals(16));
       expect(titleWidget.style?.fontWeight, equals(FontWeight.w500));
       expect(titleWidget.style?.color, equals(Colors.black));

       final resetFinder = find.text('RESET');
       expect(resetFinder, findsWidgets);

       final resetWidget = tester.widget<Text>(resetFinder.first);
       expect(resetWidget.style?.fontSize, equals(14));
       expect(resetWidget.style?.color, equals(Colors.black));
    });
  });
}
