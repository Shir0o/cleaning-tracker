import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'main.dart' show Task;
import 'database_service.dart';

class NotificationSettings {
  final bool enabled;
  final String notifyBefore;
  final String reminderTime;

  NotificationSettings({
    required this.enabled,
    required this.notifyBefore,
    required this.reminderTime,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SharedPreferences? _prefs;

  @visibleForTesting
  set notificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    _notificationsPlugin = plugin;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance._prefs = null;
  }

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<NotificationSettings> _getSettings() async {
    final prefs = await _getPrefs();
    // Support both bool and string for transition, then prefer bool
    final dynamic notificationsEnabledPref = prefs.get('notifications_enabled');
    bool notificationsEnabled = true;
    if (notificationsEnabledPref is bool) {
      notificationsEnabled = notificationsEnabledPref;
    } else if (notificationsEnabledPref is String) {
      notificationsEnabled = notificationsEnabledPref != 'false';
    }

    final String notifyBeforeStr =
        prefs.getString('notifyBeforeExpiry') ?? '2 DAYS';
    final String reminderTimeStr =
        prefs.getString('dailyReminderTime') ?? '09:00 AM';

    return NotificationSettings(
      enabled: notificationsEnabled,
      notifyBefore: notifyBeforeStr,
      reminderTime: reminderTimeStr,
    );
  }

  Future<void> scheduleTaskNotification(Task task) async {
    final settings = await _getSettings();

    await _scheduleTaskNotification(
      task,
      settings.enabled,
      settings.notifyBefore,
      settings.reminderTime,
    );
  }

  Future<void> _scheduleTaskNotification(
    Task task,
    bool notificationsEnabled,
    String notifyBeforeStr,
    String reminderTimeStr,
  ) async {
    if (!notificationsEnabled) return;

    // Calculate due date
    final dueDate = task.lastCompleted.add(task.intervalDuration);

    // Parse notifyBefore
    int daysBefore = 0;
    if (notifyBeforeStr == 'SAME DAY') {
      daysBefore = 0;
    } else if (notifyBeforeStr.contains('DAY')) {
      daysBefore = int.tryParse(notifyBeforeStr.split(' ')[0]) ?? 0;
    } else if (notifyBeforeStr == '1 WEEK') {
      daysBefore = 7;
    } else if (notifyBeforeStr == '2 WEEKS') {
      daysBefore = 14;
    }

    // Parse reminder time (e.g., "09:00 AM")
    final timeParts = reminderTimeStr.split(' ');
    final hm = timeParts[0].split(':');
    int hour = int.tryParse(hm[0]) ?? 9;
    int minute = int.tryParse(hm[1]) ?? 0;
    if (timeParts[1] == 'PM' && hour < 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;

    final scheduledDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      hour,
      minute,
    ).subtract(Duration(days: daysBefore));

    if (scheduledDate.isBefore(DateTime.now())) {
      // If it's already past the reminder time for the due date, don't schedule
      return;
    }

    final id = task.title.hashCode.abs();

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'CLEANING REQUIRED',
      body: 'Task "${task.title}" is due soon.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'cleaning_reminders',
          'Cleaning Reminders',
          channelDescription: 'Notifications for cleaning tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint(
      'Scheduled notification for ${task.title} at $scheduledDate (ID: $id)',
    );
  }

  Future<void> cancelTaskNotification(String title) async {
    final id = title.hashCode.abs();
    await _notificationsPlugin.cancel(id: id);
    debugPrint('Cancelled notification for $title (ID: $id)');
  }

  Future<void> rescheduleAll([List<Task>? tasks]) async {
    List<Task> tasksToSchedule = tasks ?? [];

    if (tasks == null) {
      tasksToSchedule = await DatabaseService().getTasks();
    }

    final settings = await _getSettings();

    await _notificationsPlugin.cancelAll();
    debugPrint(
      'Cancelled all notifications. Rescheduling ${tasksToSchedule.length} tasks...',
    );
    for (final task in tasksToSchedule) {
      await _scheduleTaskNotification(
        task,
        settings.enabled,
        settings.notifyBefore,
        settings.reminderTime,
      );
    }
  }
}
