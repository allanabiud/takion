import "dart:typed_data";

import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/core/network/metron_dio_factory.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Serves queued responses in order and records every request it receives.
class QueueHttpClientAdapter implements HttpClientAdapter {
  QueueHttpClientAdapter(this._responses);

  final List<ResponseBody Function()> _responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_responses.isEmpty) {
      throw StateError("No queued response left for ${options.uri}");
    }
    return _responses.removeAt(0)();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(
  int statusCode, {
  Map<String, String> headers = const {},
}) {
  return ResponseBody.fromString(
    "{}",
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      for (final entry in headers.entries) entry.key: [entry.value],
    },
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test("injects the stored token as a Bearer Authorization header", () async {
    final adapter = QueueHttpClientAdapter([() => jsonResponse(200)]);
    final dio = buildMetronDio(
      readToken: () => db.settingsDao.getString(SettingsKeys.metronApiToken),
    )..httpClientAdapter = adapter;

    await db.settingsDao.setString(SettingsKeys.metronApiToken, "secret-token");
    await dio.get("issue/");

    expect(
      adapter.requests.single.headers["Authorization"],
      "Bearer secret-token",
    );
  });

  test("omits the Authorization header when no token is stored", () async {
    final adapter = QueueHttpClientAdapter([() => jsonResponse(200)]);
    final dio = buildMetronDio(
      readToken: () => db.settingsDao.getString(SettingsKeys.metronApiToken),
    )..httpClientAdapter = adapter;

    await dio.get("issue/");

    expect(adapter.requests.single.headers["Authorization"], isNull);
  });

  test(
    "always attaches the rate limiter; conditional requests need a store",
    () async {
      final withStore = buildMetronDio(readToken: () async => null, db: db);
      final backgroundStyle = buildMetronDio(readToken: () async => null);

      expect(
        withStore.interceptors.whereType<RateLimitInterceptor>().length,
        1,
      );
      expect(
        withStore.interceptors
            .whereType<ConditionalRequestInterceptor>()
            .length,
        1,
      );

      // Background sync style without DB: rate limited and authenticated, but no ETag
      // revalidation for sync endpoints.
      expect(
        backgroundStyle.interceptors.whereType<RateLimitInterceptor>().length,
        1,
      );
      expect(
        backgroundStyle.interceptors.whereType<ConditionalRequestInterceptor>(),
        isEmpty,
      );
    },
  );

  test("waits out a 429 using rate-limit headers and retries once", () async {
    final reset = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1;
    final adapter = QueueHttpClientAdapter([
      () =>
          jsonResponse(429, headers: {"x-ratelimit-sustained-reset": "$reset"}),
      () => jsonResponse(200),
    ]);
    final dio = buildMetronDio(readToken: () async => null)
      ..httpClientAdapter = adapter;

    final response = await dio.get("issue/");

    expect(response.statusCode, 200);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.last.extra["retried_after_429"], isTrue);
  }, timeout: const Timeout(Duration(seconds: 15)));

  test("waits out a 429 honoring Retry-After header and retries", () async {
    final adapter = QueueHttpClientAdapter([
      () => jsonResponse(429, headers: {"retry-after": "1"}),
      () => jsonResponse(200),
    ]);
    final dio = buildMetronDio(readToken: () async => null)
      ..httpClientAdapter = adapter;

    final response = await dio.get("issue/");

    expect(response.statusCode, 200);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.last.extra["retried_after_429"], isTrue);
    expect(adapter.requests.last.extra["retry_429_count"], 1);
  }, timeout: const Timeout(Duration(seconds: 15)));

  test("retries a transient 500 and succeeds", () async {
    final adapter = QueueHttpClientAdapter([
      () => jsonResponse(500),
      () => jsonResponse(200),
    ]);
    final dio = buildMetronDio(readToken: () async => null)
      ..httpClientAdapter = adapter;

    final response = await dio.get("issue/");

    expect(response.statusCode, 200);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.last.extra["retry_5xx_count"], 1);
  }, timeout: const Timeout(Duration(seconds: 15)));

  test("gives up after three 5xx retries and propagates the error", () async {
    final adapter = QueueHttpClientAdapter([
      () => jsonResponse(500),
      () => jsonResponse(500),
      () => jsonResponse(500),
      () => jsonResponse(500),
    ]);
    final dio = buildMetronDio(readToken: () async => null)
      ..httpClientAdapter = adapter;

    await expectLater(dio.get("issue/"), throwsA(isA<DioException>()));

    // 1 initial attempt + 3 retries (1s + 2s + 4s backoff).
    expect(adapter.requests.length, 4);
    expect(adapter.requests.last.extra["retry_5xx_count"], 3);
  }, timeout: const Timeout(Duration(seconds: 20)));

  test("deletes the stored token and notifies on 401", () async {
    final adapter = QueueHttpClientAdapter([() => jsonResponse(401)]);
    var authFailureNotified = false;
    final dio = buildMetronDio(
      readToken: () => db.settingsDao.getString(SettingsKeys.metronApiToken),
      db: db,
      onAuthFailure: () => authFailureNotified = true,
    )..httpClientAdapter = adapter;

    await db.settingsDao.setString(
      SettingsKeys.metronApiToken,
      "expired-token",
    );

    await expectLater(dio.get("issue/"), throwsA(isA<DioException>()));

    expect(await db.settingsDao.getString(SettingsKeys.metronApiToken), isNull);
    expect(authFailureNotified, isTrue);
  });
}
