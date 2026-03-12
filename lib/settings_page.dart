import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_history_page.dart';
import 'secrets.dart';

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
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // New state variables for settings
  String _notifyBeforeExpiry = '2 DAYS';
  String _dailyReminderTime = '09:00 AM';
  String _interfaceTheme = 'LIGHT';
  String _startOfWeek = 'MONDAY';

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _initGoogleSignIn();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifyBeforeExpiry =
            prefs.getString('notifyBeforeExpiry') ?? '2 DAYS';
        _dailyReminderTime = prefs.getString('dailyReminderTime') ?? '09:00 AM';
        _interfaceTheme = prefs.getString('interfaceTheme') ?? 'LIGHT';
        _startOfWeek = prefs.getString('startOfWeek') ?? 'MONDAY';
      });
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showSelectionDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    title.toUpperCase(),
                    style: _safeGoogleFont(
                      () => GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.black, thickness: 2, height: 0),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == currentValue;

                      return InkWell(
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: const Border(
                              bottom: BorderSide(color: Colors.black),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: _safeGoogleFont(
                                  () => GoogleFonts.chivoMono(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: _safeGoogleFont(
                          () => GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        // For Android in 7.x, serverClientId is required to support modern Credential Manager
        serverClientId: googleServerClientId,
      );

      GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (mounted) {
          setState(() {
            if (event is GoogleSignInAuthenticationEventSignIn) {
              _currentUser = event.user;
            } else if (event is GoogleSignInAuthenticationEventSignOut) {
              _currentUser = null;
            }
          });
        }
      });

      // Check if user is already signed in
      // attemptLightweightAuthentication can throw if config is missing
      try {
        final account = await GoogleSignIn.instance
            .attemptLightweightAuthentication();
        if (mounted) {
          setState(() {
            _currentUser = account;
          });
        }
      } catch (e) {
        debugPrint('Lightweight auth check failed: $e');
      }
    } catch (e) {
      debugPrint('GoogleSignIn initialization failed: $e');
    }
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
          const SnackBar(
            content: Text('Please enable notifications in system settings.'),
          ),
        );
        openAppSettings();
      }
    } else {
      // We can't actually disable notifications programmatically, but we can direct them to settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'To disable notifications, please visit system settings.',
            ),
          ),
        );
        openAppSettings();
      }
    }
  }

  Future<void> _handleSignIn() async {
    try {
      debugPrint('Attempting Google Sign In...');
      final account = await GoogleSignIn.instance.authenticate();
      debugPrint('Sign in result: $account');
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Sign in error: $error');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed. Please check your configuration.'),
          ),
        );
      }
    }
  }

  Future<void> _handleForceBackup() async {
    try {
      // In a real implementation, you would use googleapis here to upload data
      // For this prototype, we just simulate the success
      setState(() {
        _lastBackupTime = 'Just now';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup successful!'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $error')),
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
          'SYSTEM SETTINGS',
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize:
                  28, // Scaled down slightly from 32 for screen fit with back button
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
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
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    onTap: () {
                      _showSelectionDialog(
                        title: 'Notify Before',
                        options: [
                          '1 DAY',
                          '2 DAYS',
                          '3 DAYS',
                          '1 WEEK',
                        ],
                        currentValue: _notifyBeforeExpiry,
                        onSelected: (val) {
                          setState(() => _notifyBeforeExpiry = val);
                          _saveSetting('notifyBeforeExpiry', val);
                        },
                      );
                    },
                    icon: Icons.event,
                    title: 'Notify before expiry',
                    subtitle: 'Scheduled prior to due date',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _notifyBeforeExpiry,
                            style: _safeGoogleFont(
                              () => GoogleFonts.chivoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 20),
                      ],
                    ),
                  ),
                  _buildSettingRow(
                    onTap: () {
                      _showSelectionDialog(
                        title: 'Reminder Time',
                        options: [
                          '08:00 AM',
                          '09:00 AM',
                          '10:00 AM',
                          '07:00 PM',
                        ],
                        currentValue: _dailyReminderTime,
                        onSelected: (val) {
                          setState(() => _dailyReminderTime = val);
                          _saveSetting('dailyReminderTime', val);
                        },
                      );
                    },
                    icon: Icons.notifications_active,
                    title: 'Daily reminder',
                    subtitle: 'Morning digest status',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _dailyReminderTime,
                            style: _safeGoogleFont(
                              () => GoogleFonts.chivoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    onTap: () {
                      _showSelectionDialog(
                        title: 'Interface Theme',
                        options: ['LIGHT', 'DARK', 'SYSTEM'],
                        currentValue: _interfaceTheme,
                        onSelected: (val) {
                          setState(() => _interfaceTheme = val);
                          _saveSetting('interfaceTheme', val);
                        },
                      );
                    },
                    icon: Icons.dark_mode,
                    title: 'Interface Theme',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _interfaceTheme,
                            style: _safeGoogleFont(
                              () => GoogleFonts.chivoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.expand_more, size: 20),
                      ],
                    ),
                  ),
                  _buildSettingRow(
                    onTap: () {
                      _showSelectionDialog(
                        title: 'Start of Week',
                        options: ['SUNDAY', 'MONDAY', 'SATURDAY'],
                        currentValue: _startOfWeek,
                        onSelected: (val) {
                          setState(() => _startOfWeek = val);
                          _saveSetting('startOfWeek', val);
                        },
                      );
                    },
                    icon: Icons.calendar_view_week,
                    title: 'Start of Week',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _startOfWeek,
                            style: _safeGoogleFont(
                              () => GoogleFonts.chivoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
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
                          child: Icon(
                            Icons.cloud_upload,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sync with Google Drive'.toUpperCase(),
                              style: TextStyle(
                                fontFamily: _safeGoogleFont(
                                  () => GoogleFonts.inter(),
                                ).fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _currentUser != null
                                  ? 'Signed in as: ${_currentUser!.email}'
                                  : 'Last backup: $_lastBackupTime',
                              style: TextStyle(
                                fontFamily: _safeGoogleFont(
                                  () => GoogleFonts.inter(),
                                ).fontFamily,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _currentUser != null
                              ? _handleForceBackup
                              : _handleSignIn,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: Text(
                                _currentUser != null
                                    ? 'FORCE BACKUP NOW'
                                    : 'SIGN IN TO SYNC',
                                style: TextStyle(
                                  fontFamily: _safeGoogleFont(
                                    () => GoogleFonts.inter(),
                                  ).fontFamily,
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
                    ),
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
                                style: TextStyle(
                                  fontFamily: _safeGoogleFont(
                                    () => GoogleFonts.inter(),
                                  ).fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
            ),
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

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                      style: TextStyle(
                        fontFamily: _safeGoogleFont(
                          () => GoogleFonts.inter(),
                        ).fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: _safeGoogleFont(
                            () => GoogleFonts.inter(),
                          ).fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing,
          ],
        ),
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
                  color: const Color(
                    0xFF0038FF,
                  ).withValues(alpha: 0.2), // Optional tint to show active
                ),
              ),
          ],
        ),
      ),
    );
  }
}
