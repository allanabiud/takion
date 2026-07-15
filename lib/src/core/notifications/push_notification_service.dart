import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);

class PushNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize({
    Future<void> Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('ic_notification');
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

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> showNotification({
    required String? title,
    required String? body,
    required Map<String, dynamic> data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'takion_local',
      'Takion Notifications',
      channelDescription: 'Local notifications from Takion',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );
  }

  Future<void> dispose() async {}

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
