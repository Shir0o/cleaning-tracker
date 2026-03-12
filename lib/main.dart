import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_task_page.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';

void main() {
  runApp(const CleaningTrackerApp());
}

class CleaningTrackerApp extends StatelessWidget {
  const CleaningTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleaning Tracker',
      debugShowCheckedModeBanner: false,
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
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  static bool testingMode = false;

  const DashboardScreen({super.key});

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (testingMode) return const TextStyle();
    return fontFn();
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
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        title: Text(
          'STATUS',
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
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
                child: const Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
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
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddTaskPage()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
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

    final textColor = isOverdue ? colorScheme.error : Colors.black;
    final progressColor = isOverdue ? colorScheme.error : colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
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
                    color: const Color(
                      0xFFF4F4F4,
                    ), // Surface color from Stitch (hardcoding since we used the Surface slot for background earlier)
                    border: Border.all(color: Colors.black, width: 2),
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
                            ? const Border(
                                right: BorderSide(
                                  color: Colors.black,
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
