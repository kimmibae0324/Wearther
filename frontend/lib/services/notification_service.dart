import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static const int umbrellaNotificationId = 1001;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'umbrella_alert_channel',
    '우산 알림',
    channelDescription: '비 예보가 있을 때 우산을 챙기도록 알려주는 알림입니다.',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails();

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;

    final bool isSupportedPlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!isSupportedPlatform) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);

    tz.initializeTimeZones();

    try {
      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    await _requestPermission();

    _isInitialized = true;
  }

  static Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> showUmbrellaNotificationNow({
    required String message,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notifications.show(
      id: umbrellaNotificationId,
      title: '☔ 우산 챙기세요!',
      body: message,
      notificationDetails: _notificationDetails,
    );
  }

  static Future<void> scheduleUmbrellaNotification({
    required DateTime scheduledTime,
    required String message,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.cancel(id: umbrellaNotificationId);

    await _notifications.zonedSchedule(
      id: umbrellaNotificationId,
      title: '☔ 우산 챙기세요!',
      body: message,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelUmbrellaNotification() async {
    await _notifications.cancel(id: umbrellaNotificationId);
  }
}