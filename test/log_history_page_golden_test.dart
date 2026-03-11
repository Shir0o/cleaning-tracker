import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  group('LogHistoryPage Golden Tests', () {
    setUpAll(() {
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    testWidgets('Log History Page matches golden image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LogHistoryPage(),
        ),
      );

      // Wait for fonts to load
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LogHistoryPage),
        matchesGoldenFile('goldens/log_history_page.png'),
      );
    });
  });
}
