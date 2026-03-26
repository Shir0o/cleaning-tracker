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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              'KITCHEN',
              [
                _PresetItem(title: 'WASH DISHES', interval: 'DAILY', icon: Icons.local_dining),
                _PresetItem(title: 'WIPE COUNTERS & SINK', interval: 'DAILY', icon: Icons.countertops),
                _PresetItem(title: 'WIPE MICROWAVE & APPLIANCES', interval: 'WEEKLY', icon: Icons.microwave),
                _PresetItem(title: 'REFRIGERATOR SORT & WIPE', interval: 'WEEKLY', icon: Icons.kitchen),
                _PresetItem(title: 'WIPE INSIDE CABINETS', interval: 'MONTHLY', icon: Icons.inventory),
                _PresetItem(title: 'CLEAN STOVE & OVEN', interval: 'MONTHLY', icon: Icons.outdoor_grill),
                _PresetItem(title: 'CLEAN KITCHEN CABINETS', interval: 'MONTHLY', icon: Icons.kitchen),
                _PresetItem(title: 'DEEP CLEAN REFRIGERATOR & ICE', interval: '3 MONTHS', icon: Icons.icecream),
                _PresetItem(title: 'PANTRY SORT', interval: '3 MONTHS', icon: Icons.inventory_2),
                _PresetItem(title: 'DEEP CLEAN DISHWASHER', interval: '1 YEAR', icon: Icons.cleaning_services),
                _PresetItem(title: 'DUST REFRIGERATOR VENT', interval: '1 YEAR', icon: Icons.air),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'BATHROOM',
              [
                _PresetItem(title: 'WIPE UP BATHROOMS', interval: 'DAILY', icon: Icons.bathroom),
                _PresetItem(title: 'SCRUB TOILET, SHOWER & SINK', interval: 'WEEKLY', icon: Icons.bathtub),
                _PresetItem(title: 'CLEAN MIRRORS', interval: 'WEEKLY', icon: Icons.auto_fix_high),
                _PresetItem(title: 'CLEAN BATHROOM CABINETS', interval: 'MONTHLY', icon: Icons.bathroom),
                _PresetItem(title: 'SCRUB TILE GROUT', interval: '3 MONTHS', icon: Icons.grid_on),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'BEDROOM',
              [
                _PresetItem(title: 'MAKE BEDS', interval: 'DAILY', icon: Icons.bed),
                _PresetItem(title: 'CHANGE BED LINENS', interval: 'WEEKLY', icon: Icons.single_bed),
                _PresetItem(title: 'SORT THROUGH CLOSETS', interval: '3 MONTHS', icon: Icons.checkroom),
                _PresetItem(title: 'WASH COMFORTERS & DUVETS', interval: '3 MONTHS', icon: Icons.hotel),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'LIVING & GENERAL',
              [
                _PresetItem(title: 'GENERAL PICK UP', interval: 'DAILY', icon: Icons.home),
                _PresetItem(title: 'SWEEP FLOORS', interval: 'DAILY', icon: Icons.cleaning_services),
                _PresetItem(title: 'VACUUM CLEANING', interval: 'DAILY', icon: Icons.cleaning_services),
                _PresetItem(title: 'DUST FURNITURE & SHELVES', interval: 'WEEKLY', icon: Icons.dry_cleaning),
                _PresetItem(title: 'MOP FLOORS', interval: 'WEEKLY', icon: Icons.water_damage),
                _PresetItem(title: 'WIPE SWITCHES, DOORS & FRAMES', interval: 'MONTHLY', icon: Icons.door_front_door),
                _PresetItem(title: 'WASH OUT TRASH CANS', interval: 'MONTHLY', icon: Icons.delete_outline),
                _PresetItem(title: 'WASH WINDOWS', interval: '3 MONTHS', icon: Icons.window),
                _PresetItem(title: 'CLEAN HEATING & COOLING VENTS', interval: '3 MONTHS', icon: Icons.air),
                _PresetItem(title: 'AIR OUT ROOMS & DRAPES', interval: '3 MONTHS', icon: Icons.wind_power),
                _PresetItem(title: 'CLEAN THROW PILLOWS & BLANKETS', interval: '3 MONTHS', icon: Icons.bedroom_parent),
                _PresetItem(title: 'CLEAN CARPETS', interval: '1 YEAR', icon: Icons.dry_cleaning),
                _PresetItem(title: 'WASH WALLS', interval: '1 YEAR', icon: Icons.layers),
                _PresetItem(title: 'RINSE SCREENS', interval: '1 YEAR', icon: Icons.grid_4x4),
                _PresetItem(title: 'WASH WINDOW SILLS', interval: '1 YEAR', icon: Icons.window),
                _PresetItem(title: 'SCRUB BLINDS', interval: '1 YEAR', icon: Icons.blinds),
                _PresetItem(title: 'WASH LIGHT FIXTURES', interval: '1 YEAR', icon: Icons.lightbulb),
                _PresetItem(title: 'CLEAN BALCONY', interval: '1 YEAR', icon: Icons.balcony),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'LAUNDRY & UTILITY',
              [
                _PresetItem(title: 'LOAD OF LAUNDRY', interval: 'DAILY', icon: Icons.local_laundry_service),
                _PresetItem(title: 'DEEP CLEAN WASHING MACHINE', interval: '1 YEAR', icon: Icons.local_laundry_service),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
