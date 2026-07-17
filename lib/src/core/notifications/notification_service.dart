import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_provider.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'weekly_pull_channel';
  static const _channelName = 'Weekly Pull Summary';
  static const _notificationId = 1001;

  VoidCallback? onNavigateToMyPulls;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      AppLogger.info('Notification service initialized');
    } catch (e) {
      AppLogger.warning('Notification service init failed', error: e);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.notificationResponseType !=
        NotificationResponseType.selectedNotification) {
      return;
    }
    onNavigateToMyPulls?.call();
  }

  tz.TZDateTime _nextDayAt8PM(NotificationDay day) {
    final now = tz.TZDateTime.now(tz.local);
    int daysUntil = day.dartWeekday - now.weekday;
    if (daysUntil < 0 || (daysUntil == 0 && now.hour >= 20)) {
      daysUntil += 7;
    }
    return tz.TZDateTime(tz.local, now.year, now.month, now.day + daysUntil, 20);
  }

  Future<void> scheduleWeekly(int count, NotificationDay day) async {
    await cancel();

    final scheduledDate = _nextDayAt8PM(day);
    AppLogger.info('Scheduling weekly pull notification: $count pulls on $day at ${_formatTime(scheduledDate)}');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Weekly summary of your comic pulls',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        _notificationId,
        'Weekly Pull Summary',
        'You have $count pulls this week',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
      AppLogger.info('Weekly pull notification scheduled successfully');
    } catch (e) {
      AppLogger.warning('Failed to schedule weekly pull notification', error: e);
    }
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return (await android.requestNotificationsPermission()) ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return (await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )) ?? true;
    }
    return true;
  }

  Future<void> cancel() async {
    try {
      await _plugin.cancel(_notificationId);
      AppLogger.info('Weekly pull notification cancelled');
    } catch (e) {
      AppLogger.warning('Failed to cancel weekly pull notification', error: e);
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
