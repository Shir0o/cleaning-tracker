import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart';

void main() {
  group('Smart Interval Suggestion Logic', () {
    test('Should return null if less than 3 completions', () {
      final task = Task(
        title: 'Test',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
        completions: [
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now().subtract(const Duration(days: 14)),
        ],
      );

      expect(task.suggestedInterval, isNull);
    });

    test('Should suggest shorter interval if consistently early', () {
      // Current interval is 10 days
      // Actual completions: 5 days, 5 days, 5 days
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '10 DAYS',
        lastCompleted: now,
        completions: [
          now.subtract(const Duration(days: 15)),
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 5)),
          now,
        ],
      );

      expect(task.suggestedInterval, equals('5 DAYS'));
    });

    test('Should suggest longer interval if consistently late', () {
      // Current interval is 5 days
      // Actual completions: 10 days, 10 days, 10 days
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '5 DAYS',
        lastCompleted: now,
        completions: [
          now.subtract(const Duration(days: 30)),
          now.subtract(const Duration(days: 20)),
          now.subtract(const Duration(days: 10)),
          now,
        ],
      );

      expect(task.suggestedInterval, equals('10 DAYS'));
    });

    test('Should return null if average matches current interval', () {
      final now = DateTime.now();
      final task = Task(
        title: 'Test',
        interval: '7 DAYS',
        lastCompleted: now,
        completions: [
          now.subtract(const Duration(days: 21)),
          now.subtract(const Duration(days: 14)),
          now.subtract(const Duration(days: 7)),
          now,
        ],
      );

      expect(task.suggestedInterval, isNull);
    });
  });
}
