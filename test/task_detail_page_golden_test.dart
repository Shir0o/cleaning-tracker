import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/task_detail_page.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TaskDetailPage.testingMode = true;
  });

  testWidgets('TaskDetailPage Golden Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TaskDetailPage(
          title: 'HVAC FILTER',
          progress: 0.15,
          dueDateText: '14 DAYS',
          isOverdue: false,
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
