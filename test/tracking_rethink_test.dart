import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart' show Task;

void main() {
  group('Task Tracking Rethink Tests', () {
    test('health calculation: fresh task', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now,
      );
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
  });
}
