import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';

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
