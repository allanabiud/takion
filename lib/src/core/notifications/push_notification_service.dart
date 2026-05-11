import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService();
});

class PushNotificationService {
  Future<void> initialize() async {}

  Future<void> syncRegistration({required bool enabled}) async {}

  Future<void> markCurrentDeviceDisabled() async {}

  Future<void> dispose() async {}
}
