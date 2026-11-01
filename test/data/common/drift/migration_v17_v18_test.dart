import "dart:io";

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Fixture test for the v17 → v18 schema upgrade: a database stamped at
/// schema version 17 (current schema plus the legacy `api_cache`,
/// `image_cache`, and `superhero_character_cache` tables) must lose those
/// cache tables while user data survives untouched.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("takion_migration_v17");
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
    return rows.map((r) => r.data["name"] as String).toSet();
  }

  Future<int> userVersion(AppDatabase db) async {
    final row = await db.customSelect("PRAGMA user_version").getSingle();
    return row.read<int>("user_version");
  }

  test(
    "v17 to v18 drops the legacy cache tables and keeps user data",
    () async {
      // ---- Seed a fixture at schema version 17 ----
      final seed = AppDatabase.forTesting(NativeDatabase(dbFile));

      // The v17 schema is the schema before v18/v19: today's schema without
      // the v19 additions (`issue_name`, `slug`, `paged_query_*`) plus the
      // three cache tables that the v18 migration drops.
      await seed.customStatement(
        "CREATE TABLE api_cache (cache_key TEXT PRIMARY KEY, "
        "payload TEXT NOT NULL, cached_at INTEGER NOT NULL)",
      );
      await seed.customStatement(
        "INSERT INTO api_cache (cache_key, payload, cached_at) "
        "VALUES ('fixture_key', '{}', 0)",
      );
      await seed.customStatement(
        "CREATE TABLE image_cache (url TEXT PRIMARY KEY, "
        "file_path TEXT NOT NULL, created_at INTEGER NOT NULL)",
      );
      await seed.customStatement(
        "INSERT INTO image_cache (url, file_path, created_at) "
        "VALUES ('https://example.org/cover.jpg', '/tmp/cover.jpg', 0)",
      );
      await seed.customStatement(
        "CREATE TABLE superhero_character_cache (id INTEGER PRIMARY KEY, "
        "name TEXT NOT NULL, payload TEXT NOT NULL)",
      );
      await seed.customStatement(
        "INSERT INTO superhero_character_cache (id, name, payload) "
        "VALUES (7, 'Spawn', '{}')",
      );

      // Roll back everything the v19/v20 migrations add so the fixture carries
      // the genuine pre-v18 shape for every step of the 17 → 20 upgrade.
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
        "ALTER TABLE metron_issues DROP COLUMN issue_name",
      );
      await seed.customStatement(
        "ALTER TABLE metron_characters DROP COLUMN slug",
      );
      await seed.customStatement("DROP TABLE paged_query_caches");
      await seed.customStatement("DROP TABLE paged_query_items");

      // User data that must survive the migration.
      await seed.customStatement(
        "INSERT INTO library_items (id, user_id, metron_issue_id, "
        "metron_series_id, ownership_status, is_read, format, created_at, "
        "updated_at) VALUES ('lib-42', 'local-user', 42, 10, 'owned', 1, "
        "'PRINT', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z')",
      );
      await seed.settingsDao.setString("migration_fixture_marker", "v17");

      // The fixture must genuinely carry the legacy tables pre-migration, so a
      // green result can't come from tables that never existed.
      final tablesBefore = await tableNames(seed);
      expect(tablesBefore, contains("api_cache"));
      expect(tablesBefore, contains("image_cache"));
      expect(tablesBefore, contains("superhero_character_cache"));

      // Stamp the fixture as v17 so reopening runs onUpgrade(from: 17).
      await seed.customStatement("PRAGMA user_version = 17");
      expect(await userVersion(seed), 17);
      await seed.close();

      // ---- Reopen: drift runs the 17 → 20 migration on first use ----
      final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 20);
      await migrated.customSelect("SELECT 1").getSingle(); // force open

      expect(await userVersion(migrated), 20);

      final tablesAfter = await tableNames(migrated);
      expect(tablesAfter, isNot(contains("api_cache")));
      expect(tablesAfter, isNot(contains("image_cache")));
      expect(tablesAfter, isNot(contains("superhero_character_cache")));

      // Non-cache user data is preserved by the drop-table migration.
      expect(
        await migrated.settingsDao.getString("migration_fixture_marker"),
        "v17",
      );
      final survivor = await migrated.libraryItemDao.getByIssueId(42);
      expect(survivor, isNotNull);
      expect(survivor!.metronSeriesId, 10);
      expect(survivor.syncStatus, "synced");

      // The migrated database still functions for regular writes/reads.
      await migrated.syncMetaDao.set("post_migration_key", "ok");
      expect(await migrated.syncMetaDao.get("post_migration_key"), "ok");

      await migrated.close();
    },
  );
}
