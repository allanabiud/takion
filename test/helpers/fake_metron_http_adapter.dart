import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";

/// A scriptable Dio [HttpClientAdapter] that simulates the Metron API for tests.
///
/// Supports:
/// - Scripting paginated list responses with opaque `next` and `previous` URLs.
/// - HTTP 304 Not Modified with conditional ETag validation.
/// - HTTP 401 Unauthorized with token invalidation testing.
/// - HTTP 429 Too Many Requests with `Retry-After` / `X-RateLimit-Reset` headers.
/// - HTTP 5xx transient server error retries.
/// - Connection drops / SocketException simulation.
/// - Request history inspection.
class FakeMetronHttpAdapter implements HttpClientAdapter {
  FakeMetronHttpAdapter();

  final List<RequestOptions> _recordedRequests = [];
  final List<FutureOr<ResponseBody> Function(RequestOptions)> _queue = [];
  final Map<String, FutureOr<ResponseBody> Function(RequestOptions)> _handlers =
      {};

  List<RequestOptions> get recordedRequests =>
      List.unmodifiable(_recordedRequests);

  void reset() {
    _recordedRequests.clear();
    _queue.clear();
    _handlers.clear();
  }

  /// Scripts a sequential response.
  void enqueueResponse(
    FutureOr<ResponseBody> Function(RequestOptions) responder,
  ) {
    _queue.add(responder);
  }

  /// Scripts a JSON response with status code, data, and headers.
  void enqueueJsonResponse(
    int statusCode,
    dynamic data, {
    Map<String, List<String>>? headers,
  }) {
    enqueueResponse(
      (_) => jsonResponseBody(statusCode, data, headers: headers),
    );
  }

  /// Scripts a paginated Metron API response.
  void enqueuePage({
    required List<Map<String, dynamic>> items,
    Uri? next,
    Uri? previous,
    int? count,
    String? etag,
  }) {
    final payload = {
      "count": count ?? items.length,
      "next": next?.toString(),
      "previous": previous?.toString(),
      "results": items,
    };
    final headers = <String, List<String>>{
      Headers.contentTypeHeader: [Headers.jsonContentType],
      if (etag != null) "etag": [etag],
    };
    enqueueResponse((_) => jsonResponseBody(200, payload, headers: headers));
  }

  /// Scripts a 304 Not Modified response.
  void enqueue304({String? etag}) {
    enqueueResponse(
      (_) => ResponseBody.fromString(
        "",
        304,
        headers: {
          if (etag != null) "etag": [etag],
        },
      ),
    );
  }

  /// Scripts a 401 Unauthorized response.
  void enqueue401({String message = "Invalid token"}) {
    enqueueJsonResponse(401, {"detail": message});
  }

  /// Scripts a 429 Too Many Requests with Retry-After and rate-limit headers.
  void enqueue429({int retryAfterSeconds = 1, int? resetTimestamp}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final reset = resetTimestamp ?? (now + retryAfterSeconds);
    enqueueResponse(
      (_) => ResponseBody.fromString(
        jsonEncode({"detail": "Request was throttled."}),
        429,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          "retry-after": ["$retryAfterSeconds"],
          "x-ratelimit-reset": ["$reset"],
          "x-ratelimit-remaining": ["0"],
        },
      ),
    );
  }

  /// Scripts a 5xx Server Error response.
  void enqueue5xx(int statusCode, {String message = "Server Error"}) {
    enqueueJsonResponse(statusCode, {"detail": message});
  }

  /// Scripts a network connection drop (SocketException).
  void enqueueConnectionLoss({String message = "Connection reset by peer"}) {
    enqueueResponse((options) {
      throw DioException(
        requestOptions: options,
        error: SocketException(message),
        type: DioExceptionType.connectionError,
      );
    });
  }

  /// Registers a pattern handler for a path.
  void onPath(
    String pathSubstring,
    FutureOr<ResponseBody> Function(RequestOptions) handler,
  ) {
    _handlers[pathSubstring] = handler;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _recordedRequests.add(options);

    if (_queue.isNotEmpty) {
      final responder = _queue.removeAt(0);
      return await responder(options);
    }

    for (final entry in _handlers.entries) {
      if (options.path.contains(entry.key)) {
        return await entry.value(options);
      }
    }

    // Default fallback: 404
    return jsonResponseBody(404, {
      "detail": "Not found in FakeMetronHttpAdapter",
    });
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody jsonResponseBody(
    int statusCode,
    dynamic data, {
    Map<String, List<String>>? headers,
  }) {
    final jsonString = jsonEncode(data);
    final responseHeaders = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    };
    return ResponseBody.fromString(
      jsonString,
      statusCode,
      headers: responseHeaders,
    );
  }
}
