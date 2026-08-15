import "package:dio/dio.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/network/conditional_interceptor.dart";
import "package:takion/src/data/common/drift/database.dart";

class CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions response) {
    captured = response;
  }
}

void main() {
  late AppDatabase db;
  late CacheHeaderStore store;
  late ConditionalRequestInterceptor interceptor;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = CacheHeaderStore();
    interceptor = ConditionalRequestInterceptor(store, db);
  });

  tearDown(() async {
    await db.close();
  });

  RequestOptions requestOptions({Map<String, dynamic> extra = const {}}) {
    return RequestOptions(
      method: "GET",
      path: "https://metron.cloud/api/arc/1/issue_list/?page=1",
      extra: extra,
    );
  }

  test("attaches If-None-Match when an ETag is cached", () async {
    await store.store(db, "https://metron.cloud/api/arc/1/issue_list/?page=1",
        etag: '"abc"');

    final handler = CapturingHandler();
    interceptor.onRequest(requestOptions(), handler);

    expect(handler.captured, isNotNull);
    expect(handler.captured!.headers["If-None-Match"], '"abc"');
  });

  test("skips conditional headers when bypass_conditional is set", () async {
    await store.store(db, "https://metron.cloud/api/arc/1/issue_list/?page=1",
        etag: '"abc"');

    final handler = CapturingHandler();
    interceptor.onRequest(
      requestOptions(extra: {"bypass_conditional": true}),
      handler,
    );

    expect(handler.captured, isNotNull);
    expect(handler.captured!.headers["If-None-Match"], isNull);
    expect(handler.captured!.headers["If-Modified-Since"], isNull);
  });
}
