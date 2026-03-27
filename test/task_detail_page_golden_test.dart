import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/task_detail_page.dart';
import 'package:cleaning_tracker/main.dart' show Task;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TaskDetailPage.testingMode = true;
  });

  testWidgets('TaskDetailPage Golden Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TaskDetailPage(
          title: 'HVAC FILTER',
          interval: '90 DAYS',
          progress: 0.15,
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

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TaskDetailPage),
      matchesGoldenFile('goldens/task_detail_page_initial.png'),
    );
  });
}
