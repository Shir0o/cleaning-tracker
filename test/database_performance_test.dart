import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/main.dart';

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

    when(() => mockDb.insert(any(), any())).thenAnswer((_) async => 1);

    final stopwatch = Stopwatch()..start();
    for (final task in tasks) {
      await databaseService.insertTask(task);
    }
    stopwatch.stop();

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

    final mockBatch = MockBatch();
    when(() => mockDb.batch()).thenReturn(mockBatch);
    when(
      () => mockBatch.commit(),
    ).thenAnswer((_) async => List.generate(50, (i) => i + 1));
    when(() => mockBatch.commit(noResult: true)).thenAnswer((_) async => []);

    final stopwatch = Stopwatch()..start();
    await databaseService.batchInsertTasks(tasks);
    stopwatch.stop();

    print('BENCHMARK_RESULT_BATCH: ${stopwatch.elapsedMicroseconds} us');
  });
}
