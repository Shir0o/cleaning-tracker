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
      expect(find.text('CLEANLINESS'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);

      // Reset Button
      expect(find.text('I JUST DID IT!'), findsOneWidget);

      // Category Section
      expect(find.text('CATEGORY'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);

      // Interval Section
      expect(find.text('INTERVAL'), findsOneWidget);

      // Notes Section
      // We might need to scroll for these
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('NOTES'), findsOneWidget);
      expect(find.text('NO NOTES RECORDED'), findsOneWidget);

      // History Section
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(find.text('HISTORY'), findsOneWidget);
      expect(find.text('NO HISTORY YET'), findsOneWidget);
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

      // Progress is sent as negative health. Cleanliness should show negative.
      expect(find.text('-1%'), findsOneWidget);
      expect(find.text('STATUS: 5 DAYS OVERDUE'), findsOneWidget);
    });

    testWidgets('shows red color at exactly 0%', (WidgetTester tester) async {
      TaskDetailPage.testingMode = false; // Disable to allow style/color inspection
      addTearDown(() => TaskDetailPage.testingMode = true);

      // Use a fixed time for stability in health calculation
      final now = DateTime.now();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0038FF),
              error: Color(0xFFFF0000),
            ),
          ),
          home: TaskDetailPage(
            task: Task(
              title: 'DEADLINE TASK',
              interval: '1 DAYS',
              lastCompleted: now.subtract(const Duration(days: 1)),
            ),
          ),
        ),
      );

      final percentageText = tester.widget<Text>(find.text('0%'));
      // This is expected to fail initially as 0% is currently blue (primary)
      expect(percentageText.style?.color, const Color(0xFFFF0000), 
          reason: '0% cleanliness should be displayed in error color (red)');
    });
  });
}
