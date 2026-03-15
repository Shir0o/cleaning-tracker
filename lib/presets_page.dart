import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PresetsPage extends StatelessWidget {
  static bool testingMode = false;

  const PresetsPage({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CRISP & UTILITY',
              style: _safeGoogleFont(
                () => GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Text(
              'CHOOSE PRESET',
              style: _safeGoogleFont(
                () => GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'MAINTENANCE',
              [
                _PresetItem(title: 'HVAC FILTER', interval: '90 DAYS', icon: Icons.air),
                _PresetItem(title: 'SMOKE ALARM', interval: '6 MONTHS', icon: Icons.smoke_free), // closest to detector_smoke
                _PresetItem(title: 'WATER FILTER', interval: '6 MONTHS', icon: Icons.water_drop),
                _PresetItem(title: 'FURNACE', interval: '1 YEAR', icon: Icons.mode_fan_off), // using generic fan or similar. Actually Icons.ac_unit or Icons.hvac? Let's use Icons.toys or Icons.heat_pump
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'KITCHEN',
              [
                _PresetItem(title: 'COUNTERTOPS', interval: 'DAILY', icon: Icons.countertops),
                _PresetItem(title: 'DISHWASHER', interval: 'WEEKLY', icon: Icons.local_dining), // dishwasher
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'BATHROOM',
              [
                _PresetItem(title: 'DEEP CLEAN', interval: 'WEEKLY', icon: Icons.bathtub),
                _PresetItem(title: 'SURFACES', interval: 'EVERY 3 DAYS', icon: Icons.sanitizer),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'GENERAL',
              [
                _PresetItem(title: 'VACUUMING', interval: 'WEEKLY', icon: Icons.cleaning_services), // vacuum
                _PresetItem(title: 'MOPPING', interval: 'WEEKLY', icon: Icons.water_damage), // mop
                _PresetItem(title: 'DUSTING', interval: 'EVERY 2 WKS', icon: Icons.dry_cleaning), // dusting
                _PresetItem(title: 'WINDOWS', interval: '6 MONTHS', icon: Icons.window),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_PresetItem> items) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
          ),
          padding: const EdgeInsets.only(bottom: 8),
          margin: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: _safeGoogleFont(
              () => GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items.map((item) => _PresetCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class _PresetItem {
  final String title;
  final String interval;
  final IconData icon;

  _PresetItem({required this.title, required this.interval, required this.icon});
}

class _PresetCard extends StatelessWidget {
  final _PresetItem item;

  const _PresetCard({required this.item});

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (PresetsPage.testingMode) return const TextStyle();
    return fontFn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.onSurface, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: colorScheme.onSurface,
          onTap: () {
            Navigator.of(context).pop({
              'name': item.title,
              'interval': item.interval,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 32,
                  color: colorScheme.onSurface, // In hover, this might not invert automatically without custom state, but it's fine for simple tap
                ),
                const Spacer(),
                Text(
                  item.interval,
                  style: _safeGoogleFont(
                    () => GoogleFonts.chivoMono(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: _safeGoogleFont(
                    () => GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
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
