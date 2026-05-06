import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleaning_tracker/notification_service.dart';
import 'package:cleaning_tracker/models.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    NotificationService.resetForTesting();
    notificationService = NotificationService();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService.notificationsPlugin = mockPlugin;
    notificationService.setInitializedForTesting(true);

    // Default mock behavior
    when(
      () => mockPlugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);

    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async => {});

    when(
      () => mockPlugin.cancel(
        id: any(named: 'id'),
        tag: any(named: 'tag'),
      ),
    ).thenAnswer((_) async => {});

    when(() => mockPlugin.cancelAll()).thenAnswer((_) async => {});

    when(
      () => mockPlugin.pendingNotificationRequests(),
    ).thenAnswer((_) async => <PendingNotificationRequest>[]);
  });

  test(
    'scheduleTaskNotification respects notifications_enabled setting (bool)',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);

      final task = Task(
        title: 'Test Task',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );

      await notificationService.scheduleTaskNotification(task);

      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    },
  );

  test(
    'scheduleTaskNotification respects notifications_enabled setting (string)',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notifications_enabled', 'false');

      final task = Task(
        title: 'Test Task',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );

      await notificationService.scheduleTaskNotification(task);

      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    },
  );

  test('scheduleTaskNotification schedules correctly when enabled', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setString('notifyBeforeExpiry', 'SAME DAY');
    await prefs.setString('dailyReminderTime', '10:00 AM');

    final now = DateTime.now();
    final task = Task(
      title: 'Enabled Task',
      interval: '7 DAYS',
      lastCompleted: now.subtract(const Duration(days: 1)), // Due in 6 days
    );

    await notificationService.scheduleTaskNotification(task);

    verify(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: 'CLEANING REQUIRED',
        body: 'Task "Enabled Task" is due soon.',
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      ),
    ).called(1);
  });

  test('cancelTaskNotification cancels the correct notification', () async {
    await notificationService.cancelTaskNotification('Test Task');
    final id = 'Test Task'.hashCode.abs();
    verify(() => mockPlugin.cancel(id: id)).called(1);
  });

  test('rescheduleAll cancels all and schedules tasks', () async {
    final task = Task(
      title: 'Task 1',
      interval: '7 DAYS',
      lastCompleted: DateTime.now().add(const Duration(days: 10)), // Future
    );

    await notificationService.rescheduleAll([task]);

    verify(() => mockPlugin.cancelAll()).called(1);
    verify(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).called(1);
  });
}
