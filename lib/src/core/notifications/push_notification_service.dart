import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);

class PushNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _weeklyPullsNotificationId = 1001;
  static const String _weeklyPullsPayload = 'my-pulls';

  /// Initialize the plugin and timezone data. onNotificationTap will be
  /// invoked when the user taps a delivered notification.
  Future<void> initialize({
    Future<void> Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;

    // Init timezone database and attempt to set local location from platform.
    try {
      tzdata.initializeTimeZones();

      // Try platform channel first to get the device timezone identifier.
      try {
        const channel = MethodChannel('takion/native_timezone');
        final platformTz = await channel.invokeMethod<String>('getLocalTimezone');
        if (platformTz != null && platformTz.isNotEmpty) {
          tz.setLocalLocation(tz.getLocation(platformTz));
        } else {
          // Fallback to UTC when platform doesn't provide one
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      } catch (_) {
        // If platform channel fails, fallback to UTC
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (_) {
      // Ensure at least UTC is available
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (onNotificationTap != null) await onNotificationTap(payload);
      },
    );

    _initialized = true;
  }

  Future<void> syncRegistration({
    required bool enabled,
    int? initialPullCount,
    int? weekday,
    int? hour,
    int? minute,
  }) async {
    if (enabled) {
      // Schedule weekly reminder using the provided initial count and schedule
      final count = initialPullCount ?? 0;
      final w = weekday ?? DateTime.tuesday;
      final h = hour ?? 20;
      final m = minute ?? 0;
      await _scheduleWeeklyPullsReminder(count, w, h, m);
    } else {
      await _plugin.cancel(_weeklyPullsNotificationId);
    }
  }

  Future<void> _scheduleWeeklyPullsReminder(int count, int weekday, int hour, int minute) async {
    final title = 'Pull List Reminder';
    final body =
        'You have $count issue${count == 1 ? '' : 's'} in your pull list this week.';

    final androidDetails = AndroidNotificationDetails(
      'takion_notifications',
      'Takion Notifications',
      channelDescription: 'General notifications from Takion',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
      visibility: NotificationVisibility.public,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for the next occurrence of the requested weekday/hour/minute in local time.
    final now = tz.TZDateTime.now(tz.local);
    // weekday: 1=Mon .. 7=Sun
    final targetWeekday = weekday.clamp(1, 7);
    int days = (targetWeekday - now.weekday + 7) % 7;
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: days));
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _plugin.zonedSchedule(
      _weeklyPullsNotificationId,
      title,
      body,
      scheduledDate,
      details,
      payload: _weeklyPullsPayload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Request notification permission from the OS. Uses permission_handler
  /// to request notifications permission cross-platform.
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> markCurrentDeviceDisabled() async {
    await _plugin.cancel(_weeklyPullsNotificationId);
  }

  Future<void> dispose() async {
    // No explicit dispose needed for the plugin
  }
}
