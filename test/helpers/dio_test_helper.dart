import "package:dio/dio.dart";

/// Generates mock HTTP response headers for Metron API rate limits.
Map<String, List<String>> createRateLimitHeadersMap({
  int sustainedLimit = 5000,
  int sustainedRemaining = 4999,
  int sustainedReset = 1750000000,
  int burstRemaining = 19,
  int burstReset = 60,
  bool lowercase = true,
}) {
  if (lowercase) {
    return {
      "x-ratelimit-sustained-limit": ["$sustainedLimit"],
      "x-ratelimit-sustained-remaining": ["$sustainedRemaining"],
      "x-ratelimit-sustained-reset": ["$sustainedReset"],
      "x-ratelimit-burst-remaining": ["$burstRemaining"],
      "x-ratelimit-burst-reset": ["$burstReset"],
    };
  } else {
    return {
      "X-RateLimit-Sustained-Limit": ["$sustainedLimit"],
      "X-RateLimit-Sustained-Remaining": ["$sustainedRemaining"],
      "X-RateLimit-Sustained-Reset": ["$sustainedReset"],
      "X-RateLimit-Burst-Remaining": ["$burstRemaining"],
      "X-RateLimit-Burst-Reset": ["$burstReset"],
    };
  }
}

/// Generates [Headers] wrapper for Metron API rate limits.
Headers createRateLimitHeaders({
  int sustainedLimit = 5000,
  int sustainedRemaining = 4999,
  int sustainedReset = 1750000000,
  int burstRemaining = 19,
  int burstReset = 60,
  bool lowercase = true,
}) {
  return Headers.fromMap(
    createRateLimitHeadersMap(
      sustainedLimit: sustainedLimit,
      sustainedRemaining: sustainedRemaining,
      sustainedReset: sustainedReset,
      burstRemaining: burstRemaining,
      burstReset: burstReset,
      lowercase: lowercase,
    ),
  );
}
