import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'main.dart' show Task;
import 'database_service.dart';

class TaskDetailPage extends StatefulWidget {
  static bool testingMode = false;

  final Task task;
  final DateTime? referenceTime;

  const TaskDetailPage({
    super.key,
    required this.task,
    this.referenceTime,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (TaskDetailPage.testingMode) return const TextStyle();
    return fontFn();
  }

  void _showIntervalDialog() {
    final options = ['7 DAYS', '30 DAYS', '90 DAYS', 'CUSTOM'];
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.onSurface, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                return InkWell(
                  onTap: () {
                    if (option == 'CUSTOM') {
                      Navigator.pop(context);
                      _showCustomIntervalDialog();
                    } else {
                      setState(() {
                        _currentTask = _currentTask.copyWith(interval: option);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.onSurface)),
                    ),
                    child: Text(
                      option,
                      style: _safeGoogleFont(() => GoogleFonts.chivoMono(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCustomIntervalDialog() {
    final controller = TextEditingController();
    String unit = 'DAYS';
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.onSurface, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'VALUE...'),
                  ),
                  DropdownButton<String>(
                    value: unit,
                    items: ['DAYS', 'WEEKS', 'MONTHS'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setDialogState(() => unit = val!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          _currentTask = _currentTask.copyWith(interval: '${controller.text} $unit');
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('SET INTERVAL'),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showNotesDialog() {
    final controller = TextEditingController(text: _currentTask.notes);

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.onSurface, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EDIT NOTES',
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter notes here...',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentTask = _currentTask.copyWith(notes: controller.text);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE NOTES'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    final controller = TextEditingController(text: _currentTask.category);
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.onSurface, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EDIT CATEGORY',
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'CATEGORY...',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          _currentTask = _currentTask.copyWith(category: controller.text.toUpperCase());
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('SAVE'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSurfaceColor(ThemeData theme) {
    return theme.brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4);
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: _safeGoogleFont(
          () => GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2.0,
            color: const Color(0xFF8A8A8A),
          ),
        ),
      ),
    );
  }

  void _onSnooze() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return Container(
          color: colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'SNOOZE UNTIL...',
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              _buildSnoozeOption('1 DAY', const Duration(days: 1)),
              _buildSnoozeOption('3 DAYS', const Duration(days: 3)),
              _buildSnoozeOption('1 WEEK', const Duration(days: 7)),
              _buildSnoozeOption('2 WEEKS', const Duration(days: 14)),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSnoozeOption(String label, Duration duration) {
    return ListTile(
      title: Text(
        label,
        textAlign: TextAlign.center,
        style: _safeGoogleFont(
          () => GoogleFonts.chivoMono(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      onTap: () async {
        final snoozeDate = DateTime.now().add(duration);
        final updatedTask = _currentTask.copyWith(snoozedUntil: snoozeDate);
        await DatabaseService().updateTask(updatedTask);
        if (mounted) {
          setState(() {
            _currentTask = updatedTask;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Snoozed for $label')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceColor = _getSurfaceColor(theme);

    // Recalculate based on _currentTask
    final now = widget.referenceTime ?? DateTime.now();
    final health = _currentTask.health(now);
    final remainingPercentage = (health * 100).round();
    final isOverdue = remainingPercentage <= 0;

    String getStatusText() {
      return 'STATUS: ${_currentTask.statusText(now)}';
    }

    String getDueDateText() {
      return 'DUE DATE: ${_currentTask.dueDateText(now)}';
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result == null) {
          // If popped via back button, return the updated task
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 64,
          leading: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.onSurface, width: 2),
                color: colorScheme.surface,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop(_currentTask);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          shape: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
          title: Text(
            _currentTask.title,
            style: _safeGoogleFont(
              () => GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
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
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
              ),
              child: Column(
                children: [
                  Text(
                    'CLEANLINESS',
                    style: _safeGoogleFont(
                      () => GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 2.0,
                        color: const Color(0xFF8A8A8A),
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
                        color: isOverdue ? colorScheme.error : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getStatusText(),
                    style: _safeGoogleFont(
                      () => GoogleFonts.chivoMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                        color: isOverdue ? colorScheme.error : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getDueDateText(),
                    style: _safeGoogleFont(
                      () => GoogleFonts.chivoMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                        color: isOverdue ? colorScheme.error : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
  
            // Reset Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
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
                              final now = DateTime.now();
                              HapticFeedback.heavyImpact();
                              // Clear snooze when completing
                              final updatedTask = _currentTask.copyWith(
                                lastCompleted: now,
                                completions: [..._currentTask.completions, now],
                                snoozedUntil: null,
                              );
                              await DatabaseService().updateTask(updatedTask);
                              if (!context.mounted) return;
                              setState(() {
                                _currentTask = updatedTask;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('System Reset Successful')),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.restart_alt, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'I JUST DID IT!',
                                  style: _safeGoogleFont(
                                    () => GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.onSurface,
                              side: BorderSide(color: colorScheme.onSurface, width: 2),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            onPressed: _onSnooze,
                            child: Text(
                              'SNOOZE',
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
                            'DELETE',
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

            // SYSTEM DETAILS SECTION
            _buildSectionTitle('System Details', context),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.onSurface, width: 2),
                  bottom: BorderSide(color: colorScheme.onSurface, width: 2),
                ),
              ),
              child: Column(
                children: [
                  // Category Row
                  InkWell(
                    onTap: _showCategoryDialog,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CATEGORY',
                            style: _safeGoogleFont(
                              () => GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _currentTask.category,
                                style: _safeGoogleFont(
                                  () => GoogleFonts.chivoMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 16, color: Color(0xFF8A8A8A)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: colorScheme.onSurface, thickness: 1, height: 0),
                  // Interval Row
                  InkWell(
                    onTap: _showIntervalDialog,
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
                          Row(
                            children: [
                              Text(
                                _currentTask.interval,
                                style: _safeGoogleFont(
                                  () => GoogleFonts.chivoMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 16, color: Color(0xFF8A8A8A)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
  
            // NOTES SECTION
            _buildSectionTitle('Notes', context),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.onSurface, width: 2),
                  bottom: BorderSide(color: colorScheme.onSurface, width: 2),
                ),
              ),
              child: InkWell(
                onTap: _showNotesDialog,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _currentTask.notes.isEmpty ? 'NO NOTES RECORDED' : _currentTask.notes,
                          style: _safeGoogleFont(
                            () => GoogleFonts.inter(
                              fontSize: 16,
                              height: 1.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16, color: Color(0xFF8A8A8A)),
                    ],
                  ),
                ),
              ),
            ),

            // SMART SUGGESTION SECTION
            if (_currentTask.suggestedInterval != null) ...[
              _buildSectionTitle('Smart Suggestion', context),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ADAPTIVE INTERVAL',
                            style: _safeGoogleFont(
                              () => GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.0,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'BASED ON YOUR HISTORY, WE RECOMMEND UPDATING THE INTERVAL TO ${_currentTask.suggestedInterval}.',
                        style: _safeGoogleFont(
                          () => GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
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
                            final updatedTask = _currentTask.copyWith(
                              interval: _currentTask.suggestedInterval!,
                            );
                            await DatabaseService().updateTask(updatedTask);
                            if (mounted) {
                              setState(() {
                                _currentTask = updatedTask;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Interval updated based on history.')),
                              );
                            }
                          },
                          child: Text(
                            'UPDATE TO ${_currentTask.suggestedInterval}',
                            style: _safeGoogleFont(
                              () => GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
  
            // HISTORY SECTION
            _buildSectionTitle('History', context),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.onSurface, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _currentTask.completions.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colorScheme.onSurface, width: 1),
                            ),
                          ),
                          child: Text(
                            'NO HISTORY YET',
                            style: _safeGoogleFont(
                              () => GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _currentTask.completions.reversed
                              .take(5)
                              .map((completion) => _buildHistoryRow(completion, context))
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(DateTime completion, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MM.dd').format(completion);
    final yearStr = DateFormat('yyyy').format(completion);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              dateStr,
              style: _safeGoogleFont(
                () => GoogleFonts.chivoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'COMPLETION REGISTERED',
              style: _safeGoogleFont(
                () => GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Text(
            yearStr,
            style: _safeGoogleFont(
              () => GoogleFonts.chivoMono(
                fontSize: 14,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  'DELETE SYSTEM?',
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
                  'THIS ACTION CANNOT BE UNDONE. ALL HISTORY FOR THIS SYSTEM WILL BE PERMANENTLY REMOVED.',
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
                            backgroundColor: const Color(0xFFFF0000),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop('delete'); // Pop detail page with 'delete' result
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
