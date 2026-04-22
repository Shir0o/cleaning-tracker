import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/models.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    LogHistoryPage.testingMode = true;
    DatabaseService.testingMode = true;
    mockDatabaseService = MockDatabaseService();
    DatabaseService.instance = mockDatabaseService;
  });

  testWidgets('LogHistoryPage renders correctly with header and logs', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final task = Task(
      id: 1,
      title: 'HVAC FILTER',
      interval: '90 DAYS',
      lastCompleted: now,
      completions: [now.subtract(const Duration(days: 90)), now],
    );

    when(() => mockDatabaseService.getTasks()).thenAnswer((_) async => [task]);

    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));
    await tester.pump(); // No need for long pump since testingMode = true

    // Verify header exists
    expect(find.text('HISTORY'), findsOneWidget);

    // Verify year dividers exist
    expect(find.text(now.year.toString()), findsOneWidget);

    // Verify log entries exist
    expect(find.text('HVAC FILTER'), findsNWidgets(2));
  });

  testWidgets('LogHistoryPage shows empty state when no completions', (
    WidgetTester tester,
  ) async {
    when(() => mockDatabaseService.getTasks()).thenAnswer((_) async => []);

    await tester.pumpWidget(const MaterialApp(home: LogHistoryPage()));
    await tester.pump();

    expect(find.text('NO HISTORY AVAILABLE'), findsOneWidget);
  });
}
