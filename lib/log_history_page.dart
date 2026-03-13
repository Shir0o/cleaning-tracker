import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class LogHistoryPage extends StatefulWidget {
  static bool testingMode = false;

  const LogHistoryPage({super.key});

  @override
  State<LogHistoryPage> createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (LogHistoryPage.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  void initState() {
    super.initState();
    if (LogHistoryPage.testingMode) {
      _isLoading = false;
    } else {
      _startLoadingTimer();
    }
  }

  void _startLoadingTimer() {
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
    _loadingTimer?.cancel();
    super.dispose();
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
          'ARCHIVE',
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
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerLogRecord(),
            )
          : Center(
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

  Widget _buildLogRecord(String date, String title, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              date,
              style: _safeGoogleFont(
                () => GoogleFonts.chivoMono(
                    fontSize: 14,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title.toUpperCase(),
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
              () => GoogleFonts.chivoMono(fontSize: 14, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
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
