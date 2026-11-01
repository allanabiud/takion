abstract final class OutboxEntityType {
  static const String collection = "collection";
  static const String subscription = "subscription";
  static const String pullSeries = "subscription";
  static const String wishlist = "wishlist";
  static const String scrobble = "scrobble";
}

abstract final class OutboxOperationType {
  static const String create = "create";
  static const String patch = "patch";
  static const String delete = "delete";
  static const String scrobble = "scrobble";
  static const String acquire = "acquire";
}

abstract final class OutboxState {
  static const String pending = "pending";
  static const String running = "running";
  static const String retry = "retry";
  static const String blocked = "blocked";
  static const String conflict = "conflict";
  static const String done = "done";
}

abstract final class ProjectionSyncState {
  static const String synced = "synced";
  static const String pending = "pending";
  static const String failed = "failed";
  static const String conflict = "conflict";
}
