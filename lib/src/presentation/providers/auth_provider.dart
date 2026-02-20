import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/network/auth_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated }

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<AuthStatus> build() async {
    final creds = await ref.watch(authServiceProvider).getCredentials();
    return creds != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final isValid = await ref.read(authServiceProvider).verifyCredentials(username, password);
      if (isValid) {
        await ref.read(authServiceProvider).saveCredentials(username, password);
        state = const AsyncValue.data(AuthStatus.authenticated);
      } else {
        state = AsyncValue.error('Invalid username or password', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).clearCredentials();
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}
