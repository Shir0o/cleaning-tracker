import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart' show TaskCard;
import 'package:cleaning_tracker/models.dart';

void main() {
  group('Task Tracking Rethink Tests', () {
    test('health calculation: fresh task', () {
      final now = DateTime.now();
      final task = Task(title: 'Test', interval: '10 DAYS', lastCompleted: now);
      // Health should be 1.0 (100%)
      expect(task.health(now), 1.0);
    });

    test('health calculation: midway task', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 5)),
      );
      // Health should be 0.5 (50%)
      expect(task.health(now), closeTo(0.5, 0.001));
    });

    test('health calculation: due task', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 10)),
      );
      // Health should be 0.0 (0%)
      expect(task.health(now), closeTo(0.0, 0.001));
    });

    test('health calculation: overdue task (continuous)', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 15)),
      );
      // Health should be -0.5 (-50%)
      expect(task.health(now), closeTo(-0.5, 0.001));
    });

    test('statusText: logic based on health', () {
      final now = DateTime.now();
      Task createTask(double health) {
        final totalSecs = 10 * 24 * 3600;
        final elapsedSecs = (totalSecs * (1.0 - health)).round();
        return Task(
          title: 'Test',
          interval: '10 DAYS',
          lastCompleted: now.subtract(Duration(seconds: elapsedSecs)),
        );
      }

      expect(createTask(0.9).statusText(now), 'OPERATIONAL');
      expect(createTask(0.5).statusText(now), 'DEGRADING');
      expect(createTask(0.1).statusText(now), 'CRITICAL');
      expect(createTask(-0.1).statusText(now), '1 DAYS OVERDUE');
    });

    test('dueDateText: absolute and relative', () {
      final now = DateTime(2026, 3, 27); // Today in session
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 7)),
      );
      // Due date is now + 3 days = March 30
      expect(task.dueDateText(now), 'MAR 30 (3 DAYS)');

      final overdueTask = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 12)),
      );
      // Due date was now - 2 days = March 25
      expect(overdueTask.dueDateText(now), 'MAR 25 (-2 DAYS)');
    });

    test('overdue threshold logic: rounds to 0% is overdue', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '1 DAYS',
        // 0.4% health rounds to 0%
        lastCompleted: now.subtract(const Duration(seconds: 86100)),
      );
      final health = task.health(now);
      final isOverdue = (health * 100).round() <= 0;
      expect(
        isOverdue,
        isTrue,
        reason: '0.4% health rounds to 0% and should be considered overdue',
      );
    });

    test('overdue threshold logic: rounds to 1% is NOT overdue', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '1 DAYS',
        // 0.6% health rounds to 1%
        lastCompleted: now.subtract(const Duration(seconds: 85800)),
      );
      final health = task.health(now);
      final isOverdue = (health * 100).round() <= 0;
      expect(
        isOverdue,
        isFalse,
        reason: '0.6% health rounds to 1% and should NOT be considered overdue',
      );
    });

    testWidgets('TaskCard handles long titles without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title:
                  'THIS IS AN EXTREMELY LONG TASK TITLE THAT SHOULD DEFINITELY OVERFLOW IF NOT HANDLED PROPERLY BY THE EXPANDED WIDGET',
              interval: '7 DAYS',
              dueDateText: 'MAR 30 (3 DAYS)',
              progress: 0.5,
              isOverdue: false,
            ),
          ),
        ),
      );

      // Verify no overflow exception was thrown and title is rendered (partially)
      expect(find.textContaining('THIS IS AN EXTREMELY LONG'), findsOneWidget);
      expect(find.text('MAR 30 (3 DAYS)'), findsOneWidget);
    });
  });
}
