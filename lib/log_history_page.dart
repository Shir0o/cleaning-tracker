import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import 'database_service.dart';

class LogHistoryPage extends StatefulWidget {
  static bool testingMode = false;

  const LogHistoryPage({super.key});

  @override
  State<LogHistoryPage> createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> {
  bool _isLoading = true;
  List<TaskCompletion> _completions = [];

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (LogHistoryPage.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final tasks = await DatabaseService().getTasks();
    
    final List<TaskCompletion> allCompletions = [];
    
    for (var task in tasks) {
      for (var completionDate in task.completions) {
        allCompletions.add(TaskCompletion(
          taskTitle: task.title,
          completionDate: completionDate,
        ));
      }
    }
    
    // Sort by date descending
    allCompletions.sort((a, b) => b.completionDate.compareTo(a.completionDate));

    if (mounted) {
      setState(() {
        _completions = allCompletions;
        _isLoading = false;
      });
    }
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
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.onSurface, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
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
          'HISTORY',
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const ShimmerLogRecord(),
            )
          : _completions.isEmpty
              ? Center(
                  child: Text(
                    'NO HISTORY AVAILABLE',
                    style: _safeGoogleFont(
                      () => GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _completions.length,
                  itemBuilder: (context, index) {
                    final completion = _completions[index];
                    final showYear = index == 0 || 
                      completion.completionDate.year != _completions[index - 1].completionDate.year;
                    
                    return Column(
                      children: [
                        if (showYear) 
                          _buildYearDivider(completion.completionDate.year.toString(), context),
                        _buildLogRecord(completion, context),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildYearDivider(String year, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
      ),
      child: Text(
        year,
        style: _safeGoogleFont(
          () => GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            height: 1.0,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLogRecord(TaskCompletion completion, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MM.dd').format(completion.completionDate);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 1)),
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
                    color: colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              completion.taskTitle.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _safeGoogleFont(
                  () => GoogleFonts.inter(),
                ).fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.2,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'RESET',
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
}

class TaskCompletion {
  final String taskTitle;
  final DateTime completionDate;

  TaskCompletion({required this.taskTitle, required this.completionDate});
}

class ShimmerLogRecord extends StatelessWidget {
  const ShimmerLogRecord({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 1)),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
