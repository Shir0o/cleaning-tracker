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
import 'secrets.dart';
import 'drive_service.dart';
import 'dart:convert';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class Task {
  final String title;
  final String interval;
  final DateTime lastCompleted;
  final Map<String, String> specs;

  Task({
    required this.title,
    required this.interval,
    required this.lastCompleted,
    Map<String, String>? specs,
  }) : specs = specs ?? {'SPEC 1': 'N/A', 'SPEC 2': 'N/A'};

  Task copyWith({
    String? title,
    String? interval,
    DateTime? lastCompleted,
    Map<String, String>? specs,
  }) {
    return Task(
      title: title ?? this.title,
      interval: interval ?? this.interval,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      specs: specs ?? this.specs,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'interval': interval,
        'lastCompleted': lastCompleted.toIso8601String(),
        'specs': specs,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'] as String,
        interval: json['interval'] as String,
        lastCompleted: json['lastCompleted'] != null
            ? DateTime.parse(json['lastCompleted'] as String)
            : DateTime.now(),
        specs: json['specs'] != null
            ? Map<String, String>.from(json['specs'] as Map)
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
    final total = intervalDuration.inSeconds;
    final elapsed = now.difference(lastCompleted).inSeconds;
    return (total - elapsed) / total;
  }

  String statusText(DateTime now) {
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

class _CleaningTrackerAppState extends State<CleaningTrackerApp> with WidgetsBindingObserver {
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
  GoogleSignInAccount? _currentUser;
  bool _isLoading = true;
  Timer? _loadingTimer;
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
    if (DashboardScreen.testingMode) {
      _isLoading = false;
    } else {
      _startLoadingTimer();
    }
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final taskStrings = prefs.getStringList('tasks') ?? [];
      setState(() {
        _tasks = taskStrings
            .map((s) => Task.fromJson(jsonDecode(s) as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = _tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  void _startLoadingTimer() {
    // Minimum animation timer to prevent flashing (e.g., 1500ms)
    _loadingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _listenToAuthEvents() {
    if (DashboardScreen.testingMode) return;

    // Listen for changes
    _authSubscription = GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (mounted) {
        setState(() {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _currentUser = event.user;
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            _currentUser = null;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
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
          : _tasks.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
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
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final now = DateTime.now();
                    final health = task.health(now);
                    final isOverdue = health < 0;

                    return TaskCard(
                      title: task.title,
                      interval: task.interval,
                      dueDateText: task.dueDateText(now),
                      progress: health,
                      isOverdue: isOverdue,
                      isFresh: now.difference(task.lastCompleted).inSeconds < 3600, // Show fresh if completed in last hour
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskDetailPage(
                              task: task,
                            ),
                          ),
                        );

                        if (result == 'delete') {
                          setState(() {
                            _tasks.removeAt(index);
                          });
                          await _saveTasks();
                        } else if (result is Task) {
                          setState(() {
                            _tasks[index] = result;
                          });
                          await _saveTasks();
                        }
                      },
                    );
                  },
                ),
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
              final result = await Navigator.of(context).push<Map<String, String>>(
                MaterialPageRoute(builder: (context) => const AddTaskPage()),
              );
              if (result != null && mounted) {
                setState(() {
                  _tasks.add(Task(
                    title: result['name']!,
                    interval: result['interval']!,
                    lastCompleted: DateTime.now(),
                  ));
                });
                await _saveTasks();
              }
            },
            child: Icon(Icons.add, color: colorScheme.surface, size: 32),
          ),
        ),
      ),
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
                Container(
                  width: 120,
                  height: 24,
                  color: Colors.white,
                ),
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 24,
              width: double.infinity,
              color: Colors.white,
            ),
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
        border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
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
                    color: theme.brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4), // Surface color from Stitch
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isOverdue ? 1.0 : progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        border:
                            (isOverdue) || (progress <= 0.0) || (!isFresh && progress >= 1.0)
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
