import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'models.dart';
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

const String _channelId = 'cleaning_reminders';
const String _channelName = 'Cleaning Reminders';
const String _channelDescription = 'Notifications for cleaning tasks';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SharedPreferences? _prefs;
  bool _initialized = false;

  @visibleForTesting
  set notificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    _notificationsPlugin = plugin;
  }

  @visibleForTesting
  void setInitializedForTesting(bool initialized) {
    _initialized = initialized;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance._prefs = null;
    _instance._initialized = false;
  }

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_notify');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
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

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('Android POST_NOTIFICATIONS granted: $granted');

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    }

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
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

    final id = _notificationIdForTask(task);

    if (scheduledDate.isBefore(DateTime.now())) {
      // The reminder time is already past — either the task is overdue or the
      // notify-before window has elapsed. Fire an immediate "due now" notice
      // instead of silently dropping the reminder.
      await _notificationsPlugin.show(
        id: id,
        title: 'CLEANING REQUIRED',
        body: 'Task "${task.title}" is due.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      debugPrint('Showed immediate due notification for ${task.title} (ID: $id)');
      return;
    }

    final scheduleMode = await _resolveAndroidScheduleMode();

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'CLEANING REQUIRED',
        body: 'Task "${task.title}" is due soon.',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
      );
      debugPrint(
        'Scheduled notification for ${task.title} at $scheduledDate '
        '(ID: $id, mode: $scheduleMode)',
      );
    } on PlatformException catch (e) {
      // exact_alarms_not_permitted can occur if the user revokes the
      // SCHEDULE_EXACT_ALARM permission between the capability check and
      // the schedule call. Retry once with an inexact mode.
      if (e.code == 'exact_alarms_not_permitted' &&
          scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        debugPrint(
          'Exact alarms not permitted, falling back to inexact for ${task.title}',
        );
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: 'CLEANING REQUIRED',
          body: 'Task "${task.title}" is due soon.',
          scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (kIsWeb || !Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact =
        await androidPlugin?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      id: 999999,
      title: 'TEST NOTIFICATION',
      body: 'If you see this, notifications are working.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    debugPrint('Showed test notification');
  }

  int _notificationIdForTask(Task task) {
    return task.id ?? task.title.hashCode.abs();
  }

  Future<void> cancelTaskNotification(Task task) async {
    final id = _notificationIdForTask(task);
    await _notificationsPlugin.cancel(id: id);
    debugPrint('Cancelled notification for ${task.title} (ID: $id)');
  }

  Future<void> rescheduleAll([List<Task>? tasks]) async {
    if (!_initialized) {
      // init() was skipped (e.g. testingMode). Avoid touching tz.local /
      // platform channels — there's nothing to schedule against anyway.
      return;
    }
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

    if (kDebugMode) {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending notifications after reschedule: ${pending.length}');
      for (final p in pending) {
        debugPrint('  id=${p.id} title=${p.title} body=${p.body}');
      }
    }
  }
}
