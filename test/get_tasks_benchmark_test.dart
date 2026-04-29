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

  test('Benchmark getTasks N+1', () async {
    const numTasks = 100;
    const completionsPerTask = 5;

    final taskMaps = List.generate(
      numTasks,
      (i) => {
        'id': i + 1,
        'title': 'Task $i',
        'interval': '7 DAYS',
        'lastCompleted': DateTime.now().toIso8601String(),
        'category': 'GENERAL',
        'notes': '',
        'snoozedUntil': null,
      },
    );

    when(() => mockDb.query('tasks')).thenAnswer((_) async => taskMaps);

    final allCompletions = [];
    for (int i = 1; i <= numTasks; i++) {
      for (int j = 0; j < completionsPerTask; j++) {
        allCompletions.add({
          'id': i * 100 + j,
          'task_id': i,
          'date': DateTime.now().subtract(Duration(days: j)).toIso8601String(),
        });
      }
    }
    // Sort them by date ASC to match implementation expectations
    allCompletions.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );

    when(
      () => mockDb.query('completions', orderBy: 'date ASC'),
    ).thenAnswer((_) async => allCompletions);

    final stopwatch = Stopwatch()..start();
    final tasks = await databaseService.getTasks();
    stopwatch.stop();

    expect(tasks.length, numTasks);
    expect(tasks.first.completions.length, completionsPerTask);

    print(
      'BENCHMARK_RESULT_GET_TASKS_OPTIMIZED: ${stopwatch.elapsedMicroseconds} us',
    );
  });
}
