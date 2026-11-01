import "dart:async";

import "package:dio/dio.dart";

const backgroundZoneKey = #opencode_background;
const priorityZoneKey = #opencode_request_priority;
const requestPriorityExtraKey = "request_priority";

/// [RequestOptions.extra] key marking a request as part of a sequential
/// pagination/snapshot scan. The scheduler allows at most one such scan to
/// run concurrently so background sync cannot saturate the connection pool.
const paginationScanExtraKey = "isPaginationScan";

/// Marks [options] as a pagination/snapshot scan request.
void markPaginationScan(RequestOptions options) {
  options.extra = Map<String, dynamic>.from(options.extra)
    ..[paginationScanExtraKey] = true;
}

/// Whether [options] was marked as a pagination/snapshot scan request.
bool isPaginationScan(RequestOptions options) =>
    options.extra[paginationScanExtraKey] == true;

enum RequestPriority {
  high(0),
  normal(1),
  background(2),
  drop(3);

  const RequestPriority(this.level);

  final int level;

  bool get isForeground => level <= normal.level;

  bool get isBackground => level >= background.level;
}

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
