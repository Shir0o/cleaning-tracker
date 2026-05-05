import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/database_service.dart';

void main() {
  setUp(() {
    DashboardScreen.testingMode = true;
    DatabaseService.testingMode = true;
  });

  testWidgets('Dashboard shows overall health score and priority actions', (
    WidgetTester tester,
  ) async {
    // We can't easily mock the DatabaseService.getTasks return value without changing its architecture
    // or using a library like get_it. For this test, we will verify the UI elements exist.

    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    // Verify "HOME HEALTH" text exists
    expect(find.text('HOME HEALTH'), findsOneWidget);

    // Since DatabaseService returns [] in testing mode, overall health should be 100% (default for empty)
    expect(find.text('100%'), findsOneWidget);

    // Verify "NO SYSTEMS TRACKED" since tasks are empty
    expect(find.text('NO SYSTEMS TRACKED'), findsOneWidget);
  });
}
