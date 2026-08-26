import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  group('DatabaseService.getTasks', () {
    test('returns an empty list when no tasks exist', () async {
      when(() => mockDb.query('tasks')).thenAnswer((_) async => []);

      final result = await databaseService.getTasks();

      expect(result, isEmpty);
      verify(() => mockDb.query('tasks')).called(1);
      verifyNever(
        () => mockDb.query(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      );
    });

    test('hydrates tasks with completions and parses snoozedUntil', () async {
      final now = DateTime.utc(2026, 1, 1, 12);
      final due = DateTime.utc(2026, 1, 5);
      when(() => mockDb.query('tasks')).thenAnswer(
        (_) async => [
          {
            'id': 1,
            'title': 'MOP',
            'interval': '7 DAYS',
            'lastCompleted': now.toIso8601String(),
            'category': 'KITCHEN',
            'notes': 'note',
            'snoozedUntil': due.toIso8601String(),
          },
        ],
      );
      when(
        () => mockDb.query(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenAnswer(
        (_) async => [
          {'date': now.toIso8601String()},
          {'date': due.toIso8601String()},
        ],
      );

      final result = await databaseService.getTasks();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.title, 'MOP');
      expect(result.first.interval, '7 DAYS');
      expect(result.first.category, 'KITCHEN');
      expect(result.first.notes, 'note');
      expect(result.first.lastCompleted, now);
      expect(result.first.snoozedUntil, due);
      expect(result.first.completions, [now, due]);
    });

    test('handles null snoozedUntil gracefully', () async {
      final now = DateTime.utc(2026, 1, 1);
      when(() => mockDb.query('tasks')).thenAnswer(
        (_) async => [
          {
            'id': 2,
            'title': 'T',
            'interval': '1 DAYS',
            'lastCompleted': now.toIso8601String(),
            'category': 'GENERAL',
            'notes': '',
            'snoozedUntil': null,
          },
        ],
      );
      when(
        () => mockDb.query(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenAnswer((_) async => []);

      final result = await databaseService.getTasks();

      expect(result.single.snoozedUntil, isNull);
      expect(result.single.completions, isEmpty);
    });
  });

  group('DatabaseService.deleteTask', () {
    test('removes both the task and its completions', () async {
      when(
        () => mockDb.delete(
          'tasks',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);
      when(
        () => mockDb.delete(
          'completions',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 0);

      await databaseService.deleteTask(7);

      verify(
        () => mockDb.delete('tasks', where: 'id = ?', whereArgs: [7]),
      ).called(1);
      verify(
        () =>
            mockDb.delete('completions', where: 'task_id = ?', whereArgs: [7]),
      ).called(1);
    });
  });

  group('DatabaseService.addCompletion', () {
    test('inserts a completion row and updates lastCompleted', () async {
      final completionDate = DateTime.utc(2026, 4, 1, 9);
      when(
        () => mockDb.insert('completions', any()),
      ).thenAnswer((_) async => 1);
      when(
        () => mockDb.update(
          'tasks',
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await databaseService.addCompletion(3, completionDate);

      verify(
        () => mockDb.insert('completions', {
          'task_id': 3,
          'date': completionDate.toIso8601String(),
        }),
      ).called(1);
      verify(
        () => mockDb.update(
          'tasks',
          {'lastCompleted': completionDate.toIso8601String()},
          where: 'id = ?',
          whereArgs: [3],
        ),
      ).called(1);
    });
  });

  group('DatabaseService.deleteAllTasks', () {
    test('wipes both completions and tasks inside a transaction', () async {
      when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<void> Function(Transaction);
        return action(mockTxn);
      });
      when(() => mockTxn.delete(any())).thenAnswer((_) async => 0);

      await databaseService.deleteAllTasks();

      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(() => mockTxn.delete('completions')).called(1);
      verify(() => mockTxn.delete('tasks')).called(1);
    });
  });

  group('DatabaseService.insertTask with explicit id', () {
    test('reuses the provided id and skips the auto-increment', () async {
      final task = Task(
        id: 99,
        title: 'Pinned',
        interval: '1 DAYS',
        lastCompleted: DateTime.utc(2026, 1, 1),
      );

      when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<int> Function(Transaction);
        return action(mockTxn);
      });
      when(() => mockTxn.insert(any(), any())).thenAnswer((_) async => 99);

      final id = await databaseService.insertTask(task);

      expect(id, 99);
      verify(
        () => mockTxn.insert('tasks', {
          'id': 99,
          'title': 'Pinned',
          'interval': '1 DAYS',
          'lastCompleted': task.lastCompleted.toIso8601String(),
          'category': 'GENERAL',
          'notes': '',
          'snoozedUntil': null,
        }),
      ).called(1);
    });

    test('writes a row for every completion', () async {
      final dates = [
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 8),
        DateTime.utc(2026, 1, 15),
      ];
      // Use an explicit id so the task_id column is deterministic.
      final task = Task(
        id: 42,
        title: 'X',
        interval: '7 DAYS',
        lastCompleted: dates.last,
        completions: dates,
      );

      when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<int> Function(Transaction);
        return action(mockTxn);
      });
      // Record the (table, values) pairs so we can assert after the fact
      // without mocktail's verify() consuming the call list.
      final inserts = <Map<String, Object?>>[];
      when(() => mockTxn.insert(any(), any())).thenAnswer((invocation) async {
        inserts.add(
          Map<String, Object?>.from(invocation.positionalArguments[1] as Map),
        );
        return 1;
      });
      await databaseService.insertTask(task);

      final completionRows = inserts
          .where((m) => m.containsKey('date'))
          .toList();
      expect(completionRows, hasLength(3));
      for (final d in dates) {
        final matches = completionRows.where(
          (r) => r['task_id'] == 42 && r['date'] == d.toIso8601String(),
        );
        expect(
          matches,
          hasLength(1),
          reason: 'expected one completion row for $d',
        );
      }
    });
  });

  group('DatabaseService.migrateFromSharedPreferences', () {
    test('skips work when migration_complete is already true', () async {
      SharedPreferences.setMockInitialValues({'migration_complete': true});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('migration_complete'), isTrue);

      // With the flag set, the migration is a no-op and must not touch the DB.
      await databaseService.migrateFromSharedPreferences();

      verifyNever(() => mockDb.transaction(any()));
    });

    test('imports existing tasks from SharedPreferences', () async {
      final date = DateTime.utc(2026, 1, 1);
      final taskJson = jsonEncode({
        'title': 'Legacy',
        'interval': '7 DAYS',
        'lastCompleted': date.toIso8601String(),
        'category': 'KITCHEN',
        'notes': '',
        'completions': <String>[],
      });
      SharedPreferences.setMockInitialValues({
        'tasks': [taskJson],
      });

      when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) {
        final action =
            invocation.positionalArguments[0]
                as Future<int> Function(Transaction);
        return action(mockTxn);
      });
      when(() => mockTxn.insert(any(), any())).thenAnswer((_) async => 1);

      await databaseService.migrateFromSharedPreferences();

      // One insert for the task, none for completions.
      verify(() => mockTxn.insert('tasks', any())).called(1);
      verifyNever(() => mockTxn.insert('completions', any()));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('migration_complete'), isTrue);
    });
  });
}
