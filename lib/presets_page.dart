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
        shape: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
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
            _buildSection(context, 'KITCHEN', [
              _PresetItem(
                title: 'WASH DISHES',
                interval: 'DAILY',
                icon: Icons.local_dining,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'WIPE COUNTERS & SINK',
                interval: 'DAILY',
                icon: Icons.countertops,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'WIPE MICROWAVE & APPLIANCES',
                interval: 'WEEKLY',
                icon: Icons.microwave,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'REFRIGERATOR SORT & WIPE',
                interval: 'WEEKLY',
                icon: Icons.kitchen,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'WIPE INSIDE CABINETS',
                interval: 'MONTHLY',
                icon: Icons.inventory,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'CLEAN STOVE & OVEN',
                interval: 'MONTHLY',
                icon: Icons.outdoor_grill,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'CLEAN KITCHEN CABINETS',
                interval: 'MONTHLY',
                icon: Icons.kitchen,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'DEEP CLEAN REFRIGERATOR & ICE',
                interval: '3 MONTHS',
                icon: Icons.icecream,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'PANTRY SORT',
                interval: '3 MONTHS',
                icon: Icons.inventory_2,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'DEEP CLEAN DISHWASHER',
                interval: '1 YEAR',
                icon: Icons.cleaning_services,
                category: 'KITCHEN',
              ),
              _PresetItem(
                title: 'DUST REFRIGERATOR VENT',
                interval: '1 YEAR',
                icon: Icons.air,
                category: 'KITCHEN',
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'BATHROOM', [
              _PresetItem(
                title: 'WIPE UP BATHROOMS',
                interval: 'DAILY',
                icon: Icons.bathroom,
                category: 'BATHROOM',
              ),
              _PresetItem(
                title: 'SCRUB TOILET, SHOWER & SINK',
                interval: 'WEEKLY',
                icon: Icons.bathtub,
                category: 'BATHROOM',
              ),
              _PresetItem(
                title: 'CLEAN MIRRORS',
                interval: 'WEEKLY',
                icon: Icons.auto_fix_high,
                category: 'BATHROOM',
              ),
              _PresetItem(
                title: 'CLEAN BATHROOM CABINETS',
                interval: 'MONTHLY',
                icon: Icons.bathroom,
                category: 'BATHROOM',
              ),
              _PresetItem(
                title: 'SCRUB TILE GROUT',
                interval: '3 MONTHS',
                icon: Icons.grid_on,
                category: 'BATHROOM',
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'BEDROOM', [
              _PresetItem(
                title: 'MAKE BEDS',
                interval: 'DAILY',
                icon: Icons.bed,
                category: 'BEDROOM',
              ),
              _PresetItem(
                title: 'CHANGE BED LINENS',
                interval: 'WEEKLY',
                icon: Icons.single_bed,
                category: 'BEDROOM',
              ),
              _PresetItem(
                title: 'SORT THROUGH CLOSETS',
                interval: '3 MONTHS',
                icon: Icons.checkroom,
                category: 'BEDROOM',
              ),
              _PresetItem(
                title: 'WASH COMFORTERS & DUVETS',
                interval: '3 MONTHS',
                icon: Icons.hotel,
                category: 'BEDROOM',
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'LIVING & GENERAL', [
              _PresetItem(
                title: 'GENERAL PICK UP',
                interval: 'DAILY',
                icon: Icons.home,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'SWEEP FLOORS',
                interval: 'DAILY',
                icon: Icons.cleaning_services,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'VACUUM CLEANING',
                interval: 'DAILY',
                icon: Icons.cleaning_services,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'DUST FURNITURE & SHELVES',
                interval: 'WEEKLY',
                icon: Icons.dry_cleaning,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'MOP FLOORS',
                interval: 'WEEKLY',
                icon: Icons.water_damage,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WIPE SWITCHES, DOORS & FRAMES',
                interval: 'MONTHLY',
                icon: Icons.door_front_door,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WASH OUT TRASH CANS',
                interval: 'MONTHLY',
                icon: Icons.delete_outline,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WASH WINDOWS',
                interval: '3 MONTHS',
                icon: Icons.window,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'CLEAN HEATING & COOLING VENTS',
                interval: '3 MONTHS',
                icon: Icons.air,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'AIR OUT ROOMS & DRAPES',
                interval: '3 MONTHS',
                icon: Icons.wind_power,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'CLEAN THROW PILLOWS & BLANKETS',
                interval: '3 MONTHS',
                icon: Icons.bedroom_parent,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'CLEAN CARPETS',
                interval: '1 YEAR',
                icon: Icons.dry_cleaning,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WASH WALLS',
                interval: '1 YEAR',
                icon: Icons.layers,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'RINSE SCREENS',
                interval: '1 YEAR',
                icon: Icons.grid_4x4,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WASH WINDOW SILLS',
                interval: '1 YEAR',
                icon: Icons.window,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'SCRUB BLINDS',
                interval: '1 YEAR',
                icon: Icons.blinds,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'WASH LIGHT FIXTURES',
                interval: '1 YEAR',
                icon: Icons.lightbulb,
                category: 'LIVING & GENERAL',
              ),
              _PresetItem(
                title: 'CLEAN BALCONY',
                interval: '1 YEAR',
                icon: Icons.balcony,
                category: 'LIVING & GENERAL',
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'LAUNDRY & UTILITY', [
              _PresetItem(
                title: 'LOAD OF LAUNDRY',
                interval: 'DAILY',
                icon: Icons.local_laundry_service,
                category: 'LAUNDRY & UTILITY',
              ),
              _PresetItem(
                title: 'DEEP CLEAN WASHING MACHINE',
                interval: '1 YEAR',
                icon: Icons.local_laundry_service,
                category: 'LAUNDRY & UTILITY',
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<_PresetItem> items,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.onSurface, width: 2),
            ),
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
  final String category;

  _PresetItem({
    required this.title,
    required this.interval,
    required this.icon,
    required this.category,
  });
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
              'category': item.category,
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
                  color: colorScheme
                      .onSurface, // In hover, this might not invert automatically without custom state, but it's fine for simple tap
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
