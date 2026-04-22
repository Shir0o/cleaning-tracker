import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/presets_page.dart';

void main() {
  setUp(() {
    PresetsPage.testingMode = true;
  });

  testWidgets('PresetsPage shows all home-related categories and items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PresetsPage()));

    // Verify Categories
    expect(find.text('KITCHEN'), findsOneWidget);
    expect(find.text('BATHROOM'), findsOneWidget);
    expect(find.text('BEDROOM'), findsOneWidget);
    expect(find.text('LIVING & GENERAL'), findsOneWidget);
    expect(find.text('LAUNDRY & UTILITY'), findsOneWidget);

    // Verify some items in each category
    expect(find.text('WASH DISHES'), findsOneWidget);
    expect(find.text('WIPE UP BATHROOMS'), findsOneWidget);
    expect(find.text('MAKE BEDS'), findsOneWidget);
    expect(find.text('GENERAL PICK UP'), findsOneWidget);
    expect(find.text('LOAD OF LAUNDRY'), findsOneWidget);
  });

  testWidgets('Tapping a preset returns correct data', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Map<String, dynamic>? selectedPreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              selectedPreset = await Navigator.of(context)
                  .push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (context) => const PresetsPage(),
                    ),
                  );
            },
            child: const Text('OPEN'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    // Tap WASH DISHES
    await tester.tap(find.text('WASH DISHES'));
    await tester.pumpAndSettle();

    expect(selectedPreset, isNotNull);
    expect(selectedPreset!['name'], 'WASH DISHES');
    expect(selectedPreset!['interval'], 'DAILY');
    expect(selectedPreset!['category'], 'KITCHEN');
  });
}
