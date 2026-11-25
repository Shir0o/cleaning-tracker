import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleaning_tracker/main.dart';
import 'package:cleaning_tracker/database_service.dart';
import 'package:cleaning_tracker/log_history_page.dart';
import 'package:cleaning_tracker/models.dart';
import 'package:cleaning_tracker/privacy_policy_page.dart';
import 'package:cleaning_tracker/settings_tab.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DashboardScreen.testingMode = true;
    DatabaseService.testingMode = true;
    LogHistoryPage.testingMode = true;
    PrivacyPolicyPage.testingMode = true;
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
    themeNotifier.value = ThemeMode.light;
  });

  /// Runs [body] with the semantics tree enabled and guarantees the handle is
  /// released. The handle is disposed in `finally` because flutter_test
  /// verifies outstanding handles before `addTearDown` callbacks run; the
  /// teardown registration remains as an idempotent safety net.
  Future<void> withSemantics(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    final handle = tester.ensureSemantics();
    var disposed = false;
    void disposeHandle() {
      if (disposed) return;
      disposed = true;
      handle.dispose();
    }

    addTearDown(disposeHandle);
    try {
      await body();
    } finally {
      disposeHandle();
    }
  }

  /// Applies the requested viewport/text-scale for one test and registers a
  /// teardown that restores the binding defaults.
  void configureView(
    WidgetTester tester, {
    required Size size,
    required double textScale,
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
  }

  /// Captures the golden (only while `--update-goldens` is active), then runs
  /// the overflow and accessibility guidelines for the current screen.
  Future<void> captureAndAudit(
    WidgetTester tester, {
    required String name,
  }) async {
    await tester.pumpAndSettle();

    // Goldens are captured before guideline assertions so a failing guideline
    // still leaves a rendered image behind for review.
    if (autoUpdateGoldenFiles) {
      await expectLater(
        find.byType(CleaningTrackerApp),
        matchesGoldenFile('goldens/ui_ux_audit_$name.png'),
      );
    }

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  /// Asserts that the ring gauge's inner labels stay inside the painted ring
  /// with at least 4px of radial clearance from the stroke's inner edge.
  void expectRingLabelsInsideInnerCircle(WidgetTester tester) {
    final ringFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is RingGaugePainter,
    );
    expect(ringFinder, findsOneWidget);

    final painter =
        tester.widget<CustomPaint>(ringFinder).painter! as RingGaugePainter;
    final ringRect = tester.getRect(ringFinder);
    final center = ringRect.center;

    // The painter centers the stroke on (width - strokeWidth) / 2, so the
    // stroke's inner edge sits strokeWidth / 2 inside that radius.
    final strokeRadius = (ringRect.width - painter.strokeWidth) / 2;
    final innerRadius = strokeRadius - painter.strokeWidth / 2;
    const minClearance = 4.0;

    final labelFinders = <Finder>[
      find.descendant(of: ringFinder, matching: find.byType(FittedBox)),
      find.descendant(of: ringFinder, matching: find.textContaining('%')),
      find.descendant(of: ringFinder, matching: find.text('Cleanliness')),
    ];

    for (final finder in labelFinders) {
      expect(finder, findsWidgets);
      for (final element in finder.evaluate()) {
        final box = element.renderObject! as RenderBox;
        final rect = MatrixUtils.transformRect(
          box.getTransformTo(null),
          Offset.zero & box.size,
        );
        for (final corner in [
          rect.topLeft,
          rect.topRight,
          rect.bottomLeft,
          rect.bottomRight,
        ]) {
          final distance = (corner - center).distance;
          expect(
            distance,
            lessThanOrEqualTo(innerRadius - minClearance),
            reason:
                'Ring label corner $corner is ${distance.toStringAsFixed(1)}px '
                'from the ring centre; it must stay at least '
                '${minClearance}px inside the '
                '${innerRadius.toStringAsFixed(1)}px inner radius.',
          );
        }
      }
    }
  }

  Future<void> renderVariant(
    WidgetTester tester, {
    required String variantName,
    required Size size,
    required double textScale,
    required ThemeMode themeMode,
  }) async {
    configureView(tester, size: size, textScale: textScale);

    themeNotifier.value = themeMode;

    await tester.pumpWidget(const CleaningTrackerApp());
    await captureAndAudit(tester, name: variantName);
  }

  testWidgets('phone_light (390x844 @ 1.0x)', (WidgetTester tester) async {
    await withSemantics(tester, () async {
      await renderVariant(
        tester,
        variantName: 'phone_light',
        size: const Size(390, 844),
        textScale: 1.0,
        themeMode: ThemeMode.light,
      );
    });
  });

  testWidgets('phone_dark (390x844 @ 1.0x)', (WidgetTester tester) async {
    await withSemantics(tester, () async {
      await renderVariant(
        tester,
        variantName: 'phone_dark',
        size: const Size(390, 844),
        textScale: 1.0,
        themeMode: ThemeMode.dark,
      );
    });
  });

  testWidgets('small_large_font (320x568 @ 1.6x)', (WidgetTester tester) async {
    await withSemantics(tester, () async {
      await renderVariant(
        tester,
        variantName: 'small_large_font',
        size: const Size(320, 568),
        textScale: 1.6,
        themeMode: ThemeMode.light,
      );
    });
  });

  testWidgets('stats_small_large_font (320x568 @ 1.6x)', (
    WidgetTester tester,
  ) async {
    await withSemantics(tester, () async {
      configureView(tester, size: const Size(320, 568), textScale: 1.6);
      themeNotifier.value = ThemeMode.light;

      await tester.pumpWidget(const CleaningTrackerApp());
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await captureAndAudit(tester, name: 'stats_small_large_font');
      expectRingLabelsInsideInnerCircle(tester);
    });
  });

  testWidgets('interactive click-through E2E (390x844 @ 1.0x light)', (
    WidgetTester tester,
  ) async {
    await withSemantics(tester, () async {
      configureView(tester, size: const Size(390, 844), textScale: 1.0);
      themeNotifier.value = ThemeMode.light;

      await tester.pumpWidget(const CleaningTrackerApp());
      await captureAndAudit(tester, name: 'e2e_due_tab');

      // ---------------------------------------------------------------
      // Due tab -> task detail overlay
      // ---------------------------------------------------------------
      await tester.tap(find.text('CLEAN SHOWER'));
      await captureAndAudit(tester, name: 'e2e_task_detail');

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // Due tab -> add task sheet -> custom task form
      // ---------------------------------------------------------------
      await tester.tap(find.byIcon(Icons.add));
      await captureAndAudit(tester, name: 'e2e_add_task_sheet');

      final addSheetScrollable = find
          .descendant(
            of: find.byType(Positioned),
            matching: find.byType(Scrollable),
          )
          .last;
      await tester.scrollUntilVisible(
        find.text('Create Custom Task'),
        400,
        scrollable: addSheetScrollable,
      );
      await tester.tap(find.text('Create Custom Task'));
      await captureAndAudit(tester, name: 'e2e_custom_task_form');

      await tester.enterText(find.byType(TextField).first, 'AUDIT TEST TASK');
      await tester.pumpAndSettle();

      // Back out of the custom form, then close the add task sheet.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // Rooms tab
      // ---------------------------------------------------------------
      await tester.tap(find.byIcon(Icons.grid_view_outlined));
      await captureAndAudit(tester, name: 'e2e_rooms_tab');

      // ---------------------------------------------------------------
      // Stats tab
      // ---------------------------------------------------------------
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await captureAndAudit(tester, name: 'e2e_stats_tab');
      expectRingLabelsInsideInnerCircle(tester);

      // ---------------------------------------------------------------
      // Settings tab
      // ---------------------------------------------------------------
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await captureAndAudit(tester, name: 'e2e_settings_tab');

      // Reminder time picker (modal bottom sheet).
      await tester.tap(find.text('Time'));
      await captureAndAudit(tester, name: 'e2e_settings_time_sheet');
      await tester.tap(find.text('7:00 PM'));
      await tester.pumpAndSettle();

      // Heads-up picker (modal bottom sheet).
      await tester.tap(find.text('Heads-up'));
      await captureAndAudit(tester, name: 'e2e_settings_heads_up_sheet');
      await tester.tap(find.text('1 week'));
      await tester.pumpAndSettle();

      // Appearance selector (below the fold on a 390x844 phone).
      final settingsScrollable = find.descendant(
        of: find.byType(SettingsTab),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Dark'),
        300,
        scrollable: settingsScrollable,
      );
      await tester.drag(settingsScrollable, const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      expect(themeNotifier.value, ThemeMode.dark);
      await captureAndAudit(tester, name: 'e2e_settings_dark_theme');
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(themeNotifier.value, ThemeMode.light);

      // About rows live below the fold.
      await tester.scrollUntilVisible(
        find.text('Privacy policy'),
        300,
        scrollable: settingsScrollable,
      );
      await captureAndAudit(tester, name: 'e2e_settings_about_section');

      // Cleaning history secondary screen.
      await tester.tap(find.text('Cleaning history'));
      await captureAndAudit(tester, name: 'e2e_log_history_page');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Privacy policy secondary screen.
      await tester.tap(find.text('Privacy policy'));
      await captureAndAudit(tester, name: 'e2e_privacy_policy_page');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });
  });
}
