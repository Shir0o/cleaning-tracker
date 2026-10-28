import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drive_service.dart';
import 'log_history_page.dart';
import 'main.dart' show themeNotifier, roomThemes;
import 'notification_service.dart';
import 'privacy_policy_page.dart';

const _primary = Color(0xFF3A7D5C);

const List<String> reminderTimeOptions = [
  '08:00 AM',
  '09:00 AM',
  '10:00 AM',
  '07:00 PM',
];

const List<String> notifyBeforeOptions = [
  'SAME DAY',
  '1 DAY',
  '2 DAYS',
  '3 DAYS',
  '4 DAYS',
  '5 DAYS',
  '1 WEEK',
  '2 WEEKS',
];

/// Settings shown as the fourth dashboard tab. Every control here is saved
/// to SharedPreferences and, for reminders, reschedules notifications.
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> with WidgetsBindingObserver {
  bool _notificationsEnabled = true;
  String _notifyBefore = '2 DAYS';
  String _reminderTime = '09:00 AM';
  String _interfaceTheme = 'LIGHT';
  Set<String> _mutedRooms = {};
  String _lastBackupTime = 'Never';
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkNotificationPermission();
    DriveService().addListener(_onDriveServiceChange);
    _currentUser = DriveService().currentUser;
  }

  @override
  void dispose() {
    DriveService().removeListener(_onDriveServiceChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  void _onDriveServiceChange() {
    if (mounted) {
      _loadSettings();
      setState(() => _currentUser = DriveService().currentUser);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _notifyBefore = prefs.getString('notifyBeforeExpiry') ?? '2 DAYS';
      _reminderTime = prefs.getString('dailyReminderTime') ?? '09:00 AM';
      _interfaceTheme = prefs.getString('interfaceTheme') ?? 'LIGHT';
      _mutedRooms = (prefs.getStringList(mutedRoomsPrefKey) ?? []).toSet();

      final lastBackup = prefs.getString('last_backup_time');
      if (lastBackup != null) {
        final diff = DateTime.now().difference(DateTime.parse(lastBackup));
        if (diff.inMinutes < 1) {
          _lastBackupTime = 'Just now';
        } else if (diff.inHours < 1) {
          _lastBackupTime = '${diff.inMinutes}m ago';
        } else if (diff.inDays < 1) {
          _lastBackupTime = '${diff.inHours}h ago';
        } else {
          _lastBackupTime = '${diff.inDays}d ago';
        }
      }
    });
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (mounted && !status.isGranted && _notificationsEnabled) {
      setState(() => _notificationsEnabled = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    if (value) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          if (mounted) {
            _showSnack('Please enable notifications in system settings.');
          }
          return;
        }
      }
    }
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    // An empty list cancels everything when reminders are off.
    await NotificationService().rescheduleAll(value ? null : []);
  }

  Future<void> _setRoomEnabled(String categoryKey, bool enabled) async {
    setState(() {
      enabled ? _mutedRooms.remove(categoryKey) : _mutedRooms.add(categoryKey);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(mutedRoomsPrefKey, _mutedRooms.toList());
    await NotificationService().rescheduleAll();
  }

  Future<void> _setTheme(String value) async {
    setState(() => _interfaceTheme = value);
    themeNotifier.value = switch (value) {
      'DARK' => ThemeMode.dark,
      'SYSTEM' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('interfaceTheme', value);
  }

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required String current,
    required String prefKey,
    required ValueChanged<String> apply,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(
                  _formatOption(option),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: option == current
                    ? const Icon(Icons.check, color: _primary)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == current) return;
    setState(() => apply(picked));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, picked);
    await NotificationService().rescheduleAll();
  }

  /// '2 DAYS' -> '2 days', 'SAME DAY' -> 'Same day', '09:00 AM' -> '9:00 AM'.
  String _formatOption(String value) {
    if (value.contains(':')) {
      return value.startsWith('0') ? value.substring(1) : value;
    }
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Future<void> _handleSignIn() async {
    try {
      await DriveService().setSyncEnabled(true);
    } catch (error) {
      debugPrint(
        'Sign in error: ${DriveService.sanitizeLogMessage(error.toString())}',
      );
      if (mounted) {
        _showSnack('Sign in failed. Please check your configuration.');
      }
    }
  }

  Future<void> _handleBackup() async {
    try {
      await DriveService().syncFiles();
      if (mounted) _showSnack('Backup successful!');
    } catch (error) {
      if (mounted) _showSnack('Backup failed: $error');
    }
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Restore from backup?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'This replaces all tasks and settings on this device with your '
          'Google Drive backup. It can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await DriveService().restoreFromBackup();
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      _showSnack('Restore successful!');
      _loadSettings();
      await NotificationService().rescheduleAll();
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      _showSnack('Restore failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _Palette(isDark);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _section(palette, 'Reminders', [
          _row(
            palette,
            icon: Icons.notifications_none,
            title: 'Reminders',
            subtitle: 'Get notified when tasks are due',
            trailing: Switch(
              value: _notificationsEnabled,
              activeTrackColor: _primary,
              onChanged: _setNotificationsEnabled,
            ),
          ),
          _row(
            palette,
            icon: Icons.schedule,
            title: 'Time',
            value: _formatOption(_reminderTime),
            enabled: _notificationsEnabled,
            onTap: () => _pickOption(
              title: 'Reminder time',
              options: reminderTimeOptions,
              current: _reminderTime,
              prefKey: 'dailyReminderTime',
              apply: (v) => _reminderTime = v,
            ),
          ),
          _row(
            palette,
            icon: Icons.event_outlined,
            title: 'Heads-up',
            subtitle: 'How early to warn before a task is due',
            value: _notifyBefore == 'SAME DAY'
                ? 'Same day'
                : '${_formatOption(_notifyBefore)} early',
            enabled: _notificationsEnabled,
            onTap: () => _pickOption(
              title: 'Heads-up',
              options: notifyBeforeOptions,
              current: _notifyBefore,
              prefKey: 'notifyBeforeExpiry',
              apply: (v) => _notifyBefore = v,
            ),
          ),
          _row(
            palette,
            icon: Icons.send_outlined,
            title: 'Send a test notification',
            onTap: () async {
              await NotificationService().showTestNotification();
              if (mounted) {
                _showSnack(
                  'Test notification sent. Check the notification shade.',
                );
              }
            },
          ),
        ]),
        _section(palette, 'Remind me about', [
          for (final room in roomThemes)
            _row(
              palette,
              icon: room.icon,
              iconColor: room.accent(isDark),
              iconTint: room.tint(isDark),
              title: room.name,
              enabled: _notificationsEnabled,
              trailing: Switch(
                value: !_mutedRooms.contains(room.categoryKey),
                activeTrackColor: _primary,
                onChanged: _notificationsEnabled
                    ? (v) => _setRoomEnabled(room.categoryKey, v)
                    : null,
              ),
            ),
        ]),
        _sectionHeader(palette, 'Appearance'),
        _card(
          palette,
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              for (final (value, label, icon) in const [
                ('LIGHT', 'Light', Icons.light_mode_outlined),
                ('DARK', 'Dark', Icons.dark_mode_outlined),
                ('SYSTEM', 'System', Icons.phone_iphone),
              ])
                Expanded(
                  child: _themeButton(
                    palette,
                    label: label,
                    icon: icon,
                    selected: _interfaceTheme == value,
                    onTap: () => _setTheme(value),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader(palette, 'Backup'),
        _card(
          palette,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _iconBadge(Icons.cloud_outlined, _primary, palette.tint),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Google Drive', style: palette.title),
                        Text(
                          _currentUser != null
                              ? '${_currentUser!.email} · Last backup: $_lastBackupTime'
                              : 'Back up your tasks to your own Drive',
                          style: palette.subtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_currentUser == null)
                _primaryButton('Sign in to back up', _handleSignIn)
              else
                Row(
                  children: [
                    Expanded(
                      child: _primaryButton('Back up now', _handleBackup),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          foregroundColor: palette.text,
                          side: BorderSide(color: palette.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleRestore,
                        child: const Text(
                          'Restore…',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _section(palette, 'About', [
          _row(
            palette,
            icon: Icons.history,
            title: 'Cleaning history',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LogHistoryPage()),
            ),
          ),
          _row(
            palette,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyPage(),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _sectionHeader(_Palette palette, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: palette.muted,
        ),
      ),
    );
  }

  Widget _card(_Palette palette, {required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _section(_Palette palette, String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(palette, title),
          _card(
            palette,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, indent: 66, color: palette.divider),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color, Color tint) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _row(
    _Palette palette, {
    required IconData icon,
    required String title,
    Color iconColor = _primary,
    Color? iconTint,
    String? subtitle,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _iconBadge(icon, iconColor, iconTint ?? palette.tint),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: palette.title),
                      if (subtitle != null)
                        Text(subtitle, style: palette.subtitle),
                    ],
                  ),
                ),
                if (value != null)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: palette.accentText,
                    ),
                  ),
                ?trailing,
                if (onTap != null)
                  Icon(Icons.chevron_right, color: palette.muted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeButton(
    _Palette palette, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? palette.tint : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? palette.accentText : palette.text,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? palette.accentText : palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: _primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

/// Colors matching the dashboard's sage palette in main.dart.
class _Palette {
  _Palette(bool isDark)
    : card = isDark ? const Color(0xFF1E211A) : Colors.white,
      border = isDark ? const Color(0x14FFFFFF) : const Color(0xFFDDE3D8),
      divider = isDark ? const Color(0x14FFFFFF) : const Color(0xFFEEF1EA),
      text = isDark ? const Color(0xFFEEF2E9) : const Color(0xFF26301F),
      muted = isDark ? const Color(0xFF9AA48F) : const Color(0xFF5E6857),
      tint = isDark ? const Color(0x2E4A9B73) : const Color(0xFFEAF3EC),
      accentText = isDark ? const Color(0xFF7FD3A4) : const Color(0xFF2E6B4E);

  final Color card;
  final Color border;
  final Color divider;
  final Color text;
  final Color muted;
  final Color tint;
  final Color accentText;

  TextStyle get title =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: text);
  TextStyle get subtitle =>
      TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted);
}
