import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_provider.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'weekly_pull_channel';
  static const _channelName = 'Weekly Pull Summary';
  static const _notificationId = 1001;

  static const _syncChannelId = 'drive_sync_channel';
  static const _syncChannelName = 'Drive Sync';
  static const _syncNotificationId = 2001;

  bool Function()? onNavigateToMyPulls;

  bool _pendingNavigateToMyPulls = false;
  bool get hasPendingMyPullsNavigation => _pendingNavigateToMyPulls;

  int? _lastCount;
  NotificationDay? _lastDay;
  Future<void>? _pendingSchedule;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const settings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            backgroundNotificationHandler,
      );

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Weekly summary of your comic pulls',
          importance: Importance.high,
        );
        await android.createNotificationChannel(channel);

        const syncChannel = AndroidNotificationChannel(
          _syncChannelId,
          _syncChannelName,
          description: 'Notifications for Google Drive sync status',
          importance: Importance.low,
        );
        await android.createNotificationChannel(syncChannel);
      }

      AppLogger.info('Notification service initialized');
    } catch (e) {
      AppLogger.warning('Notification service init failed', error: e);
    }
  }

  Future<void> showSyncNotification({
    required String title,
    required String body,
    bool isOngoing = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _syncChannelName,
      channelDescription: 'Notifications for Google Drive sync status',
      importance: Importance.low,
      priority: Priority.low,
      icon: 'ic_notification',
      ongoing: isOngoing,
      autoCancel: !isOngoing,
      showProgress: isOngoing,
      indeterminate: isOngoing,
      showWhen: true,
    );
    final details = NotificationDetails(android: androidDetails);
    try {
      await _plugin.show(_syncNotificationId, title, body, details);
    } catch (e) {
      AppLogger.warning('Failed to show sync notification', error: e);
    }
  }

  Future<void> cancelSyncNotification() async {
    try {
      await _plugin.cancel(_syncNotificationId);
    } catch (e) {
      AppLogger.warning('Failed to cancel sync notification', error: e);
    }
  }

  Future<void> checkPendingNotificationLaunch() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details != null &&
          details.didNotificationLaunchApp &&
          details.notificationResponse != null) {
        _onNotificationResponse(details.notificationResponse!);
      }
    } catch (e) {
      AppLogger.debug('Pending notification launch check skipped: $e');
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.notificationResponseType !=
        NotificationResponseType.selectedNotification) {
      return;
    }
    if (response.payload == 'my_pulls' ||
        response.payload == null ||
        response.payload!.isEmpty) {
      _pendingNavigateToMyPulls = true;
      tryNavigateToMyPulls();
    }
  }

  bool tryNavigateToMyPulls() {
    if (!_pendingNavigateToMyPulls) return false;
    if (onNavigateToMyPulls != null) {
      final handled = onNavigateToMyPulls!();
      if (handled) {
        _pendingNavigateToMyPulls = false;
        return true;
      }
    }
    return false;
  }

  tz.TZDateTime _nextDayAt8PM(NotificationDay day) {
    final now = tz.TZDateTime.now(tz.local);
    int daysUntil = day.dartWeekday - now.weekday;
    if (daysUntil < 0 || (daysUntil == 0 && now.hour >= 20)) {
      daysUntil += 7;
    }
    final targetDate = now.add(Duration(days: daysUntil));
    return tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      20,
      0,
    );
  }

  Future<void> scheduleWeekly(int count, NotificationDay day) async {
    if (_lastCount == count && _lastDay == day) {
      AppLogger.info('Weekly pull notification already scheduled; skipping');
      return;
    }
    if (_pendingSchedule != null) {
      AppLogger.info('Weekly pull notification already scheduled; skipping');
      return;
    }
    final future = _doScheduleWeekly(count, day);
    _pendingSchedule = future;
    try {
      await future;
      _lastCount = count;
      _lastDay = day;
    } finally {
      if (identical(_pendingSchedule, future)) {
        _pendingSchedule = null;
      }
    }
  }

  Future<void> _doScheduleWeekly(int count, NotificationDay day) async {
    await cancel();

    if (count <= 0) {
      AppLogger.info('No pulls this week; weekly pull notification cancelled');
      return;
    }

    final scheduledDate = _nextDayAt8PM(day);
    AppLogger.info(
      'Scheduling weekly pull notification: $count pulls on ${day.name} at ${DateFormatter.time(scheduledDate)} (${scheduledDate.location.name})',
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Weekly summary of your comic pulls',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );
    const details = NotificationDetails(android: androidDetails);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExactly =
        await android?.canScheduleExactNotifications() ?? false;

    try {
      await _plugin.zonedSchedule(
        _notificationId,
        'Weekly Pull Summary',
        count == 1
            ? 'You have 1 pull this week'
            : 'You have $count pulls this week',
        scheduledDate,
        details,
        payload: 'my_pulls',
        androidScheduleMode: canScheduleExactly
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
      AppLogger.info(
        'Weekly pull notification scheduled successfully for $scheduledDate',
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to schedule weekly pull notification',
        error: e,
      );
    }
  }

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return (await android.requestNotificationsPermission()) ?? true;
  }

  /// Android 14+ requires explicit user approval for exact alarms.
  Future<void> requestExactAlarmPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    final canScheduleExactly =
        await android.canScheduleExactNotifications() ?? false;
    if (!canScheduleExactly) {
      await android.requestExactAlarmsPermission();
    }
  }

  Future<void> cancel() async {
    _lastCount = null;
    _lastDay = null;
    try {
      await _plugin.cancel(_notificationId);
      AppLogger.info('Weekly pull notification cancelled');
    } catch (e) {
      AppLogger.warning('Failed to cancel weekly pull notification', error: e);
    }
  }
}

@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) {
  // Navigation on tap is handled by checkPendingNotificationLaunch() on foreground.
}
