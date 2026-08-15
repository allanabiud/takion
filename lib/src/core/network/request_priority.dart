import "dart:async";

import "package:dio/dio.dart";

/// Marks work running in a background zone so the request scheduler can treat
/// it as lower priority than user-facing (foreground) requests.
const backgroundZoneKey = #opencode_background;

/// Zone value carrying an explicit [RequestPriority] override (P0/P3 needs).
const priorityZoneKey = #opencode_request_priority;

/// `options.extra` key for an explicit [RequestPriority] override.
const requestPriorityExtraKey = "request_priority";

/// Priority classes for outgoing Metron API requests.
///
/// Default is [RequestPriority.normal]. Lower [RequestPriority.level] values
/// are dispatched first.
enum RequestPriority {
  /// Direct user action, must not wait (barcode scan, search-as-you-type,
  /// explicit pull-to-refresh, opening a detail screen).
  high(0),

  /// User-visible content on screen (paged list fetches, open series).
  normal(1),

  /// Not currently visible; nice-to-have freshness (stale refreshes,
  /// subscription hydration, category stats backfill).
  background(2),

  /// Fully optional; dropped when the budget is tight (delta sync pre-fetch,
  /// "continue reading" scans, neighbors pre-fetch).
  drop(3);

  const RequestPriority(this.level);

  final int level;

  bool get isForeground => level <= normal.level;

  bool get isBackground => level >= background.level;
}

/// Resolves the effective priority for a request: an explicit zone override
/// wins, then the background zone hook, then `options.extra`, then the default.
RequestPriority resolveRequestPriority(RequestOptions options) {
  final zonePriority = Zone.current[priorityZoneKey];
  if (zonePriority is RequestPriority) return zonePriority;
  if (Zone.current[backgroundZoneKey] == true) {
    return RequestPriority.background;
  }
  final extra = options.extra[requestPriorityExtraKey];
  if (extra is RequestPriority) return extra;
  return RequestPriority.normal;
}
