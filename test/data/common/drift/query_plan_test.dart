import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<String>> explainQuery(String sql, [List<dynamic> args = const []]) async {
    final result = await db.customSelect("EXPLAIN QUERY PLAN $sql", variables: [
      for (final arg in args)
        if (arg is int)
          Variable.withInt(arg)
        else if (arg is String)
          Variable.withString(arg)
        else if (arg is bool)
          Variable.withBool(arg)
    ]).get();

    return result.map((row) => row.read<String>("detail")).toList();
  }

  group("Drift EXPLAIN QUERY PLAN Index Verification", () {
    test("library items queries use indexes for status and read state", () async {
      final plan = await explainQuery(
        "SELECT * FROM library_items WHERE ownership_status = ? AND is_read = ?",
        ["owned", false],
      );

      expect(
        plan.any((p) => p.contains("idx_lib_status_read") || p.contains("USING INDEX")),
        isTrue,
        reason: "Expected index usage on library items query: $plan",
      );
    });

    test("pull list queries use release date and status indexes", () async {
      final plan = await explainQuery(
        "SELECT * FROM pull_list_entries WHERE release_date >= ? AND entry_status = ?",
        ["2026-08-01", "pending"],
      );

      expect(
        plan.any((p) => p.contains("idx_pull_release") || p.contains("USING INDEX")),
        isTrue,
        reason: "Expected index usage on pull list query: $plan",
      );
    });

    test("activity events queries use timestamp index", () async {
      final plan = await explainQuery(
        "SELECT * FROM activity_events WHERE timestamp >= ? ORDER BY timestamp DESC",
        ["2026-08-01"],
      );

      expect(
        plan.any((p) => p.contains("idx_activity") || p.contains("USING INDEX")),
        isTrue,
        reason: "Expected index usage on activity events query: $plan",
      );
    });

    test("series subscriptions query uses series index", () async {
      final plan = await explainQuery(
        "SELECT * FROM series_subscriptions WHERE metron_series_id = ?",
        [101],
      );

      expect(
        plan.any((p) => p.contains("idx_sub_series") || p.contains("USING INDEX")),
        isTrue,
        reason: "Expected index usage on series subscriptions query: $plan",
      );
    });

    test("reading list items query uses list index", () async {
      final plan = await explainQuery(
        "SELECT * FROM reading_list_items WHERE list_id = ?",
        ["list_abc"],
      );

      expect(
        plan.any((p) => p.contains("idx_rli_list") || p.contains("USING INDEX")),
        isTrue,
        reason: "Expected index usage on reading list items query: $plan",
      );
    });
  });
}
