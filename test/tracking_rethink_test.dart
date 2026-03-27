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
  });
}
