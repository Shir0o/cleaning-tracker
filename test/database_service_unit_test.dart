import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/main.dart' show Task;

class MockDatabase extends Mock implements Database {}
class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockDatabase mockDb;
  late MockTransaction mockTxn;
  late DatabaseService databaseService;

  setUpAll(() {
    registerFallbackValue(MockTransaction());
  });

  setUp(() {
    mockDb = MockDatabase();
    mockTxn = MockTransaction();
    DatabaseService.setMockDb(mockDb);
    databaseService = DatabaseService();
  });

  tearDown(() {
    DatabaseService.setMockDb(null);
  });

  group('DatabaseService.insertTask', () {
    test('should insert task and return its id', () async {
      final task = Task(
        title: 'Test Task',
        interval: '7 DAYS',
        lastCompleted: DateTime(2024, 1, 1),
        category: 'TEST',
        notes: 'Some notes',
      );

      when(() => mockDb.insert(
            'tasks',
            {
              'title': task.title,
              'interval': task.interval,
              'lastCompleted': task.lastCompleted.toIso8601String(),
              'category': task.category,
              'notes': task.notes,
              'snoozedUntil': null,
            },
          )).thenAnswer((_) async => 123);

      final result = await databaseService.insertTask(task);

      expect(result, 123);
      verify(() => mockDb.insert('tasks', any())).called(1);
      verifyNever(() => mockDb.insert('completions', any()));
    });

    test('should insert task and its completions', () async {
      final completions = [
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      ];
      final task = Task(
        title: 'Test Task',
        interval: '7 DAYS',
        lastCompleted: DateTime(2024, 1, 8),
        completions: completions,
      );

      when(() => mockDb.insert('tasks', any())).thenAnswer((_) async => 456);
      when(() => mockDb.insert('completions', any())).thenAnswer((_) async => 1);

      final result = await databaseService.insertTask(task);

      expect(result, 456);
      verify(() => mockDb.insert('tasks', any())).called(1);
      verify(() => mockDb.insert('completions', {
            'task_id': 456,
            'date': completions[0].toIso8601String(),
          })).called(1);
      verify(() => mockDb.insert('completions', {
            'task_id': 456,
            'date': completions[1].toIso8601String(),
          })).called(1);
    });
  });

  group('DatabaseService.resetCategory', () {
    test('should update all tasks in category and add completions', () async {
      final category = 'KITCHEN';
      final resetDate = DateTime(2024, 1, 1);
      final tasks = [
        {'id': 1, 'title': 'Clean Fridge', 'category': category},
        {'id': 2, 'title': 'Mop Floor', 'category': category},
      ];

      // Mock the initial query for tasks in the category
      when(() => mockDb.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
      )).thenAnswer((_) async => tasks);

      // Mock the transaction
      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<void> Function(Transaction);
        await action(mockTxn);
      });

      // Mock the updates and inserts within the transaction
      when(() => mockTxn.insert(
        'completions',
        any(),
      )).thenAnswer((_) async => 1);

      when(() => mockTxn.update(
        'tasks',
        any(),
        where: 'id = ?',
        whereArgs: any(named: 'whereArgs'),
      )).thenAnswer((_) async => 1);

      await databaseService.resetCategory(category, resetDate);

      // Verify queries and transaction
      verify(() => mockDb.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
      )).called(1);

      verify(() => mockDb.transaction<void>(any())).called(1);

      // Verify actions for each task
      for (var task in tasks) {
        final id = task['id'] as int;
        verify(() => mockTxn.insert('completions', {
          'task_id': id,
          'date': resetDate.toIso8601String(),
        })).called(1);

        verify(() => mockTxn.update(
          'tasks',
          {'lastCompleted': resetDate.toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        )).called(1);
      }
    });

    test('should do nothing if no tasks in category', () async {
      final category = 'EMPTY_CAT';
      final resetDate = DateTime(2024, 1, 1);

      when(() => mockDb.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
      )).thenAnswer((_) async => []);

      // Mock the transaction (even though it shouldn't be called if we follow the code,
      // actually the code DOES call transaction even if tasks is empty)
      // Let's check the code:
      // await database.transaction((txn) async {
      //   for (var task in tasks) { ... }
      // });
      // Yes, it calls transaction.

      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<void> Function(Transaction);
        await action(mockTxn);
      });

      await databaseService.resetCategory(category, resetDate);

      verify(() => mockDb.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category],
      )).called(1);

      verify(() => mockDb.transaction<void>(any())).called(1);
      verifyNever(() => mockTxn.insert(any(), any()));
      verifyNever(() => mockTxn.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')));
    });
  });
}
