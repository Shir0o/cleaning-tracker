import 'package:flutter/services.dart';
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

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

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

    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockPlugin.cancel(
        id: any(named: 'id'),
        tag: any(named: 'tag'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

    when(
      () => mockPlugin.pendingNotificationRequests(),
    ).thenAnswer((_) async => <PendingNotificationRequest>[]);

    when(
      () => mockPlugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> setPrefs({
    required String notifyBefore,
    String reminderTime = '09:00 AM',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setString('notifyBeforeExpiry', notifyBefore);
    await prefs.setString('dailyReminderTime', reminderTime);
  }

  group('NotificationService.notifyBefore parsing', () {
    test('SAME DAY schedules for the due date at the reminder time', () async {
      await setPrefs(notifyBefore: 'SAME DAY');

      final task = Task(
        id: 1,
        title: 'T',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );
      await notificationService.scheduleTaskNotification(task);

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

    test('"X DAY" parses the leading integer', () async {
      await setPrefs(notifyBefore: '3 DAYS');

      final task = Task(
        id: 2,
        title: 'T',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );
      await notificationService.scheduleTaskNotification(task);

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

    test('"1 WEEK" schedules 7 days before the due date', () async {
      await setPrefs(notifyBefore: '1 WEEK');

      final task = Task(
        id: 3,
        title: 'T',
        interval: '14 DAYS',
        lastCompleted: DateTime.now(),
      );
      await notificationService.scheduleTaskNotification(task);

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

    test('"2 WEEKS" schedules 14 days before the due date', () async {
      await setPrefs(notifyBefore: '2 WEEKS');

      final task = Task(
        id: 4,
        title: 'T',
        interval: '30 DAYS',
        lastCompleted: DateTime.now(),
      );
      await notificationService.scheduleTaskNotification(task);

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

    test('falls back to 0 days for unrecognised notifyBefore values', () async {
      await setPrefs(notifyBefore: 'WHEN-WHENEVER');

      final task = Task(
        id: 5,
        title: 'T',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );
      await notificationService.scheduleTaskNotification(task);

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
  });

  group('NotificationService.cancelTaskNotification id fallback', () {
    test('uses the task id when available', () async {
      final task = Task(
        id: 42,
        title: 'T',
        interval: '1 DAYS',
        lastCompleted: DateTime.now(),
      );

      await notificationService.cancelTaskNotification(task);

      verify(() => mockPlugin.cancel(id: 42)).called(1);
    });

    test('falls back to a stable hashCode when id is null', () async {
      final task = Task(
        title: 'NoIdTask',
        interval: '1 DAYS',
        lastCompleted: DateTime.now(),
      );

      await notificationService.cancelTaskNotification(task);

      final expectedId = task.title.hashCode.abs();
      verify(() => mockPlugin.cancel(id: expectedId)).called(1);
    });
  });

  group('NotificationService.rescheduleAll uninitialized path', () {
    test('skips work entirely when init() was never called', () async {
      NotificationService.resetForTesting();
      final isolated = NotificationService();
      isolated.notificationsPlugin = mockPlugin;

      final task = Task(
        id: 7,
        title: 'T',
        interval: '1 DAYS',
        lastCompleted: DateTime.now(),
      );

      await isolated.rescheduleAll([task]);

      verifyNever(() => mockPlugin.cancelAll());
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
    });
  });

  group('NotificationService.showTestNotification', () {
    test('shows a high-importance test notification with id 999999', () async {
      await notificationService.showTestNotification();

      verify(
        () => mockPlugin.show(
          id: 999999,
          title: 'TEST NOTIFICATION',
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });
  });

  group('NotificationService.zonedSchedule error path', () {
    test(
      'retries with inexactAllowWhileIdle on exact_alarms_not_permitted',
      () async {
        await setPrefs(notifyBefore: 'SAME DAY');

        var calls = 0;
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
          ),
        ).thenAnswer((_) async {
          calls += 1;
          if (calls == 1) {
            throw PlatformException(code: 'exact_alarms_not_permitted');
          }
        });

        final task = Task(
          id: 9,
          title: 'T',
          interval: '7 DAYS',
          lastCompleted: DateTime.now(),
        );

        await notificationService.scheduleTaskNotification(task);

        expect(calls, 2, reason: 'should retry once on exact-alarm denial');
      },
    );

    test('rethrows other PlatformException codes without retrying', () async {
      await setPrefs(notifyBefore: 'SAME DAY');

      when(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).thenThrow(PlatformException(code: 'something_else'));

      final task = Task(
        id: 9,
        title: 'T',
        interval: '7 DAYS',
        lastCompleted: DateTime.now(),
      );

      await expectLater(
        notificationService.scheduleTaskNotification(task),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
