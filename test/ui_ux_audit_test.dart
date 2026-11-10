import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DashboardScreen.testingMode = true;
    DatabaseService.testingMode = true;
    final now = DateTime.now();
    DatabaseService.mockTasks = [
      Task(
        id: 1,
        title: 'WASH DISHES',
        interval: 'DAILY',
        lastCompleted: now.subtract(const Duration(hours: 4)),
        category: 'KITCHEN',
      ),
      Task(
        id: 2,
        title: 'CLEAN SHOWER',
        interval: 'WEEKLY',
        lastCompleted: now.subtract(const Duration(days: 8)),
        category: 'BATHROOM',
      ),
      Task(
        id: 3,
        title: 'WASH BED SHEETS',
        interval: '2 WEEKS',
        lastCompleted: now.subtract(const Duration(days: 3)),
        category: 'BEDROOM',
      ),
    ];
  });

  tearDown(() {
    DatabaseService.mockTasks = null;
  });

  Future<void> renderVariant(
    WidgetTester tester, {
    required String variantName,
    required Size size,
    required double textScale,
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    themeNotifier.value = themeMode;

    await tester.pumpWidget(const CleaningTrackerApp());
    await tester.pumpAndSettle();

    if (autoUpdateGoldenFiles) {
      await expectLater(
        find.byType(CleaningTrackerApp),
        matchesGoldenFile('goldens/ui_ux_audit_$variantName.png'),
      );
    }

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  testWidgets('phone_light (390x844 @ 1.0x)', (WidgetTester tester) async {
    await renderVariant(
      tester,
      variantName: 'phone_light',
      size: const Size(390, 844),
      textScale: 1.0,
      themeMode: ThemeMode.light,
    );
  });

  testWidgets('phone_dark (390x844 @ 1.0x)', (WidgetTester tester) async {
    await renderVariant(
      tester,
      variantName: 'phone_dark',
      size: const Size(390, 844),
      textScale: 1.0,
      themeMode: ThemeMode.dark,
    );
  });

  testWidgets('small_large_font (320x568 @ 1.6x)', (WidgetTester tester) async {
    await renderVariant(
      tester,
      variantName: 'small_large_font',
      size: const Size(320, 568),
      textScale: 1.6,
      themeMode: ThemeMode.light,
    );
  });
}
