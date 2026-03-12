import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'log_history_page.dart';

class SettingsPage extends StatefulWidget {
  static bool testingMode = false;

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    if (SettingsPage.testingMode) return const TextStyle();
    return fontFn();
  }
  bool _notificationsEnabled = false;
  String _lastBackupTime = 'Never';

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    // In a real implementation you might check user's backup status here
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _requestNotificationPermission(bool enable) async {
    if (enable) {
      final status = await Permission.notification.request();
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
      if (status.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable notifications in system settings.')),
        );
        openAppSettings();
      }
    } else {
      // We can't actually disable notifications programmatically, but we can direct them to settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To disable notifications, please visit system settings.')),
        );
        openAppSettings();
      }
    }
  }

  Future<void> _handleForceBackup() async {
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      await GoogleSignIn.instance.authorizationClient.authorizeScopes([
        'https://www.googleapis.com/auth/drive.file',
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Successfully authenticated as ${account.email}')),
        );
        setState(() {
          _lastBackupTime = 'Just now';
        });
        // Here you would use googleapis to actually upload the data.
      }
    } catch (error) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Authentication failed: $error')),
        );
       }
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
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              ),
            ),
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
        title: Text(
          'SYSTEM SETTINGS',
          style: _safeGoogleFont(() => GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 28, // Scaled down slightly from 32 for screen fit with back button
            letterSpacing: -0.5,
            color: Colors.black,
          )),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          children: [
          // Notification Preferences
          _buildSectionHeader('01. Notification Preferences'),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.event,
                  title: 'Notify before expiry',
                  subtitle: 'Scheduled 48 hours prior',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '2 DAYS',
                          style: _safeGoogleFont(() => GoogleFonts.chivoMono(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
                _buildSettingRow(
                  icon: Icons.notifications_active,
                  title: 'Daily reminder',
                  subtitle: 'Morning digest status',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '09:00 AM',
                          style: _safeGoogleFont(() => GoogleFonts.chivoMono(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Custom switch for notifications
                      _buildBrutalSwitch(
                        _notificationsEnabled,
                        _requestNotificationPermission,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Global Preferences
          _buildSectionHeader('02. Global Preferences'),
           Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.dark_mode,
                  title: 'Interface Theme',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'LIGHT',
                          style: _safeGoogleFont(() => GoogleFonts.chivoMono(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more, size: 20),
                    ],
                  ),
                ),
                 _buildSettingRow(
                  icon: Icons.calendar_view_week,
                  title: 'Start of Week',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'MONDAY',
                          style: _safeGoogleFont(() => GoogleFonts.chivoMono(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Data Backup
          _buildSectionHeader('03. Data & Sync'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // slate-50
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Icon(Icons.cloud_upload, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync with Google Drive'.toUpperCase(),
                            style: TextStyle(fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Last backup: $_lastBackupTime',
                            style: TextStyle(fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily, fontWeight: FontWeight.w500, fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                     width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                           onTap: _handleForceBackup,
                           child: Padding(
                             padding: const EdgeInsets.symmetric(vertical: 12.0),
                             child: Center(
                               child: Text(
                                  'FORCE BACKUP NOW',
                                   style: TextStyle(
                                    fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                               ),
                             ),
                           ),
                        ),
                      ),
                  )
                ],
              ),
            ),
          ),

          // History Section
          _buildSectionHeader('04. History'),
           Padding(
             padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
             child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (context) => const LogHistoryPage(),
                         ),
                       );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                             children: [
                                Icon(Icons.history, color: colorScheme.primary),
                                const SizedBox(width: 16),
                                Text(
                                  'VIEW ALL LOGS',
                                  style: TextStyle(fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                             ],
                           ),
                           const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ),
             ),
           )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSettingRow({required IconData icon, required String title, String? subtitle, required Widget trailing}) {
    return Container(
       decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
       ),
       padding: const EdgeInsets.all(16),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                 Icon(icon, color: const Color(0xFF0038FF)), // Primary color
                 const SizedBox(width: 16),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                        title.toUpperCase(),
                         style: TextStyle(fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(fontFamily: _safeGoogleFont(() => GoogleFonts.inter()).fontFamily, fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[500]),
                        ),
                   ],
                 )
              ],
            ),
            trailing,
          ],
       ),
    );
  }

  Widget _buildBrutalSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
               left: value ? 20 : 0,
               top: 0,
               bottom: 0,
               child: Container(
                 width: 16,
                 color: value ? Colors.white : Colors.black,
               ),
            ),
            if (value)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0038FF).withValues(alpha: 0.2), // Optional tint to show active
                ),
              )
          ],
        ),
      ),
    );
  }
}
