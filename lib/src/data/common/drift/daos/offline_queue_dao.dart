import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class OfflineQueueDao extends DatabaseAccessor<AppDatabase> {
  OfflineQueueDao(super.db);

  Future<int> enqueue({
    required String operation,
    required String entityType,
    String? entityId,
    required String payload,
  }) async {
    final existing = await (select(attachedDatabase.offlineWriteQueue)
          ..where((t) =>
              t.operation.equals(operation) &
              t.entityType.equals(entityType) &
              t.entityId.equals(entityId ?? "") &
              t.status.equals("pending")))
        .getSingleOrNull();

    if (existing != null) {
      await (update(attachedDatabase.offlineWriteQueue)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        OfflineWriteQueueCompanion(
          payload: Value(payload),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          retryCount: const Value(0),
          lastError: const Value(null),
          lastAttemptAt: const Value(null),
        ),
      );
      return existing.id;
    }

    return into(attachedDatabase.offlineWriteQueue).insert(
      OfflineWriteQueueCompanion.insert(
        operation: operation,
        entityType: entityType,
        entityId: Value(entityId),
        payload: payload,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<OfflineWriteQueueData>> getPendingEntries({int limit = 50}) async {
    return (select(attachedDatabase.offlineWriteQueue)
          ..where((t) => t.status.equals("pending"))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Stream<int> watchPendingCount() {
    final countExp = attachedDatabase.offlineWriteQueue.id.count();
    final query = selectOnly(attachedDatabase.offlineWriteQueue)
      ..addColumns([countExp])
      ..where(attachedDatabase.offlineWriteQueue.status.equals("pending"));
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  Stream<int> watchFailedCount() {
    final countExp = attachedDatabase.offlineWriteQueue.id.count();
    final query = selectOnly(attachedDatabase.offlineWriteQueue)
      ..addColumns([countExp])
      ..where(attachedDatabase.offlineWriteQueue.status.equals("failed"));
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  Future<void> markCompleted(int id) async {
    await (delete(attachedDatabase.offlineWriteQueue)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markFailed(int id, {required String error, required int retryCount}) async {
    await (update(attachedDatabase.offlineWriteQueue)..where((t) => t.id.equals(id))).write(
      OfflineWriteQueueCompanion(
        retryCount: Value(retryCount),
        lastError: Value(error),
        status: Value(retryCount >= 5 ? "failed" : "pending"),
        lastAttemptAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> clearCompleted() async {
    await (delete(attachedDatabase.offlineWriteQueue)..where((t) => t.status.equals("completed"))).go();
  }

  Future<void> clearAll() async {
    await delete(attachedDatabase.offlineWriteQueue).go();
  }

  Future<List<OfflineWriteQueueData>> getFailedEntries() async {
    return (select(attachedDatabase.offlineWriteQueue)
          ..where((t) => t.status.equals("failed"))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> deleteEntry(int id) async {
    await (delete(attachedDatabase.offlineWriteQueue)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> clearFailedEntries() async {
    await (delete(attachedDatabase.offlineWriteQueue)
          ..where((t) => t.status.equals("failed")))
        .go();
  }

  Future<void> resetFailedEntries() async {
    await (update(attachedDatabase.offlineWriteQueue)
          ..where((t) => t.status.equals("failed")))
        .write(
      const OfflineWriteQueueCompanion(
        status: Value("pending"),
        retryCount: Value(0),
        lastError: Value(null),
      ),
    );
  }
}
