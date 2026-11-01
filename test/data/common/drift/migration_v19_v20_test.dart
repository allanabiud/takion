import "dart:io";

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("takion_migration_v19");
    dbFile = File("${tempDir.path}/takion.db");
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<Set<String>> tableNames(AppDatabase db) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return rows.map((row) => row.data["name"] as String).toSet();
  }

  Future<Set<String>> columnNames(AppDatabase db, String table) async {
    final rows = await db.customSelect("PRAGMA table_info($table)").get();
    return rows.map((row) => row.data["name"] as String).toSet();
  }

  test(
    "v19 to v20 adds durable sync tables without losing legacy state",
    () async {
      final seed = AppDatabase.forTesting(NativeDatabase(dbFile));

      // Convert a freshly-created v20 fixture into v19 shape before reopening.
      for (final table in const [
        "outbox_operations",
        "sync_cursors",
        "sync_jobs",
        "sync_leases",
        "remote_cache_entries",
        "sync_conflicts",
      ]) {
        await seed.customStatement("DROP TABLE $table");
      }
      for (final column in const [
        "remote_modified",
        "last_seen_scan_id",
        "deleted_at",
      ]) {
        await seed.customStatement(
          "ALTER TABLE library_items DROP COLUMN $column",
        );
        await seed.customStatement(
          "ALTER TABLE series_subscriptions DROP COLUMN $column",
        );
      }
      await seed.customStatement(
        "ALTER TABLE wishlist_items DROP COLUMN local_id",
      );
      await seed.customStatement(
        "ALTER TABLE wishlist_items DROP COLUMN remote_modified",
      );
      await seed.customStatement(
        "ALTER TABLE wishlist_items DROP COLUMN last_seen_scan_id",
      );
      await seed.customStatement(
        "ALTER TABLE wishlist_items DROP COLUMN deleted_at",
      );

      await seed.customStatement(
        "INSERT INTO sync_meta (key, value) VALUES "
        "('metron_last_collection_sync', '2026-10-01T00:00:00.000Z')",
      );
      await seed.customStatement(
        "INSERT INTO offline_write_queue "
        "(operation, entity_type, entity_id, payload, created_at, status) VALUES "
        "('create', 'collection', '42', '{}', 1, 'pending')",
      );
      await seed.customStatement("PRAGMA user_version = 19");
      await seed.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
      final tables = await tableNames(migrated);

      expect(
        tables,
        containsAll(const [
          "outbox_operations",
          "sync_cursors",
          "sync_jobs",
          "sync_leases",
          "remote_cache_entries",
          "sync_conflicts",
        ]),
      );
      expect(
        await columnNames(migrated, "library_items"),
        containsAll(const [
          "remote_modified",
          "last_seen_scan_id",
          "deleted_at",
        ]),
      );
      expect(
        await columnNames(migrated, "series_subscriptions"),
        containsAll(const [
          "remote_modified",
          "last_seen_scan_id",
          "deleted_at",
        ]),
      );
      expect(
        await columnNames(migrated, "wishlist_items"),
        containsAll(const [
          "local_id",
          "remote_modified",
          "last_seen_scan_id",
          "deleted_at",
        ]),
      );

      // Old state is deliberately retained until command/outbox cutover.
      expect(
        await migrated.syncMetaDao.get("metron_last_collection_sync"),
        "2026-10-01T00:00:00.000Z",
      );
      expect(
        (await migrated.offlineQueueDao.getPendingEntries()).single.entityId,
        "42",
      );

      // Verify backfilled outbox operation
      final outboxItem = await migrated.outboxDao.getById("legacy_owq_1");
      expect(outboxItem, isNotNull);
      expect(outboxItem!.id, "legacy_owq_1");
      expect(outboxItem.entityType, "collection");
      expect(outboxItem.entityLocalId, "42");
      expect(outboxItem.entityRemoteId, 42);
      expect(outboxItem.operation, "create");
      expect(outboxItem.state, "pending");

      // Verify backfilled cursor
      final cursor = await migrated.syncCursorDao.get("default", "collection");
      expect(cursor, isNotNull);
      expect(cursor!.isComplete, isTrue);
      expect(cursor.cursorJson, contains("2026-10-01T00:00:00.000Z"));

      await migrated.close();
    },
  );
}
