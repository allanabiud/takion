import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";

part "auth_provider.g.dart";

enum AuthStatus { authenticated, unauthenticated }

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<AuthStatus> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final token = await dao.getString("metron_api_token");
    if (token != null && token.trim().isNotEmpty) {
      return AuthStatus.authenticated;
    }
    return AuthStatus.unauthenticated;
  }

  Future<void> setUnauthenticated() async {
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}
