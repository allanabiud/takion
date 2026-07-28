import 'package:dio/dio.dart';
import 'package:takion/src/core/cache/cache_header_store.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class ConditionalRequestInterceptor extends Interceptor {
  ConditionalRequestInterceptor(this._store, this._db);

  final CacheHeaderStore _store;
  final AppDatabase _db;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final url = options.uri.toString();
    final etag = _store.getEtag(url);
    final lastModified = _store.getLastModified(url);
    if (etag != null) {
      options.headers['If-None-Match'] = etag;
      AppLogger.debug('Cache: If-None-Match set for $url');
    }
    if (lastModified != null) {
      options.headers['If-Modified-Since'] = lastModified;
      AppLogger.debug('Cache: If-Modified-Since set for $url');
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final url = response.requestOptions.uri.toString();
    if (response.statusCode == 304) {
      AppLogger.debug('Cache: 304 Not Modified for $url');
    } else if (response.statusCode == 200) {
      AppLogger.debug('Cache: 200 OK, updating cache for $url');
      final etag = response.headers.value('etag');
      final lastModified = response.headers.value('last-modified');
      if (etag != null || lastModified != null) {
        await _store.store(_db, url, etag: etag, lastModified: lastModified);
      }
    }
    handler.next(response);
  }
}
