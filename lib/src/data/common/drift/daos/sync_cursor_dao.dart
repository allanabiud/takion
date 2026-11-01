import "package:drift/drift.dart";
import "package:takion/src/core/sync/sync_cursor.dart";
import "package:takion/src/data/common/drift/database.dart";

class SyncCursorDao extends DatabaseAccessor<AppDatabase> {
  SyncCursorDao(super.db);

  Future<SyncCursor?> get(String accountId, String resource) =>
      (select(attachedDatabase.syncCursors)..where(
            (t) => t.accountId.equals(accountId) & t.resource.equals(resource),
          ))
          .getSingleOrNull();

  Future<SyncCursorState> loadCursor(String accountId, String resource) async {
    final row = await get(accountId, resource);
    if (row == null) return SyncCursorState.initial();
    return SyncCursorState.fromJsonString(row.cursorJson);
  }

  Future<void> saveCursor({
    required String accountId,
    required String resource,
    required SyncCursorState cursor,
    required bool isComplete,
    DateTime? updatedAt,
  }) => upsert(
    accountId: accountId,
    resource: resource,
    cursorJson: cursor.toJsonString(),
    isComplete: isComplete,
    updatedAt: updatedAt,
  );

  Future<void> upsert({
    required String accountId,
    required String resource,
    required String cursorJson,
    required bool isComplete,
    DateTime? updatedAt,
  }) => into(attachedDatabase.syncCursors).insertOnConflictUpdate(
    SyncCursorsCompanion.insert(
      accountId: accountId,
      resource: resource,
      cursorJson: cursorJson,
      isComplete: Value(isComplete),
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    ),
  );
}
