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
    final fixedNow = DateTime(2024, 5, 20, 10, 0, 0);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TaskDetailPage(
          referenceTime: fixedNow,
          task: Task(
            title: 'HVAC FILTER',
            interval: '90 DAYS',
            lastCompleted: fixedNow.subtract(
              const Duration(days: 13, hours: 12),
            ), // 13.5 days ago
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
