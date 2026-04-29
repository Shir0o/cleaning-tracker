import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/models.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabase mockDb;
  late DatabaseService databaseService;

  setUp(() {
    mockDb = MockDatabase();
    DatabaseService.setMockDb(mockDb);
    databaseService = DatabaseService();
  });

  test('getTasks returns correct data and optimizes queries', () async {
    final now = DateTime.now();
    final taskMaps = [
      {
        'id': 1,
        'title': 'Task 1',
        'interval': '7 DAYS',
        'lastCompleted': now.toIso8601String(),
        'category': 'GENERAL',
        'notes': '',
        'snoozedUntil': null,
      },
      {
        'id': 2,
        'title': 'Task 2',
        'interval': '14 DAYS',
        'lastCompleted': now.toIso8601String(),
        'category': 'KITCHEN',
        'notes': 'Some notes',
        'snoozedUntil': now.add(Duration(days: 1)).toIso8601String(),
      },
    ];

    final completionMaps = [
      {
        'id': 101,
        'task_id': 1,
        'date': now.subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 102,
        'task_id': 2,
        'date': now.subtract(Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 103,
        'task_id': 1,
        'date': now.subtract(Duration(days: 3)).toIso8601String(),
      },
    ];

    when(() => mockDb.query('tasks')).thenAnswer((_) async => taskMaps);
    when(
      () => mockDb.query('completions', orderBy: 'date ASC'),
    ).thenAnswer((_) async => completionMaps);

    final tasks = await databaseService.getTasks();

    expect(tasks.length, 2);

    final t1 = tasks.firstWhere((t) => t.id == 1);
    expect(t1.title, 'Task 1');
    expect(t1.completions.length, 2);
    // Completions should be sorted by date ASC (which depends on our query result)
    // In our mock, we provide them in some order, but the code relies on ORDER BY date ASC from DB.
    // Our mock completions are 1 day ago, 2 days ago, 3 days ago.
    // The query returns them as we defined.

    final t2 = tasks.firstWhere((t) => t.id == 2);
    expect(t2.title, 'Task 2');
    expect(t2.completions.length, 1);
    expect(t2.category, 'KITCHEN');
    expect(t2.snoozedUntil, isNotNull);

    verify(() => mockDb.query('tasks')).called(1);
    verify(() => mockDb.query('completions', orderBy: 'date ASC')).called(1);
    // Verify NO N+1 queries
    verifyNever(
      () => mockDb.query(
        'completions',
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
        orderBy: any(named: 'orderBy'),
      ),
    );
  });

  test('getTasks returns empty list when no tasks exist', () async {
    when(() => mockDb.query('tasks')).thenAnswer((_) async => []);

    final tasks = await databaseService.getTasks();

    expect(tasks, isEmpty);
    verify(() => mockDb.query('tasks')).called(1);
    verifyNever(
      () => mockDb.query('completions', orderBy: any(named: 'orderBy')),
    );
  });
}
