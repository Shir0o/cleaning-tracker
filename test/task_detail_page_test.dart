import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/task_detail_page.dart';
import 'package:cleaning_tracker/main.dart' show Task;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TaskDetailPage.testingMode = true;
  });

  group('TaskDetailPage Widget Tests', () {
    testWidgets('renders all major sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: Task(
              title: 'HVAC FILTER',
              interval: '90 DAYS',
              lastCompleted: DateTime.now().subtract(const Duration(hours: 13 * 24 + 12)), // 13.5 days
            ),
          ),
        ),
      );

      // AppBar Title
      expect(find.text('HVAC FILTER'), findsOneWidget);

      // Status Section
      expect(find.text('REMAINING LIFE'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);

      // Reset Button
      expect(find.text('RESET SYSTEM'), findsOneWidget);

      // Interval Section
      expect(find.text('INTERVAL'), findsOneWidget);

      // Quick Specs Section
      // We might need to scroll for these
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('QUICK SPECS'), findsOneWidget);
      expect(find.text('SPEC 1'), findsOneWidget);
      expect(find.text('SPEC 2'), findsOneWidget);

      // Log Archive Section
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(find.text('LOG ARCHIVE'), findsOneWidget);
      expect(find.text('NO LOGS RECORDED'), findsOneWidget);
    });

    testWidgets('calculates negative percentage and shows appropriate status for overdue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: Task(
              title: 'SMOKE ALARMS',
              interval: '365 DAYS',
              lastCompleted: DateTime.now().subtract(const Duration(days: 370)),
            ),
          ),
        ),
      );

      // Progress is sent as negative health. Remaining life should show negative.
      expect(find.text('-1%'), findsOneWidget);
      expect(find.text('STATUS: 5 DAYS OVERDUE'), findsOneWidget);
    });
  });
}
