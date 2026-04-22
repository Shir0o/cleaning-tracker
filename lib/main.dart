import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import 'add_task_page.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';
import 'drive_service.dart';
import 'notification_service.dart';
import 'database_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

const String googleServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: 'dummy_client_id');

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DashboardScreen.testingMode) {
    try {
      // Initialize Google Sign In globally
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
      );
      // Initialize DriveService
      await DriveService().init();
      // Initialize Database and Migrate
      await DatabaseService().migrateFromSharedPreferences();
      // Initialize NotificationService
      await NotificationService().init();
    } catch (e) {
      debugPrint('Global initialization failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('interfaceTheme') ?? 'LIGHT';
  if (savedTheme == 'DARK') {
    themeNotifier.value = ThemeMode.dark;
  } else if (savedTheme == 'SYSTEM') {
    themeNotifier.value = ThemeMode.system;
  } else {
    themeNotifier.value = ThemeMode.light;
  }

  runApp(const CleaningTrackerApp());
}

class CleaningTrackerApp extends StatefulWidget {
  const CleaningTrackerApp({super.key});

  @override
  State<CleaningTrackerApp> createState() => _CleaningTrackerAppState();
}

class _CleaningTrackerAppState extends State<CleaningTrackerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Trigger sync when app is backgrounded
      DriveService().syncFiles().catchError((e) {
        debugPrint('Background sync failed: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Cleaning Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,
          theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF0038FF), // Primary blue from Stitch
              onPrimary: Colors.white,
              secondary: Color(0xFF0038FF),
              onSecondary: Colors.white,
              error: Color(0xFFFF0000), // Accent red from Stitch
              onError: Colors.white,
              surface: Colors
                  .white, // Background light from Stitch (using surface instead of background)
              onSurface: Colors.black,
            ),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: GoogleFonts.inter()
                .fontFamily, // Satoshi missing, using Inter as a similar clean grotesque font
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFF0038FF), // Primary blue from Stitch
              onPrimary: Colors.white,
              secondary: Color(0xFF0038FF),
              onSecondary: Colors.white,
              error: Color(0xFFFF0000), // Accent red from Stitch
              onError: Colors.white,
              surface: Colors.black, // Background dark from Stitch
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.black,
            fontFamily: GoogleFonts.inter()
                .fontFamily, // Satoshi missing, using Inter as a similar clean grotesque font
            useMaterial3: true,
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  static bool testingMode = false;

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<Task> _tasks = [];

  StreamSubscription? _authSubscription;

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (DashboardScreen.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _listenToAuthEvents();
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      final tasks = await DatabaseService().getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTasks() async {
    final tasks = await DatabaseService().getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
      });
    }
    // Update notifications whenever tasks are refreshed/changed
    NotificationService().rescheduleAll(_tasks);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthEvents() {
    if (DashboardScreen.testingMode) return;

    // Listen for changes
    _authSubscription = GoogleSignIn.instance.authenticationEvents.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          // Trigger refresh if needed
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
        title: Text(
          'STATUS',
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.onSurface, width: 2),
              color: colorScheme.surface,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.settings,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 3,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => const ShimmerCard(),
            )
          : () {
              final Map<String, List<Task>> groupedTasks = {};
              final List<Task> urgentTasks = [];
              double totalHealth = 0.0;

              for (var task in _tasks) {
                final h = task.health(now);
                totalHealth += h.clamp(0.0, 1.0);
                if (task.isUrgent(now)) {
                  urgentTasks.add(task);
                } else {
                  groupedTasks.putIfAbsent(task.category, () => []).add(task);
                }
              }

              final int overallHealth = _tasks.isEmpty
                  ? 100 // Default to 100% if no tasks
                  : ((totalHealth / _tasks.length) * 100).round();
              final bool isHomeCritical = overallHealth < 50;

              final categories = groupedTasks.keys.toList()..sort();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overall Health Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.onSurface,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'HOME HEALTH',
                          style: _safeGoogleFont(
                            () => GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2.0,
                              color: const Color(0xFF8A8A8A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$overallHealth%',
                          style: _safeGoogleFont(
                            () => GoogleFonts.chivoMono(
                              fontWeight: FontWeight.bold,
                              fontSize: 64,
                              height: 1.0,
                              color: isHomeCritical
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'NO SYSTEMS TRACKED',
                          style: _safeGoogleFont(
                            () => GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -0.5,
                              color: const Color(0xFF8A8A8A),
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Priority Section
                    if (urgentTasks.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Text(
                          'PRIORITY ACTIONS',
                          style: _safeGoogleFont(
                            () => GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2.0,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      ...urgentTasks.map(
                        (task) => _buildTaskRow(task, now, context),
                      ),
                    ],

                    // Categories
                    ...categories.expand((category) {
                      final tasksInCategory = groupedTasks[category]!;
                      return [
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: _safeGoogleFont(
                                  () => GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 2.0,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _showCategoryResetConfirmation(category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'RESET CATEGORY',
                                    style: _safeGoogleFont(
                                      () => GoogleFonts.chivoMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...tasksInCategory.map(
                          (task) => _buildTaskRow(task, now, context),
                        ),
                      ];
                    }),
                  ],
                ],
              );
            }(),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          border: Border.all(color: colorScheme.onSurface, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.of(context)
                  .push<Map<String, String>>(
                    MaterialPageRoute(
                      builder: (context) => const AddTaskPage(),
                    ),
                  );
              if (result != null && mounted) {
                final newTask = Task(
                  title: result['name']!,
                  interval: result['interval']!,
                  category: result['category'] ?? 'GENERAL',
                  lastCompleted: DateTime.now(),
                );
                await DatabaseService().insertTask(newTask);
                await _refreshTasks();
              }
            },
            child: Icon(Icons.add, color: colorScheme.surface, size: 32),
          ),
        ),
      ),
    );
  }

  void _showCategoryResetConfirmation(String category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.onSurface, width: 4),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESET ALL TASKS?',
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'THIS WILL MARK ALL TASKS IN "$category" AS COMPLETED TODAY.',
                  style: _safeGoogleFont(
                    () => GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            side: BorderSide(
                              color: colorScheme.onSurface,
                              width: 2,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'CANCEL',
                            style: _safeGoogleFont(
                              () => GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await DatabaseService().resetCategory(
                              category,
                              DateTime.now(),
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                              _refreshTasks();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'All tasks in $category reset.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'RESET ALL',
                            style: _safeGoogleFont(
                              () => GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskRow(Task task, DateTime now, BuildContext context) {
    final health = task.health(now);
    final isOverdue = (health * 100).round() <= 0;
    final isFresh = now.difference(task.lastCompleted).inSeconds < 3600;

    return TaskCard(
      title: task.title,
      interval: task.interval,
      dueDateText: task.dueDateText(now),
      progress: health,
      isOverdue: isOverdue,
      isFresh: isFresh,
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
        );

        if (result == 'delete') {
          await DatabaseService().deleteTask(task.id!);
          await _refreshTasks();
        } else if (result is Task) {
          await DatabaseService().updateTask(result);
          await _refreshTasks();
        }
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 120, height: 24, color: Colors.white),
                Container(width: 80, height: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 24, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  static bool testingMode = false;

  final String title;
  final String interval;
  final String dueDateText;
  final double progress;
  final bool isOverdue;
  final bool isFresh;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.interval,
    required this.dueDateText,
    required this.progress,
    required this.isOverdue,
    this.isFresh = false,
    this.onTap,
  });

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textColor = isOverdue ? colorScheme.error : colorScheme.onSurface;
    final progressColor = isOverdue ? colorScheme.error : colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
      child: Material(
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: _safeGoogleFont(
                          () => GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: textColor,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dueDateText,
                      style: _safeGoogleFont(
                        () => GoogleFonts.chivoMono(
                          fontSize: 14,
                          letterSpacing: 2.0,
                          color: textColor,
                          fontWeight: isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF4F4F4), // Surface color from Stitch
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isOverdue ? 1.0 : progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        border:
                            (isOverdue) ||
                                (progress <= 0.0) ||
                                (!isFresh && progress >= 1.0)
                            ? null // Full bar has no inner border
                            : Border(
                                right: BorderSide(
                                  color: colorScheme.onSurface,
                                  width: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
