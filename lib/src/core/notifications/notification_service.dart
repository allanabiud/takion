import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_provider.dart';

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

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
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

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Weekly summary of your comic pulls',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

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
  }

  Future<void> cancel() async {
    await _plugin.cancel(_notificationId);
  }
}
