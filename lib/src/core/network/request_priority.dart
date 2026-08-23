import "dart:async";

import "package:dio/dio.dart";

const backgroundZoneKey = #opencode_background;
const priorityZoneKey = #opencode_request_priority;
const requestPriorityExtraKey = "request_priority";

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
