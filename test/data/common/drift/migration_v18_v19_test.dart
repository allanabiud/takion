import "dart:io";

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Fixture test for the v18 → v19 schema upgrade: a database stamped at
/// schema version 18 (current schema without `metron_issues.issue_name`,
/// `metron_characters.slug`, or the `paged_query_*` tables) must gain the
/// normalized paged-cache schema, drop the legacy `paged_cache*`
/// key-value rows, and keep ordinary settings, details-cache entries, and
/// user data untouched.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("takion_migration_v18");
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

  Future<Set<String>> columnNames(AppDatabase db, String table) async {
    final rows = await db.customSelect("PRAGMA table_info($table)").get();
    return rows.map((r) => r.data["name"] as String).toSet();
  }

  Future<Set<String>> settingKeys(AppDatabase db) async {
    final rows = await db.customSelect("SELECT key FROM app_settings").get();
    return rows.map((r) => r.data["key"] as String).toSet();
  }

  Future<int> userVersion(AppDatabase db) async {
    final row = await db.customSelect("PRAGMA user_version").getSingle();
    return row.read<int>("user_version");
  }

  test("v18 to v19 normalizes the paged cache and keeps user data", () async {
    // ---- Seed a fixture at schema version 18 ----
    final seed = AppDatabase.forTesting(NativeDatabase(dbFile));

    // Downgrade the freshly created schema to its v18 shape: neither new
    // column nor either new table exists yet.
    await seed.customStatement(
      "ALTER TABLE metron_issues DROP COLUMN issue_name",
    );
    await seed.customStatement("ALTER TABLE metron_characters DROP COLUMN slug");
    await seed.customStatement("DROP TABLE paged_query_caches");
    await seed.customStatement("DROP TABLE paged_query_items");

    // Legacy JSON page payloads in the settings key-value store next to an
    // ordinary setting and a details-cache entry that must survive.
    await seed.customStatement(
      "INSERT INTO app_settings (key, value) VALUES "
      "('paged_cache:issue_list:issue_list:p1', '[{\"id\":42}]'), "
      "('paged_cache_meta:issue_list:issue_list:p1', '{\"count\":1}'), "
      "('paged_cache_at:issue_list:issue_list:p1', "
      "'2026-09-01T00:00:00.000Z'), "
      "('details_cache:issue:42', '{\"id\":42}'), "
      "('details_cache_at:issue:42', '2026-09-01T00:00:00.000Z'), "
      "('app_theme', 'dark')",
    );
    await seed.customStatement(
      "INSERT INTO metron_issues (id, number, description, is_fully_hydrated) "
      "VALUES (42, '1', 'Hydrated description', 1)",
    );
    await seed.customStatement("PRAGMA user_version = 18");

    // ---- Pre-migration assertions: the fixture really is a v18 database ----
    expect(await userVersion(seed), 18);
    final v18Tables = await tableNames(seed);
    expect(v18Tables, isNot(contains("paged_query_caches")));
    expect(v18Tables, isNot(contains("paged_query_items")));
    expect(
      await columnNames(seed, "metron_issues"),
      isNot(contains("issue_name")),
    );
    expect(
      await columnNames(seed, "metron_characters"),
      isNot(contains("slug")),
    );
    expect(
      await settingKeys(seed),
      contains("paged_cache:issue_list:issue_list:p1"),
    );
    await seed.close();

    // ---- Reopen: onUpgrade(18 → 19) runs ----
    final migrated = AppDatabase.forTesting(NativeDatabase(dbFile));

    expect(await userVersion(migrated), 19);

    // New normalized paged-cache schema exists.
    final tables = await tableNames(migrated);
    expect(tables, contains("paged_query_caches"));
    expect(tables, contains("paged_query_items"));
    expect(await columnNames(migrated, "metron_issues"), contains("issue_name"));
    expect(
      await columnNames(migrated, "metron_characters"),
      contains("slug"),
    );

    // Legacy paged-cache key-value rows are gone; everything else survives.
    final keys = await settingKeys(migrated);
    expect(keys.where((key) => key.startsWith("paged_cache")), isEmpty);
    expect(keys, contains("details_cache:issue:42"));
    expect(keys, contains("details_cache_at:issue:42"));
    expect(keys, contains("app_theme"));

    final issueRow = await migrated
        .customSelect(
          "SELECT number, description, is_fully_hydrated "
          "FROM metron_issues WHERE id = 42",
        )
        .getSingle();
    expect(issueRow.data["number"], "1");
    expect(issueRow.data["description"], "Hydrated description");
    expect(issueRow.data["is_fully_hydrated"], 1);

    await migrated.close();
  });
}
