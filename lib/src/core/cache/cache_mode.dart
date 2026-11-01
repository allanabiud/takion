import "package:dio/dio.dart";

/// Dictates how cached remote data is checked, validated, and updated.
enum CacheMode {
  /// Reads strictly from the local cache without contacting the network.
  /// Throws or rejects if no cached representation exists.
  offlineOnly,

  /// Returns cached representation if present without checking network freshness.
  /// Fetches from the network only on cache miss.
  cacheFirst,

  /// Returns cached representation immediately if fresh; if stale or absent,
  /// fetches from network with conditional headers (304 restoration).
  staleWhileRevalidate,

  /// Forces validation with the remote server using conditional headers
  /// (`If-None-Match` / `If-Modified-Since`) if cached. Restores cached body on 304.
  validate,

  /// Completely bypasses local cache and conditional headers, fetching fresh
  /// data from the network and refreshing the cache on success.
  networkOnly,
}

/// Request options specifying cache behavior for Dio HTTP requests.
class CacheRequestOptions {
  const CacheRequestOptions({
    this.mode = CacheMode.staleWhileRevalidate,
    this.cacheKey,
    this.ttl,
    this.isPinned = false,
    this.accountId = "local-user",
  });

  final CacheMode mode;
  final String? cacheKey;
  final Duration? ttl;
  final bool isPinned;
  final String accountId;

  static const String extraKey = "cache_request_options";

  Map<String, dynamic> toExtra() => {extraKey: this};

  static CacheRequestOptions? fromExtra(Map<String, dynamic>? extra) {
    if (extra == null) return null;
    final val = extra[extraKey];
    if (val is CacheRequestOptions) return val;
    return null;
  }

  Options toOptions({Options? baseOptions}) {
    final opts = baseOptions ?? Options();
    opts.extra = {...?opts.extra, ...toExtra()};
    return opts;
  }
}
