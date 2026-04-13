import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleaning_tracker/notification_service.dart';
import 'package:cleaning_tracker/main.dart' show Task;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake implements InitializationSettings {}
class FakeNotificationDetails extends Fake implements NotificationDetails {}

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
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': true,
      'notifyBeforeExpiry': '2 DAYS',
      'dailyReminderTime': '09:00 AM',
    });
    notificationService = NotificationService();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService.notificationsPlugin = mockPlugin;

    when(() => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        )).thenAnswer((_) async => true);

    when(() => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        )).thenAnswer((_) async => {});

    when(() => mockPlugin.cancelAll()).thenAnswer((_) async => {});
  });

  test('Benchmark rescheduleAll', () async {
    final tasks = List.generate(100, (i) => Task(
      title: 'Task $i',
      interval: '7 DAYS',
      lastCompleted: DateTime.now().add(const Duration(days: 10)),
    ));

    final stopwatch = Stopwatch()..start();
    await notificationService.rescheduleAll(tasks);
    stopwatch.stop();

    print('Benchmark: rescheduleAll with 100 tasks took ${stopwatch.elapsedMicroseconds} microseconds');
  });
}
