import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class SyncConflictDao extends DatabaseAccessor<AppDatabase> {
  SyncConflictDao(super.db);

  Future<void> upsert(SyncConflictsCompanion conflict) =>
      into(attachedDatabase.syncConflicts).insertOnConflictUpdate(conflict);

  Future<List<SyncConflict>> getOpen(String accountId) =>
      (select(attachedDatabase.syncConflicts)
            ..where(
              (t) => t.accountId.equals(accountId) & t.state.equals("open"),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> resolve(String id, String resolution) =>
      (update(
        attachedDatabase.syncConflicts,
      )..where((t) => t.id.equals(id))).write(
        SyncConflictsCompanion(
          state: const Value("resolved"),
          resolution: Value(resolution),
          resolvedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
