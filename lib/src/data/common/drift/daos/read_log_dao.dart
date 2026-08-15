import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class ReadLogDao extends DatabaseAccessor<AppDatabase> {
  ReadLogDao(super.db);

  Stream<List<LibraryReadLog>> watchByIssueId(int metronIssueId) {
    final itemId = "lib-$metronIssueId";
    return (select(
      attachedDatabase.libraryReadLogs,
    )..where((t) => t.collectionItemId.equals(itemId))).watch();
  }

  Future<void> insert(LibraryReadLogsCompanion entry) async {
    await into(attachedDatabase.libraryReadLogs).insert(entry);
  }

  Future<void> batchInsert(List<LibraryReadLogsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAll(attachedDatabase.libraryReadLogs, entries);
    });
  }

  Future<void> batchDeleteByItemIds(List<String> collectionItemIds) async {
    if (collectionItemIds.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    final logs = await (select(
      attachedDatabase.libraryReadLogs,
    )..where((t) => t.collectionItemId.isIn(collectionItemIds))).get();

    await batch((b) {
      for (final itemId in collectionItemIds) {
        b.deleteWhere(
          attachedDatabase.libraryReadLogs,
          (t) => t.collectionItemId.equals(itemId),
        );
      }
      for (final log in logs) {
        b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
          SyncMetaCompanion.insert(
            key: "delete:library_read_logs:${log.id}",
            value: now,
          ),
        ]);
      }
    });
  }

  Future<void> deleteById(String id) async {
    await transaction(() async {
      await (delete(
        attachedDatabase.libraryReadLogs,
      )..where((t) => t.id.equals(id))).go();
      await attachedDatabase.syncMetaDao.set(
        "delete:library_read_logs:$id",
        DateTime.now().toUtc().toIso8601String(),
      );
    });
  }
}
