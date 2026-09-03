class OfflineWriteEntry {
  const OfflineWriteEntry({
    required this.id,
    required this.operation,
    required this.entityType,
    this.entityId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = "pending",
    this.lastError,
  });

  final int id;
  final String operation;
  final String entityType;
  final String? entityId;
  final String payload;
  final int createdAt;
  final int retryCount;
  final String status;
  final String? lastError;
}
