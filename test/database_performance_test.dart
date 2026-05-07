import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/models.dart';

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockDatabase mockDb;
  late DatabaseService databaseService;

  setUp(() {
    mockDb = MockDatabase();
    DatabaseService.setMockDb(mockDb);
    databaseService = DatabaseService();
  });

  test('Baseline: Sequential inserts (Mocked)', () async {
    final tasks = List.generate(
      50,
      (i) => Task(
        title: 'Task $i',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
        completions: [
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 7)),
        ],
      ),
    );

    final mockTxn = MockTransaction();
    when(() => mockDb.transaction<int>(any())).thenAnswer((invocation) async {
      final action =
          invocation.positionalArguments[0]
              as Future<int> Function(Transaction);
      return await action(mockTxn);
    });

    when(() => mockTxn.insert(any(), any())).thenAnswer((_) async => 1);

    final stopwatch = Stopwatch()..start();
    for (final task in tasks) {
      await databaseService.insertTask(task);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('BENCHMARK_RESULT_SEQUENTIAL: ${stopwatch.elapsedMicroseconds} us');
  });

  test('Optimization: Batch inserts (Mocked)', () async {
    final tasks = List.generate(
      50,
      (i) => Task(
        title: 'Task $i',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
        completions: [
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 7)),
        ],
      ),
    );

    final mockTxn = MockTransaction();
    final mockBatch = MockBatch();
    when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) async {
      final action =
          invocation.positionalArguments[0]
              as Future<void> Function(Transaction);
      await action(mockTxn);
    });
    when(() => mockTxn.batch()).thenReturn(mockBatch);
    when(
      () => mockBatch.commit(),
    ).thenAnswer((_) async => List.generate(50, (i) => i + 1));
    when(() => mockBatch.commit(noResult: true)).thenAnswer((_) async => []);

    final stopwatch = Stopwatch()..start();
    await databaseService.batchInsertTasks(tasks);
    stopwatch.stop();

    // ignore: avoid_print
    print('BENCHMARK_RESULT_BATCH: ${stopwatch.elapsedMicroseconds} us');
  });
}
