import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_background_task.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);

class PushNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _workmanagerInitialized = false;

  static const String _taskName = 'weeklyPullReminder';

  Future<void> initialize({
    Future<void> Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;

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

  Future<void> _ensureWorkmanager() async {
    if (_workmanagerInitialized) return;
    await Workmanager().initialize(pullReminderBackgroundCallback);
    _workmanagerInitialized = true;
  }

  Future<void> syncRegistration({
    required bool enabled,
    int? initialPullCount,
    int? weekday,
    int? hour,
    int? minute,
  }) async {
    await _ensureWorkmanager();

    if (enabled) {
      final now = DateTime.now();
      final w = weekday ?? DateTime.tuesday;
      final h = hour ?? 20;
      final m = minute ?? 0;

      int days = (w - now.weekday + 7) % 7;
      var scheduledDate = DateTime(now.year, now.month, now.day, h, m)
          .add(Duration(days: days));
      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        frequency: const Duration(days: 7),
        initialDelay: scheduledDate.difference(now),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 10),
      );
    } else {
      await Workmanager().cancelByUniqueName(_taskName);
    }
  }

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> markCurrentDeviceDisabled() async {
    await _ensureWorkmanager();
    await Workmanager().cancelByUniqueName(_taskName);
  }

  Future<void> dispose() async {}

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
