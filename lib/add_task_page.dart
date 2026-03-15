import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'presets_page.dart';

class AddTaskPage extends StatefulWidget {
  static bool testingMode = false;

  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  String _selectedInterval = '7 DAYS';
  final TextEditingController _nameController = TextEditingController();

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (AddTaskPage.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          'NEW SYSTEM',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push<Map<String, String>>(
                  MaterialPageRoute(builder: (context) => const PresetsPage()),
                );
                if (result != null) {
                  setState(() {
                    _nameController.text = result['name']!;
                    _selectedInterval = result['interval']!;
                  });
                }
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.onSurface, width: 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CHOOSE FROM PRESETS',
                      style: _safeGoogleFont(
                        () => GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.0,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: colorScheme.onSurface)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR CREATE CUSTOM',
                    style: _safeGoogleFont(
                      () => GoogleFonts.chivoMono(
                        fontSize: 10,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: TextField(
                controller: _nameController,
                cursorColor: colorScheme.primary,
                style: _safeGoogleFont(
                  () => GoogleFonts.inter(fontSize: 16, color: colorScheme.onSurface),
                ),
                decoration: InputDecoration(
                  hintText: 'SYSTEM NAME...',
                  hintStyle: _safeGoogleFont(
                    () => GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'INTERVAL',
              style: _safeGoogleFont(
                () => GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:
                    2.0, // Adjust this if needed for a 96px height button
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildIntervalButton('7 DAYS', context),
                  _buildIntervalButton('30 DAYS', context),
                  _buildIntervalButton('90 DAYS', context),
                  _buildIntervalButton('CUSTOM', context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.onSurface, width: 2)),
        ),
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                Navigator.of(context).pop(_nameController.text);
              }
            },
            child: Text(
              'INITIALIZE TRACKER',
              style: _safeGoogleFont(
                () => GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalButton(String text, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isSelected = _selectedInterval == text;

    if (text == 'CUSTOM' && !['7 DAYS', '30 DAYS', '90 DAYS'].contains(_selectedInterval)) {
      isSelected = true;
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.onSurface : colorScheme.surface,
        border: Border.all(color: colorScheme.onSurface, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedInterval = text;
            });
          },
          child: Center(
            child: Text(
              text,
              style: _safeGoogleFont(
                () => GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isSelected ? colorScheme.surface : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
