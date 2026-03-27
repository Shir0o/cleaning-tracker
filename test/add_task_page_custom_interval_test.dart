import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/add_task_page.dart';

void main() {
  AddTaskPage.testingMode = true;

  testWidgets('AddTaskPage shows custom interval fields when CUSTOM is selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: AddTaskPage()));

    // Verify initial state
    expect(find.text('CUSTOM INTERVAL'), findsNothing);

    // Tap on CUSTOM interval button
    await tester.tap(find.text('CUSTOM'));
    await tester.pumpAndSettle();

    // Verify custom interval fields are shown
    expect(find.text('CUSTOM INTERVAL'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3)); // Name, category, and custom interval field
    expect(find.text('14'), findsOneWidget); // Default value
    expect(find.text('DAYS'), findsOneWidget); // Default unit
  });

  testWidgets('AddTaskPage allows changing custom interval unit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: AddTaskPage()));

    await tester.tap(find.text('CUSTOM'));
    await tester.pumpAndSettle();

    // Tap on dropdown
    await tester.tap(find.text('DAYS'));
    await tester.pumpAndSettle();

    // Select MONTHS
    await tester.tap(find.text('MONTHS').last);
    await tester.pumpAndSettle();

    expect(find.text('MONTHS'), findsOneWidget);
  });
}
