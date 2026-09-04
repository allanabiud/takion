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
      ),
    );
  }

  Future<void> clearCompleted() async {
    await (delete(attachedDatabase.offlineWriteQueue)..where((t) => t.status.equals("completed"))).go();
  }

  Future<void> clearAll() async {
    await delete(attachedDatabase.offlineWriteQueue).go();
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
