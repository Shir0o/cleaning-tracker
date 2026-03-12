import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDetailPage extends StatelessWidget {
  static bool testingMode = false;

  final String title;
  final double progress;
  final String dueDateText;
  final bool isOverdue;

  const TaskDetailPage({
    super.key,
    required this.title,
    required this.progress,
    required this.dueDateText,
    required this.isOverdue,
  });

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // In design, progress is elapsed time. "Remaining Life" is 1.0 - progress.
    final remainingPercentage = ((1.0 - progress).clamp(0.0, 1.0) * 100)
        .round();

    String getStatusText() {
      if (isOverdue) {
        // Strip minus sign if present
        final cleanDueDate = dueDateText.replaceAll('-', '');
        return 'STATUS: $cleanDueDate OVERDUE';
      }
      return 'STATUS: ON TRACK';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64, // To accommodate the padding and border
        leading: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: colorScheme.surface,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        title: Text(
          title,
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Status Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              children: [
                Text(
                  'REMAINING LIFE',
                  style: _safeGoogleFont(
                    () => GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2.0,
                      color: const Color(0xFF8A8A8A), // muted color from Stitch
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$remainingPercentage%',
                  style: _safeGoogleFont(
                    () => GoogleFonts.chivoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 80,
                      height: 1.0,
                      letterSpacing: -2.0,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'DUE DATE: TBD', // Updated for fresh start
                  style: _safeGoogleFont(
                    () => GoogleFonts.chivoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.0,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getStatusText(),
                  style: _safeGoogleFont(
                    () => GoogleFonts.chivoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.0,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reset Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Add reset logic here
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restart_alt, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'RESET SYSTEM',
                          style: _safeGoogleFont(
                            () => GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error, width: 2),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'DELETE SYSTEM',
                          style: _safeGoogleFont(
                            () => GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interval Editable Section
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INTERVAL',
                    style: _safeGoogleFont(
                      () => GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Edit interval action
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '90 DAYS',
                            style: _safeGoogleFont(
                              () => GoogleFonts.chivoMono(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF8A8A8A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Specs Section
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F4), // Surface color
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUICK SPECS',
                        style: _safeGoogleFont(
                          () => GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
                _buildSpecRow('SPEC 1', 'N/A'),
                _buildSpecRow('SPEC 2', 'N/A', isLast: true),
              ],
            ),
          ),

          // Log Archive Section
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'LOG ARCHIVE',
                    style: _safeGoogleFont(
                      () => GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: Text(
                    'NO LOGS RECORDED',
                    style: _safeGoogleFont(
                      () => GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: _safeGoogleFont(
              () => GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ),
          Text(
            value,
            style: _safeGoogleFont(
              () => GoogleFonts.chivoMono(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow(String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Completed',
            style: _safeGoogleFont(
              () => GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            date,
            style: _safeGoogleFont(
              () => GoogleFonts.chivoMono(
                fontSize: 16,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELETE SYSTEM?',
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'THIS ACTION CANNOT BE UNDONE. ALL HISTORY FOR THIS SYSTEM WILL BE PERMANENTLY REMOVED.',
                  style: _safeGoogleFont(
                    () => GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
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
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
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
                            backgroundColor: const Color(0xFFFF0000),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Pop detail page
                          },
                          child: Text(
                            'DELETE',
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
}
