import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/network/metron_dio_factory.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/network/rate_limit_state_store.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/core/auth/auth_provider.dart";

final cacheHeaderStoreProvider = Provider<CacheHeaderStore>((ref) {
  return CacheHeaderStore();
});

/// Persists observed Metron rate-limit state to SQLite so a 429 cooldown
/// survives app restarts (Phase 5 Step 1).
final rateLimitStateStoreProvider = Provider<RateLimitStateStore>((ref) {
  return RateLimitStateStore(ref.read(driftDatabaseProvider).syncMetaDao);
});

final rateLimitInterceptorProvider = Provider<RateLimitInterceptor>((ref) {
  final interceptor = RateLimitInterceptor(
    stateStore: ref.read(rateLimitStateStoreProvider),
  );
  ref.onDispose(interceptor.dispose);
  return interceptor;
});

final dioProvider = Provider<Dio>((ref) {
  // The interceptor chain (rate limiting, conditional requests, auth
  // injection, 429/5xx retries) is built by the shared factory so the
  // background Workmanager sync behaves identically to the foreground.
  return buildMetronDio(
    readToken: () => ref
        .read(driftDatabaseProvider)
        .settingsDao
        .getString(SettingsKeys.metronApiToken),
    db: ref.read(driftDatabaseProvider),
    cacheHeaderStore: ref.read(cacheHeaderStoreProvider),
    rateLimitInterceptor: ref.read(rateLimitInterceptorProvider),
    onAuthFailure: () => ref.invalidate(authStateProvider),
  );
});
