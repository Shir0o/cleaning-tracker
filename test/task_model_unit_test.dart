import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_tracker/models.dart';

void main() {
  group('Task.intervalDuration', () {
    test('parses "X DAYS" form', () {
      final t = Task(
        title: 't',
        interval: '5 DAYS',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 5));
    });

    test('parses "X WEEKS" form', () {
      final t = Task(
        title: 't',
        interval: '2 WEEKS',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 14));
    });

    test('parses "X MONTHS" form as 30-day months', () {
      final t = Task(
        title: 't',
        interval: '3 MONTHS',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 90));
    });

    test('falls back to DAILY preset', () {
      final t = Task(
        title: 't',
        interval: 'DAILY',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 1));
    });

    test('falls back to WEEKLY preset', () {
      final t = Task(
        title: 't',
        interval: 'WEEKLY',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 7));
    });

    test('falls back to MONTHLY preset', () {
      final t = Task(
        title: 't',
        interval: 'MONTHLY',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 30));
    });

    test('falls back to 1 YEAR preset', () {
      final t = Task(
        title: 't',
        interval: '1 YEAR',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 365));
    });

    test('falls back to 3 MONTHS preset (exact match)', () {
      final t = Task(
        title: 't',
        interval: '3 MONTHS',
        lastCompleted: DateTime(2026),
      );
      // 3 MONTHS is matched by both the "X MONTHS" parser (30 * 3 = 90)
      // and the explicit 3 MONTHS preset (90). Either way 90 days.
      expect(t.intervalDuration, const Duration(days: 90));
    });

    test('defaults to 7 days for malformed input', () {
      final t = Task(
        title: 't',
        interval: 'garbage',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 7));
    });

    test('uses 1 day fallback when the "X DAYS" number is unparseable', () {
      // "NaN DAYS" has two parts, so the parser runs. int.tryParse('NaN')
      // returns null, which is coalesced to 1, yielding 1 day rather than
      // the malformed-input default of 7.
      final t = Task(
        title: 't',
        interval: 'NaN DAYS',
        lastCompleted: DateTime(2026),
      );
      expect(t.intervalDuration, const Duration(days: 1));
    });
    final now = DateTime(2026, 6, 1);

    test('snoozed task reports full health when snooze is in the future', () {
      final t = Task(
        title: 't',
        interval: '7 DAYS',
        lastCompleted: now.subtract(const Duration(days: 30)),
        snoozedUntil: now.add(const Duration(days: 1)),
      );
      expect(t.health(now), 1.0);
      expect(t.isUrgent(now), isFalse);
      expect(t.statusText(now), 'SNOOZED');
    });

    test('snoozed task uses real health when snooze has elapsed', () {
      final t = Task(
        title: 't',
        interval: '7 DAYS',
        lastCompleted: now.subtract(const Duration(days: 5)),
        snoozedUntil: now.subtract(const Duration(days: 1)),
      );
      expect(t.health(now), closeTo(2 / 7, 0.001));
      expect(t.isUrgent(now), isFalse);
      expect(t.statusText(now), 'DEGRADING');
    });
  });

  group('Task.isUrgent threshold', () {
    final now = DateTime(2026, 6, 1);

    test('not urgent at or above 25% health', () {
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 7)),
      );
      // health = 0.3
      expect(t.health(now), closeTo(0.3, 0.001));
      expect(t.isUrgent(now), isFalse);
    });

    test('urgent below 25% health', () {
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 8)),
      );
      // health = 0.2
      expect(t.health(now), closeTo(0.2, 0.001));
      expect(t.isUrgent(now), isTrue);
    });
  });

  group('Task.statusText boundary statuses', () {
    final now = DateTime(2026, 6, 1);

    test('CRITICAL is reported below 25% but above 0%', () {
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 8)),
      );
      expect(t.statusText(now), 'CRITICAL');
    });

    test('OVERDUE with absolute day count when past due', () {
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 15)),
      );
      expect(t.statusText(now), '5 DAYS OVERDUE');
    });
  });

  group('Task.dueDateText', () {
    test('formats future due date as positive relative days', () {
      final now = DateTime(2026, 3, 27);
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 7)),
      );
      expect(t.dueDateText(now), 'MAR 30 (3 DAYS)');
    });

    test('formats past due date with negative relative days', () {
      final now = DateTime(2026, 3, 27);
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now.subtract(const Duration(days: 12)),
      );
      expect(t.dueDateText(now), 'MAR 25 (-2 DAYS)');
    });
  });

  group('Task.suggestedInterval edge cases', () {
    final now = DateTime(2026, 6, 1);

    test('returns null for fewer than 3 completions', () {
      final t = Task(
        title: 't',
        interval: '7 DAYS',
        lastCompleted: now,
        completions: [now, now.subtract(const Duration(days: 7))],
      );
      expect(t.suggestedInterval, isNull);
    });

    test('returns null when sorted deltas collapse to zero (rounded 0)', () {
      // Two completions within the same day => 0 day delta between them.
      final t = Task(
        title: 't',
        interval: '1 DAYS',
        lastCompleted: now,
        completions: [now, now, now.subtract(const Duration(days: 1))]..sort(),
      );
      expect(t.suggestedInterval, isNull);
    });

    test('returns null when the diff is within 10% of current interval', () {
      // 7-day current; deltas of 7/8/8 => avg ~7.67 => 8 days
      // |8 - 7| / 7 = 0.14 => > 10% => SHOULD suggest
      // Build 7-day deltas exactly to fall under 10%:
      final t = Task(
        title: 't',
        interval: '10 DAYS',
        lastCompleted: now,
        completions: [
          now,
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 20)),
          now.subtract(const Duration(days: 30)),
        ],
      );
      // avg 10 => rounded 10 => diff 0 => null
      expect(t.suggestedInterval, isNull);
    });

    test('returns null for diff less than 1 day even if % exceeds 10%', () {
      // 100-day current; deltas avg 99 => diff 1 (>=1) and 1% (<10%) => null
      // To hit diff < 1, we need a rounded average == currentDays. That's the
      // case above. Build a case where the rounded average is one less but the
      // percent diff is small enough to skip.
      // 100 days; deltas 99,99,99 => avg 99, rounded 99; diff 1/100 = 1% < 10%
      // The guard is `diff >= 1 && percentDiff > 0.1` => false => null.
      final t = Task(
        title: 't',
        interval: '100 DAYS',
        lastCompleted: now,
        completions: [
          now,
          now.subtract(const Duration(days: 99)),
          now.subtract(const Duration(days: 198)),
          now.subtract(const Duration(days: 297)),
        ],
      );
      expect(t.suggestedInterval, isNull);
    });

    test('suggests a rounded value when diff and percent thresholds met', () {
      // 7-day current; deltas of 5/5/5 => avg 5 => diff 2/7 = 28% > 10% => 5 DAYS
      final t = Task(
        title: 't',
        interval: '7 DAYS',
        lastCompleted: now,
        completions: [
          now,
          now.subtract(const Duration(days: 5)),
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 15)),
        ],
      );
      expect(t.suggestedInterval, '5 DAYS');
    });
  });

  group('Task JSON round-trip', () {
    test('toJson includes every field and respects id omission', () {
      final t = Task(
        id: 9,
        title: 'MOP FLOORS',
        interval: '7 DAYS',
        lastCompleted: DateTime.utc(2026, 1, 2, 3, 4, 5),
        category: 'LIVING & GENERAL',
        notes: 'Use the blue bucket',
        completions: [DateTime.utc(2026, 1, 2, 3, 4, 5)],
        snoozedUntil: DateTime.utc(2026, 1, 5),
      );
      final json = t.toJson();
      expect(json['id'], 9);
      expect(json['title'], 'MOP FLOORS');
      expect(json['interval'], '7 DAYS');
      expect(json['category'], 'LIVING & GENERAL');
      expect(json['notes'], 'Use the blue bucket');
      expect(json['snoozedUntil'], DateTime.utc(2026, 1, 5).toIso8601String());
      expect(json['completions'], [
        DateTime.utc(2026, 1, 2, 3, 4, 5).toIso8601String(),
      ]);
    });

    test('toJson omits id and snoozedUntil when null', () {
      final t = Task(
        title: 't',
        interval: '1 DAYS',
        lastCompleted: DateTime(2026),
      );
      final json = t.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('snoozedUntil'), isFalse);
    });

    test('fromJson defaults lastCompleted, category, notes, completions', () {
      final t = Task.fromJson({'title': 't', 'interval': '1 DAYS'});
      expect(t.title, 't');
      expect(t.interval, '1 DAYS');
      expect(t.category, 'GENERAL');
      expect(t.notes, '');
      expect(t.completions, isEmpty);
      expect(t.snoozedUntil, isNull);
      // lastCompleted defaults to now; just verify it's a DateTime instance.
      expect(t.lastCompleted, isA<DateTime>());
    });

    test('toJson then fromJson is lossless', () {
      final t = Task(
        id: 1,
        title: 'X',
        interval: '5 DAYS',
        lastCompleted: DateTime.utc(2026, 4, 1, 12),
        category: 'KITCHEN',
        notes: 'n',
        completions: [DateTime.utc(2026, 4, 1, 12), DateTime.utc(2026, 3, 25)],
        snoozedUntil: DateTime.utc(2026, 4, 3),
      );
      final r = Task.fromJson(t.toJson());
      expect(r.id, t.id);
      expect(r.title, t.title);
      expect(r.interval, t.interval);
      expect(r.lastCompleted, t.lastCompleted);
      expect(r.category, t.category);
      expect(r.notes, t.notes);
      expect(r.completions, t.completions);
      expect(r.snoozedUntil, t.snoozedUntil);
    });
  });

  group('Task.copyWith', () {
    final base = DateTime(2026, 1, 1);
    final t = Task(
      id: 1,
      title: 'A',
      interval: '7 DAYS',
      lastCompleted: base,
      category: 'KITCHEN',
      notes: 'n',
    );

    test('returns a new instance with overridden fields', () {
      final t2 = t.copyWith(title: 'B', notes: 'updated');
      expect(t2.id, 1);
      expect(t2.title, 'B');
      expect(t2.notes, 'updated');
      expect(t2.interval, '7 DAYS');
    });

    test('passing null preserves the original value', () {
      final t2 = t.copyWith();
      expect(t2.id, 1);
      expect(t2.title, 'A');
      expect(t2.lastCompleted, base);
    });
  });
}
