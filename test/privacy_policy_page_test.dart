import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/privacy_policy_page.dart';

void main() {
  setUpAll(() {
    PrivacyPolicyPage.testingMode = true;
  });

  testWidgets('PrivacyPolicyPage renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));

    // Verify Title
    expect(find.text('PRIVACY POLICY'), findsOneWidget);

    // Verify Section Headers
    expect(find.text('01. DATA COLLECTION'), findsOneWidget);
    expect(find.text('02. GOOGLE DRIVE SYNC'), findsOneWidget);
    expect(find.text('03. THIRD-PARTY SERVICES'), findsOneWidget);
    expect(find.text('04. YOUR RIGHTS'), findsOneWidget);

    // Verify presence of some body text
    expect(
      find.textContaining(
        'Cleaning Tracker is designed with a "Local First" philosophy.',
      ),
      findsOneWidget,
    );

    // Verify footer
    expect(find.text('VERSION 1.0.0 - MARCH 2026'), findsOneWidget);
  });

  testWidgets('PrivacyPolicyPage back button works', (
    WidgetTester tester,
  ) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              ),
              child: const Text('Go to Privacy Policy'),
            ),
          ),
        ),
      ),
    );

    // Navigate to PrivacyPolicyPage
    await tester.tap(find.text('Go to Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we are back
    expect(find.byType(PrivacyPolicyPage), findsNothing);
  });
}
