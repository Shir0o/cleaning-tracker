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
            title: 'HVAC FILTER',
            interval: '90 DAYS',
            progress: 0.15, // 0.15 elapsed means 85% remaining life
            dueDateText: '14 DAYS',
            isOverdue: false,
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

    testWidgets('calculates 0% and shows appropriate status for overdue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            title: 'SMOKE ALARMS',
            interval: '365 DAYS',
            progress: 1.0,
            dueDateText: '-5 DAYS',
            isOverdue: true,
            task: Task(
              title: 'SMOKE ALARMS',
              interval: '365 DAYS',
              lastCompleted: DateTime.now().subtract(const Duration(days: 370)),
            ),
          ),
        ),
      );

      // Progress is sent as 1.0 (100% elapsed). Remaining life should show 0%.
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('STATUS: 5 DAYS OVERDUE'), findsOneWidget);
    });
  });
}
