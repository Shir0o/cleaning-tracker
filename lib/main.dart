import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'add_task_page.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';
import 'secrets.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Temporary placeholder since secrets.dart is in .gitignore
const String fallbackGoogleServerClientId = 'test_client_id';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DashboardScreen.testingMode) {
    try {
      // Initialize Google Sign In globally
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
      );
    } catch (e) {
      debugPrint('Global GoogleSignIn initialization failed: $e');
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

class CleaningTrackerApp extends StatelessWidget {
  const CleaningTrackerApp({super.key});

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
  final List<String> _tasks = [];

  StreamSubscription? _authSubscription;

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (DashboardScreen.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  void initState() {
    super.initState();
    _listenToAuthEvents();
    if (DashboardScreen.testingMode) {
      _isLoading = false;
    } else {
      _startLoadingTimer();
    }
  }

  void _startLoadingTimer() {
    // Minimum animation timer to prevent flashing (e.g., 800ms)
    _loadingTimer = Timer(const Duration(milliseconds: 800), () {
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

    // Check if user is already signed in (silent sign-in result)
    GoogleSignIn.instance.attemptLightweightAuthentication()?.then((account) {
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
    }).catchError((e) {
      debugPrint('Lightweight auth check failed in dashboard: $e');
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
                  itemBuilder: (context, index) => TaskCard(
                    title: _tasks[index],
                    dueDateText: 'FRESH START',
                    progress: 1.0,
                    isOverdue: false,
                    isFresh: true,
                  ),
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
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (context) => const AddTaskPage()),
              );
              if (result != null && mounted) {
                setState(() {
                  _tasks.add(result);
                });
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
  final String dueDateText;
  final double progress;
  final bool isOverdue;
  final bool isFresh;

  const TaskCard({
    super.key,
    required this.title,
    required this.dueDateText,
    required this.progress,
    required this.isOverdue,
    this.isFresh = false,
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskDetailPage(
                  title: title,
                  dueDateText: dueDateText,
                  progress: progress,
                  isOverdue: isOverdue,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: _safeGoogleFont(
                        () => GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                    ),
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
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        border:
                            progress < 1.0 ||
                                isFresh // Add right border if not completely full, or if it's the 100% fresh state
                            ? Border(
                                right: BorderSide(
                                  color: colorScheme.onSurface,
                                  width: 2,
                                ),
                              )
                            : null, // Full overdue bar has no inner border
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
