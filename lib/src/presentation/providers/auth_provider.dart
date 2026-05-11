import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/notifications/push_notification_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated }

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<AuthStatus> build() async => AuthStatus.authenticated;

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(pushNotificationServiceProvider).markCurrentDeviceDisabled();
    state = const AsyncValue.data(AuthStatus.authenticated);
  }
}
