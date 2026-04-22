import 'package:intl/intl.dart';

class Task {
  final int? id;
  final String title;
  final String interval;
  final DateTime lastCompleted;
  final String category;
  final String notes;
  final List<DateTime> completions;
  final DateTime? snoozedUntil;

  Task({
    this.id,
    required this.title,
    required this.interval,
    required this.lastCompleted,
    this.category = 'GENERAL',
    this.notes = '',
    this.completions = const [],
    this.snoozedUntil,
  });

  Task copyWith({
    int? id,
    String? title,
    String? interval,
    DateTime? lastCompleted,
    String? category,
    String? notes,
    List<DateTime>? completions,
    DateTime? snoozedUntil,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      interval: interval ?? this.interval,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      completions: completions ?? this.completions,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'interval': interval,
    'lastCompleted': lastCompleted.toIso8601String(),
    'category': category,
    'notes': notes,
    'completions': completions.map((e) => e.toIso8601String()).toList(),
    if (snoozedUntil != null) 'snoozedUntil': snoozedUntil!.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as int?,
    title: json['title'] as String,
    interval: json['interval'] as String,
    lastCompleted: json['lastCompleted'] != null
        ? DateTime.parse(json['lastCompleted'] as String)
        : DateTime.now(),
    category: (json['category'] as String?) ?? 'GENERAL',
    notes: (json['notes'] as String?) ?? '',
    completions:
        (json['completions'] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        [],
    snoozedUntil: json['snoozedUntil'] != null
        ? DateTime.parse(json['snoozedUntil'] as String)
        : null,
  );

  Duration get intervalDuration {
    final parts = interval.split(' ');
    if (parts.length == 2) {
      final value = int.tryParse(parts[0]) ?? 1;
      final unit = parts[1].toUpperCase();
      if (unit == 'DAYS') return Duration(days: value);
      if (unit == 'WEEKS') return Duration(days: value * 7);
      if (unit == 'MONTHS') return Duration(days: value * 30);
    }
    // Fallbacks for presets
    if (interval == 'DAILY') return const Duration(days: 1);
    if (interval == 'WEEKLY') return const Duration(days: 7);
    if (interval == 'MONTHLY') return const Duration(days: 30);
    if (interval == '1 YEAR') return const Duration(days: 365);
    if (interval == '3 MONTHS') return const Duration(days: 90);
    return const Duration(days: 7); // Default
  }

  double health(DateTime now) {
    if (snoozedUntil != null && now.isBefore(snoozedUntil!)) {
      return 1.0;
    }
    final total = intervalDuration.inSeconds;
    final elapsed = now.difference(lastCompleted).inSeconds;
    return (total - elapsed) / total;
  }

  bool isUrgent(DateTime now) {
    if (snoozedUntil != null && now.isBefore(snoozedUntil!)) {
      return false;
    }
    return health(now) < 0.25;
  }

  String statusText(DateTime now) {
    if (snoozedUntil != null && now.isBefore(snoozedUntil!)) {
      return 'SNOOZED';
    }
    final h = health(now);
    if (h >= 0.85) return 'OPERATIONAL';
    if (h >= 0.25) return 'DEGRADING';
    if (h >= 0.0) return 'CRITICAL';
    final diff = lastCompleted.add(intervalDuration).difference(now);
    return '${diff.inDays.abs()} DAYS OVERDUE';
  }

  String dueDateText(DateTime now) {
    final dueDate = lastCompleted.add(intervalDuration);
    final diff = dueDate.difference(now);
    final absoluteDate = DateFormat('MMM d').format(dueDate).toUpperCase();

    if (diff.isNegative) {
      return '$absoluteDate (-${diff.inDays.abs()} DAYS)';
    } else {
      return '$absoluteDate (${diff.inDays} DAYS)';
    }
  }

  String? get suggestedInterval {
    if (completions.length < 3) return null;

    // Calculate average days between completions
    final List<DateTime> sortedCompletions = List.from(completions)..sort();
    final List<int> deltas = [];

    for (int i = 1; i < sortedCompletions.length; i++) {
      deltas.add(
        sortedCompletions[i].difference(sortedCompletions[i - 1]).inDays,
      );
    }

    if (deltas.isEmpty) return null;

    final double averageDays = deltas.reduce((a, b) => a + b) / deltas.length;
    final int roundedAverage = averageDays.round();

    if (roundedAverage <= 0) return null;

    final int currentDays = intervalDuration.inDays;

    // Only suggest if the difference is more than 10% AND at least 1 day
    final double diff = (roundedAverage - currentDays).abs().toDouble();
    final double percentDiff = diff / currentDays;

    if (diff >= 1 && percentDiff > 0.1) {
      return '$roundedAverage DAYS';
    }

    return null;
  }
}

class TaskCompletion {
  final String taskTitle;
  final DateTime completionDate;

  TaskCompletion({required this.taskTitle, required this.completionDate});
}
