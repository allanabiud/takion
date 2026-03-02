import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/network/supabase_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    client: ref.watch(supabaseClientProvider),
    hiveService: ref.watch(hiveServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class PushNotificationService {
  PushNotificationService({
    required SupabaseClient client,
    required HiveService hiveService,
  }) : _client = client,
       _hiveService = hiveService;

  final SupabaseClient _client;
  final HiveService _hiveService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static const _settingsBoxName = 'settings_box';
  static const _pushEnabledKey = 'push_pull_notifications_enabled';
  static const _deviceIdKey = 'push_device_id';
  static const _tableName = 'device_push_tokens';

  static const _pullsChannelId = 'pull_notifications';
  static const _pullsChannelName = 'Pull Notifications';
  static const _pullsChannelDescription =
      'Alerts for upcoming or new pull-list releases';

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidInitSettings);
    await _localNotifications.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      _pullsChannelId,
      _pullsChannelName,
      description: _pullsChannelDescription,
      importance: Importance.high,
    );
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      final enabled = await _readPushEnabledPreference();
      await _upsertCurrentUserToken(token, enabled: enabled);
    });

    _foregroundMessageSub = FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      final android = notification?.android;
      if (notification == null || android == null) return;

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _pullsChannelId,
            _pullsChannelName,
            channelDescription: _pullsChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  Future<void> syncRegistration({required bool enabled}) async {
    if (enabled) {
      await _enableAndRegisterCurrentDevice();
      return;
    }
    await markCurrentDeviceDisabled();
  }

  Future<void> markCurrentDeviceDisabled() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final deviceId = await _getOrCreateDeviceId();
    await _client
        .from(_tableName)
        .update({
          'enabled': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', user.id)
        .eq('device_id', deviceId);
  }

  Future<void> _enableAndRegisterCurrentDevice() async {
    final permission = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final authorized =
        permission.authorizationStatus == AuthorizationStatus.authorized ||
        permission.authorizationStatus == AuthorizationStatus.provisional;
    if (!authorized) {
      await markCurrentDeviceDisabled();
      throw StateError('Notification permission was not granted.');
    }

    final token = await _messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      throw StateError('Unable to get push token from Firebase.');
    }

    await _upsertCurrentUserToken(token, enabled: true);
  }

  Future<void> _upsertCurrentUserToken(
    String token, {
    required bool enabled,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final deviceId = await _getOrCreateDeviceId();
    await _client.from(_tableName).upsert({
      'user_id': user.id,
      'device_id': deviceId,
      'fcm_token': token,
      'platform': Platform.operatingSystem,
      'enabled': enabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,device_id');
  }

  Future<bool> _readPushEnabledPreference() async {
    final box = await _hiveService.openBox(_settingsBoxName);
    return (box.get(_pushEnabledKey, defaultValue: false) as bool?) ?? false;
  }

  Future<String> _getOrCreateDeviceId() async {
    final box = await _hiveService.openBox(_settingsBoxName);
    final existing = (box.get(_deviceIdKey) as String?)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure().nextInt(1 << 32);
    final created =
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-${random.toRadixString(36)}';
    await box.put(_deviceIdKey, created);
    return created;
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundMessageSub?.cancel();
  }
}
