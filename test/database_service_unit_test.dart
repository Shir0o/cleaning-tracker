import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/models.dart';

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockBatch extends Mock implements Batch {}

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

  group('DatabaseService.resetCategory', () {
    test('should update all tasks in category and add completions', () async {
      final category = 'KITCHEN';
      final resetDate = DateTime(2024, 1, 1);
      final tasks = [
        {'id': 1, 'title': 'Clean Fridge', 'category': category},
        {'id': 2, 'title': 'Mop Floor', 'category': category},
      ];

      // Mock the initial query for tasks in the category
      when(
        () =>
            mockDb.query('tasks', where: 'category = ?', whereArgs: [category]),
      ).thenAnswer((_) async => tasks);

      // Mock the transaction
      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return action(mockTxn);
      });

      // Mock the updates and inserts within the transaction
      when(
        () => mockTxn.insert('completions', any()),
      ).thenAnswer((_) async => 1);

      when(
        () => mockTxn.update(
          'tasks',
          any(),
          where: 'id = ?',
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await databaseService.resetCategory(category, resetDate);

      // Verify queries and transaction
      verify(
        () =>
            mockDb.query('tasks', where: 'category = ?', whereArgs: [category]),
      ).called(1);

      verify(() => mockDb.transaction<void>(any())).called(1);

      // Verify actions for each task
      for (var task in tasks) {
        final id = task['id'] as int;
        verify(
          () => mockTxn.insert('completions', {
            'task_id': id,
            'date': resetDate.toIso8601String(),
          }),
        ).called(1);

        verify(
          () => mockTxn.update(
            'tasks',
            {'lastCompleted': resetDate.toIso8601String()},
            where: 'id = ?',
            whereArgs: [id],
          ),
        ).called(1);
      }
    });

    test('should do nothing if no tasks in category', () async {
      final category = 'EMPTY_CAT';
      final resetDate = DateTime(2024, 1, 1);

      when(
        () =>
            mockDb.query('tasks', where: 'category = ?', whereArgs: [category]),
      ).thenAnswer((_) async => []);

      // Mock the transaction (even though it shouldn't be called if we follow the code,
      // actually the code DOES call transaction even if tasks is empty)
      // Let's check the code:
      // await database.transaction((txn) async {
      //   for (var task in tasks) { ... }
      // });
      // Yes, it calls transaction.

      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return action(mockTxn);
      });

      await databaseService.resetCategory(category, resetDate);

      verify(
        () =>
            mockDb.query('tasks', where: 'category = ?', whereArgs: [category]),
      ).called(1);

      verify(() => mockDb.transaction<void>(any())).called(1);
      verifyNever(() => mockTxn.insert(any(), any()));
      verifyNever(
        () => mockTxn.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      );
    });
  });

  group('DatabaseService.insertTask', () {
    test('should use a transaction', () async {
      final task = Task(
        title: 'New Task',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
        completions: [DateTime.now()],
      );

      when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<int> Function(Transaction);
        return action(mockTxn);
      });

      when(() => mockTxn.insert(any(), any())).thenAnswer((_) async => 1);

      await databaseService.insertTask(task);

      verify(() => mockDb.transaction<int>(any())).called(1);
      verify(() => mockTxn.insert('tasks', any())).called(1);
      verify(() => mockTxn.insert('completions', any())).called(1);
    });
  });

  group('DatabaseService.updateTask', () {
    test('should use a transaction', () async {
      final task = Task(
        id: 1,
        title: 'Updated Task',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
        completions: [DateTime.now()],
      );
      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return action(mockTxn);
      });

      when(
        () => mockTxn.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);
      when(
        () => mockTxn.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);
      when(() => mockTxn.insert(any(), any())).thenAnswer((_) async => 1);

      await databaseService.updateTask(task);

      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(
        () => mockTxn.update(
          'tasks',
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
      verify(
        () => mockTxn.delete(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
      verify(() => mockTxn.insert('completions', any())).called(1);
    });
  });

  group('DatabaseService.batchInsertTasks', () {
    test('should use batch for tasks and completions', () async {
      final tasks = [
        Task(
          title: 'T1',
          interval: 'D',
          lastCompleted: DateTime.now(),
          completions: [DateTime.now()],
        ),
        Task(
          title: 'T2',
          interval: 'W',
          lastCompleted: DateTime.now(),
          completions: [DateTime.now(), DateTime.now()],
        ),
      ];
      final mockBatch = MockBatch();

      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return action(mockTxn);
      });
      when(() => mockTxn.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit()).thenAnswer((_) async => [1, 2]);
      when(() => mockBatch.commit(noResult: true)).thenAnswer((_) async => []);

      await databaseService.batchInsertTasks(tasks);

      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(() => mockTxn.batch()).called(2);
      verify(() => mockBatch.insert('tasks', any())).called(2);
      verify(
        () => mockBatch.insert('completions', any()),
      ).called(3); // 1 for T1, 2 for T2
      verify(() => mockBatch.commit()).called(1);
      verify(() => mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('DatabaseService.getTasks', () {
    test('fetches all tasks and batch queries completions', () async {
      final now = DateTime.utc(2026, 1, 1, 12);
      final completion1 = DateTime.utc(2026, 1, 2);
      final completion2 = DateTime.utc(2026, 1, 3);

      when(() => mockDb.query('tasks')).thenAnswer(
        (_) async => [
          {
            'id': 1,
            'title': 'Task 1',
            'interval': '7 DAYS',
            'lastCompleted': now.toIso8601String(),
            'category': 'KITCHEN',
            'notes': 'note 1',
            'snoozedUntil': null,
          },
          {
            'id': 2,
            'title': 'Task 2',
            'interval': '1 DAYS',
            'lastCompleted': now.toIso8601String(),
            'category': 'BATHROOM',
            'notes': '',
            'snoozedUntil': null,
          },
        ],
      );

      when(() => mockDb.query('completions', orderBy: 'date ASC')).thenAnswer(
        (_) async => [
          {'task_id': 1, 'date': completion1.toIso8601String()},
          {'task_id': 2, 'date': completion2.toIso8601String()},
        ],
      );

      final result = await databaseService.getTasks();

      expect(result, hasLength(2));
      expect(result[0].id, 1);
      expect(result[0].completions, [completion1]);
      expect(result[1].id, 2);
      expect(result[1].completions, [completion2]);

      verify(() => mockDb.query('tasks')).called(1);
      verify(() => mockDb.query('completions', orderBy: 'date ASC')).called(1);
      // Ensure N+1 per-task queries were eliminated
      verifyNever(
        () => mockDb.query(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          orderBy: any(named: 'orderBy'),
        ),
      );
    });
  });
}
