import "dart:convert";
import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/data/common/drift/database.dart";

class CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions response) {
    captured = response;
  }
}

class CapturingResponseHandler extends ResponseInterceptorHandler {
  Response? captured;

  @override
  void next(Response response) {
    captured = response;
  }
}

void main() {
  late AppDatabase db;
  late ConditionalRequestInterceptor interceptor;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    interceptor = ConditionalRequestInterceptor(db);
  });

  tearDown(() async {
    await db.close();
  });

  const url = "https://metron.cloud/api/arc/1/issue_list/?page=1";
  final canonicalKey = ConditionalRequestInterceptor.canonicalCacheKey(
    Uri.parse(url),
  );

  RequestOptions requestOptions({Map<String, dynamic> extra = const {}}) {
    return RequestOptions(method: "GET", path: url, extra: extra);
  }

  test(
    "attaches If-None-Match when an ETag AND cached body are present",
    () async {
      await db.remoteCacheDao.upsertEntry(
        accountId: "local-user",
        cacheKey: canonicalKey,
        etag: '"abc"',
        payloadJson: jsonEncode({"results": []}),
        fetchedAt: DateTime.now().toUtc(),
        staleAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );

      final handler = CapturingRequestHandler();
      await interceptor.onRequest(requestOptions(), handler);

      expect(handler.captured, isNotNull);
      expect(handler.captured!.headers["If-None-Match"], '"abc"');
    },
  );

  test(
    "does NOT attach conditional headers if cached body is absent (prevents empty 304)",
    () async {
      await db.remoteCacheDao.upsertEntry(
        accountId: "local-user",
        cacheKey: canonicalKey,
        etag: '"abc"',
        payloadJson: null, // No body!
        fetchedAt: DateTime.now().toUtc(),
        staleAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );

      final handler = CapturingRequestHandler();
      await interceptor.onRequest(requestOptions(), handler);

      expect(handler.captured, isNotNull);
      expect(handler.captured!.headers["If-None-Match"], isNull);
    },
  );

  test("skips conditional headers when bypass_conditional is set", () async {
    await db.remoteCacheDao.upsertEntry(
      accountId: "local-user",
      cacheKey: canonicalKey,
      etag: '"abc"',
      payloadJson: jsonEncode({"results": []}),
      fetchedAt: DateTime.now().toUtc(),
      staleAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );

    final handler = CapturingRequestHandler();
    await interceptor.onRequest(
      requestOptions(extra: {"bypass_conditional": true}),
      handler,
    );

    expect(handler.captured, isNotNull);
    expect(handler.captured!.headers["If-None-Match"], isNull);
    expect(handler.captured!.headers["If-Modified-Since"], isNull);
  });

  test("restores cached body on 304 Not Modified response", () async {
    final cachedData = {"id": 1, "title": "Secret Wars"};
    await db.remoteCacheDao.upsertEntry(
      accountId: "local-user",
      cacheKey: canonicalKey,
      etag: '"abc"',
      payloadJson: jsonEncode(cachedData),
      fetchedAt: DateTime.now().toUtc(),
      staleAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );

    final req = requestOptions();
    final reqHandler = CapturingRequestHandler();
    await interceptor.onRequest(req, reqHandler);

    final response = Response<dynamic>(
      requestOptions: reqHandler.captured!,
      statusCode: 304,
      data: null, // server sends null/empty on 304
    );

    final respHandler = CapturingResponseHandler();
    await interceptor.onResponse(response, respHandler);

    expect(respHandler.captured, isNotNull);
    expect(respHandler.captured!.data, isNotNull);
    expect(respHandler.captured!.data["title"], "Secret Wars");
    expect(respHandler.captured!.headers.value("x-from-cache"), "304-restored");
  });
}
