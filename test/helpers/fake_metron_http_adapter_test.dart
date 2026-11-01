import "dart:io";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";

import "fake_metron_http_adapter.dart";

void main() {
  group("FakeMetronHttpAdapter", () {
    late Dio dio;
    late FakeMetronHttpAdapter fakeAdapter;

    setUp(() {
      fakeAdapter = FakeMetronHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: "https://metron.cloud/api/"))
        ..httpClientAdapter = fakeAdapter;
    });

    test(
      "scripts paginated responses with next and previous opaque links",
      () async {
        fakeAdapter.enqueuePage(
          items: [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"},
          ],
          next: Uri.parse("https://metron.cloud/api/items/?page=2&opaque=abc"),
          count: 10,
          etag: '"test-etag-1"',
        );

        final response = await dio.get("items/");

        expect(response.statusCode, 200);
        expect(response.headers.value("etag"), '"test-etag-1"');
        final data = response.data as Map<String, dynamic>;
        expect(data["count"], 10);
        expect(
          data["next"],
          "https://metron.cloud/api/items/?page=2&opaque=abc",
        );
        expect((data["results"] as List).length, 2);
        expect(fakeAdapter.recordedRequests.length, 1);
        expect(fakeAdapter.recordedRequests.single.path, "items/");
      },
    );

    test("scripts 304 Not Modified with ETag", () async {
      fakeAdapter.enqueue304(etag: '"cached-etag"');

      // Setup validateStatus to allow 304
      dio.options.validateStatus = (status) => status == 200 || status == 304;
      final response = await dio.get("items/");

      expect(response.statusCode, 304);
      expect(response.headers.value("etag"), '"cached-etag"');
    });

    test("scripts 401 Unauthorized with token invalidation detail", () async {
      fakeAdapter.enqueue401(message: "Invalid token header");

      try {
        await dio.get("protected/");
        fail("Should throw DioException");
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
        expect(e.response?.data["detail"], "Invalid token header");
      }
    });

    test(
      "scripts 429 Too Many Requests with Retry-After and rate limit headers",
      () async {
        fakeAdapter.enqueue429(
          retryAfterSeconds: 3,
          resetTimestamp: 1700000003,
        );

        try {
          await dio.get("throttled/");
          fail("Should throw DioException");
        } on DioException catch (e) {
          expect(e.response?.statusCode, 429);
          expect(e.response?.headers.value("retry-after"), "3");
          expect(e.response?.headers.value("x-ratelimit-reset"), "1700000003");
          expect(e.response?.headers.value("x-ratelimit-remaining"), "0");
        }
      },
    );

    test("scripts 5xx transient server error", () async {
      fakeAdapter.enqueue5xx(503, message: "Metron Cloud Maintenance");

      try {
        await dio.get("service/");
        fail("Should throw DioException");
      } on DioException catch (e) {
        expect(e.response?.statusCode, 503);
        expect(e.response?.data["detail"], "Metron Cloud Maintenance");
      }
    });

    test("scripts connection loss with SocketException", () async {
      fakeAdapter.enqueueConnectionLoss(message: "Network unreachable");

      try {
        await dio.get("offline/");
        fail("Should throw DioException");
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.connectionError);
        expect(e.error, isA<SocketException>());
        expect((e.error as SocketException).message, "Network unreachable");
      }
    });
  });
}
