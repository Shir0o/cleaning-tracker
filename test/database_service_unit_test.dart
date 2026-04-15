import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/main.dart';

class MockDatabase extends Mock implements Database {}
class MockTransaction extends Mock implements Transaction {}
class MockBatch extends Mock implements Batch {}

void main() {
  late MockDatabase mockDb;
  late MockTransaction mockTxn;
  late MockBatch mockBatch;
  late DatabaseService databaseService;

  setUpAll(() {
    registerFallbackValue(MockTransaction());
  });

  setUp(() {
    mockDb = MockDatabase();
    mockTxn = MockTransaction();
    mockBatch = MockBatch();
    DatabaseService.setMockDb(mockDb);
    databaseService = DatabaseService();
  });

  tearDown(() {
    DatabaseService.setMockDb(null);
  });

  group('DatabaseService.insertTask', () {
    test('should insert task and completions using transaction and batch', () async {
      final task = Task(
        title: 'Test Task',
        interval: '7 DAYS',
        lastCompleted: DateTime(2024, 1, 1),
        category: 'TEST',
        completions: [
          DateTime(2023, 12, 25),
          DateTime(2024, 1, 1),
        ],
      );

      when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
        return await action(mockTxn);
      });

      when(() => mockTxn.insert('tasks', any())).thenAnswer((_) async => 1);
      when(() => mockTxn.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit(noResult: any(named: 'noResult'))).thenAnswer((_) async => []);

      final id = await databaseService.insertTask(task);

      expect(id, 1);
      verify(() => mockDb.transaction<int>(any())).called(1);
      verify(() => mockTxn.insert('tasks', {
        'title': task.title,
        'interval': task.interval,
        'lastCompleted': task.lastCompleted.toIso8601String(),
        'category': task.category,
        'notes': task.notes,
        'snoozedUntil': task.snoozedUntil?.toIso8601String(),
      })).called(1);

      verify(() => mockTxn.batch()).called(1);
      for (var completion in task.completions) {
        verify(() => mockBatch.insert('completions', {
          'task_id': 1,
          'date': completion.toIso8601String(),
        })).called(1);
      }
      verify(() => mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('DatabaseService.updateTask', () {
    test('should update task and completions using transaction and batch', () async {
      final task = Task(
        id: 1,
        title: 'Updated Task',
        interval: '14 DAYS',
        lastCompleted: DateTime(2024, 1, 10),
        category: 'UPDATED',
        completions: [
          DateTime(2024, 1, 10),
        ],
      );

      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<void> Function(Transaction);
        await action(mockTxn);
      });

      when(() => mockTxn.update(
        'tasks',
        any(),
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      when(() => mockTxn.delete(
        'completions',
        where: 'task_id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      when(() => mockTxn.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit(noResult: any(named: 'noResult'))).thenAnswer((_) async => []);

      await databaseService.updateTask(task);

      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(() => mockTxn.update(
        'tasks',
        {
          'title': task.title,
          'interval': task.interval,
          'lastCompleted': task.lastCompleted.toIso8601String(),
          'category': task.category,
          'notes': task.notes,
          'snoozedUntil': task.snoozedUntil?.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [1],
      )).called(1);

      verify(() => mockTxn.delete(
        'completions',
        where: 'task_id = ?',
        whereArgs: [1],
      )).called(1);

      verify(() => mockTxn.batch()).called(1);
      for (var completion in task.completions) {
        verify(() => mockBatch.insert('completions', {
          'task_id': 1,
          'date': completion.toIso8601String(),
        })).called(1);
      }
      verify(() => mockBatch.commit(noResult: true)).called(1);
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
