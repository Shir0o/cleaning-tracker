import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/database_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    LogHistoryPage.testingMode = true;
    DatabaseService.testingMode = true;
  });

  group('LogHistoryPage Golden Tests', () {
    testWidgets('Log History Page matches golden image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LogHistoryPage(),
        ),
      );

      // Wait for layout
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LogHistoryPage),
        matchesGoldenFile('goldens/log_history_page.png'),
      );
    });
  });
}
