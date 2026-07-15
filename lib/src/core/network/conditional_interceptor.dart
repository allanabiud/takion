import 'package:dio/dio.dart';
import 'package:takion/src/core/cache/cache_header_store.dart';

class ConditionalRequestInterceptor extends Interceptor {
  ConditionalRequestInterceptor(this._store);

  final CacheHeaderStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final url = options.uri.toString();
    final etag = _store.getEtag(url);
    final lastModified = _store.getLastModified(url);
    if (etag != null) options.headers['If-None-Match'] = etag;
    if (lastModified != null) {
      options.headers['If-Modified-Since'] = lastModified;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      final url = response.requestOptions.uri.toString();
      final etag = response.headers.value('etag');
      final lastModified = response.headers.value('last-modified');
      if (etag != null || lastModified != null) {
        _store.store(url, etag: etag, lastModified: lastModified);
      }
    }
    handler.next(response);
  }
}
