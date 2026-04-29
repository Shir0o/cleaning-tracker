import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/models.dart';

void main() {
  group('Task.copyWith', () {
    final originalTask = Task(
      id: 1,
      title: 'Original Title',
      interval: '7 DAYS',
      lastCompleted: DateTime(2023, 1, 1),
      category: 'GENERAL',
      notes: 'Original Notes',
      completions: [DateTime(2023, 1, 1)],
      snoozedUntil: DateTime(2023, 1, 2),
    );

    test('should return a new instance with updated fields', () {
      final updatedId = 2;
      final updatedTitle = 'Updated Title';
      final updatedInterval = '14 DAYS';
      final updatedLastCompleted = DateTime(2023, 1, 10);
      final updatedCategory = 'KITCHEN';
      final updatedNotes = 'Updated Notes';
      final updatedCompletions = [DateTime(2023, 1, 1), DateTime(2023, 1, 10)];
      final updatedSnoozedUntil = DateTime(2023, 1, 11);

      final updatedTask = originalTask.copyWith(
        id: updatedId,
        title: updatedTitle,
        interval: updatedInterval,
        lastCompleted: updatedLastCompleted,
        category: updatedCategory,
        notes: updatedNotes,
        completions: updatedCompletions,
        snoozedUntil: updatedSnoozedUntil,
      );

      expect(updatedTask.id, updatedId);
      expect(updatedTask.title, updatedTitle);
      expect(updatedTask.interval, updatedInterval);
      expect(updatedTask.lastCompleted, updatedLastCompleted);
      expect(updatedTask.category, updatedCategory);
      expect(updatedTask.notes, updatedNotes);
      expect(updatedTask.completions, updatedCompletions);
      expect(updatedTask.snoozedUntil, updatedSnoozedUntil);
    });

    test('should preserve original values when parameters are omitted', () {
      final updatedTask = originalTask.copyWith();

      expect(updatedTask.id, originalTask.id);
      expect(updatedTask.title, originalTask.title);
      expect(updatedTask.interval, originalTask.interval);
      expect(updatedTask.lastCompleted, originalTask.lastCompleted);
      expect(updatedTask.category, originalTask.category);
      expect(updatedTask.notes, originalTask.notes);
      expect(updatedTask.completions, originalTask.completions);
      expect(updatedTask.snoozedUntil, originalTask.snoozedUntil);
    });

    test('should allow setting nullable fields to new values', () {
      // snoozedUntil is already set in originalTask, let's try to update it to something else
      final newSnoozedUntil = DateTime(2023, 1, 15);
      final updatedTask = originalTask.copyWith(snoozedUntil: newSnoozedUntil);
      expect(updatedTask.snoozedUntil, newSnoozedUntil);
    });
  });
}
