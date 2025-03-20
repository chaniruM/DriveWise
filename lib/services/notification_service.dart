import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService{
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInit = false;
  bool get isInit => _isInit;

  Future<void> initNotifications() async{
    if (isInit) return;

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsiOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      iOS: initSettingsiOS,
      android: initSettingsAndroid,
    );

    await notificationPlugin.initialize(initSettings);
    await _createNotificationChannel();
    _isInit = true;
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    // Create channel only if it doesn't exist
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  NotificationDetails notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        playSound: true,
      )
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    try {
      await notificationPlugin.show(
        id,
        title,
        body,
        notificationDetails(),
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  //scheduling reminders
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
      await notificationPlugin.pendingNotificationRequests();

      bool alreadyScheduled = pendingNotifications.any((notification) => notification.id == id);

      if (!alreadyScheduled) {
        await notificationPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }
}
