import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/main.dart';

void main() {
  setUp(() {
    DashboardScreen.testingMode = true;
  });

  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    // Verify that our title is present.
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('Due'), findsWidgets);
  });
}
