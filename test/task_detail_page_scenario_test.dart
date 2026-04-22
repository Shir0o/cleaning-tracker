import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/task_detail_page.dart';
import 'package:cleaning_tracker/models.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TaskDetailPage.testingMode = true;
  });

  group('TaskDetailPage Scenarios', () {
    testWidgets('Tapping back button navigates back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(
                          task: Task(
                            title: 'HVAC FILTER',
                            interval: '90 DAYS',
                            lastCompleted: DateTime.now().subtract(
                              const Duration(days: 13),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Detail'),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to Detail Page
      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskDetailPage), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(TaskDetailPage), findsNothing);
      expect(find.text('Go to Detail'), findsOneWidget);
    });
  });
}
