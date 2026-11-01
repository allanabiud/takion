import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/data/common/drift/database.dart";

/// Phase 5 Step 5: query-plan benchmarks for the hot paths exercised by the
/// offline-first overhaul (outbox drain, due-job pickup, remote cache reads,
/// library projections).
///
/// These tests do two things:
/// 1. Verify `EXPLAIN QUERY PLAN` shows index usage (no full scans) for the
///    queries the sync engine and repositories run constantly.
/// 2. Time the queries against a seeded dataset with a generous ceiling so a
///    regression into O(n) scans fails loudly while CI jitter does not.
void main() {
  late AppDatabase db;

  const local = "local-user";
  final now = DateTime.utc(2026, 10, 30);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<String>> explainQuery(
    String sql, [
    List<dynamic> args = const [],
  ]) async {
    final result = await db
        .customSelect(
          "EXPLAIN QUERY PLAN $sql",
          variables: [
            for (final arg in args)
              if (arg is int)
                Variable.withInt(arg)
              else if (arg is String)
                Variable.withString(arg)
              else if (arg is bool)
                Variable.withBool(arg),
          ],
        )
        .get();
    return result.map((row) => row.read<String>("detail")).toList();
  }

  Future<void> seedHotPathTables() async {
    await db.batch((batch) {
      batch.insertAll(db.libraryItems, [
        for (var i = 0; i < 500; i++)
          LibraryItemsCompanion.insert(
            id: "lib-$i",
            userId: local,
            metronIssueId: i,
            metronSeriesId: i % 50,
            ownershipStatus: i.isEven ? "owned" : "wish",
            isRead: i % 3 == 0,
            format: "PRINT",
            createdAt: "2026-01-01T00:00:00.000Z",
            updatedAt: "2026-01-01T00:00:00.000Z",
          ),
      ]);
      batch.insertAll(db.outboxOperations, [
        for (var i = 0; i < 300; i++)
          OutboxOperationsCompanion.insert(
            id: "op-$i",
            accountId: local,
            entityType: OutboxEntityType.collection,
            entityLocalId: "lib-$i",
            operation: OutboxOperationType.create,
            payloadJson: '{"issue":$i}',
            coalesceKey: "collection:$i",
            state: Value(
              i % 4 == 0
                  ? OutboxState.retry
                  : i % 7 == 0
                  ? "running"
                  : OutboxState.pending,
            ),
            notBefore: Value(
              i % 5 == 0 ? now.add(const Duration(minutes: 5)) : null,
            ),
            createdAt: now.subtract(Duration(minutes: 300 - i)),
            updatedAt: now,
          ),
      ]);
      batch.insertAll(db.syncJobs, [
        for (var i = 0; i < 200; i++)
          SyncJobsCompanion.insert(
            id: "job-$i",
            accountId: local,
            reason: "periodic",
            state: Value(i % 3 == 0 ? "completed" : "pending"),
            priority: Value(i % 4),
            notBefore: Value(
              i % 6 == 0 ? now.add(const Duration(minutes: 10)) : null,
            ),
            createdAt: now.subtract(Duration(minutes: 200 - i)),
            updatedAt: now,
          ),
      ]);
      batch.insertAll(db.remoteCacheEntries, [
        for (var i = 0; i < 300; i++)
          RemoteCacheEntriesCompanion.insert(
            accountId: local,
            cacheKey: "collection/page/$i",
            payloadJson: Value('{"page":$i}'),
            fetchedAt: now,
            staleAt: now.add(Duration(hours: i % 24)),
            lastAccessedAt: now,
            isPinned: Value(i % 10 == 0),
          ),
      ]);
    });
  }

  /// Times [iterations] runs of [query] and asserts the total stays under
  /// [ceiling]. Actual timings are surfaced through [printOnFailure].
  ///
  /// Default budget: 25 iterations in 250ms = 10ms per query, comfortably
  /// inside the 16ms/60 FPS frame budget the Phase 5 plan targets while
  /// leaving headroom for CI jitter.
  Future<void> expectFast(
    String label,
    Future<List<dynamic>> Function() query, {
    int iterations = 25,
    Duration ceiling = const Duration(milliseconds: 250),
  }) async {
    await query(); // warm-up
    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      await query();
    }
    sw.stop();
    printOnFailure(
      "$label: ${sw.elapsedMilliseconds}ms for $iterations iterations",
    );
    expect(
      sw.elapsed,
      lessThan(ceiling),
      reason:
          "$label regressed: ${sw.elapsedMilliseconds}ms for "
          "$iterations iterations (ceiling ${ceiling.inMilliseconds}ms)",
    );
  }

  setUp(seedHotPathTables);

  group("query plans (index verification)", () {
    test("outbox ready-scan uses idx_outbox_ready", () async {
      final plan = await explainQuery(
        "SELECT * FROM outbox_operations WHERE account_id = ? AND state IN "
        "('pending', 'retry') AND (not_before IS NULL OR not_before <= ?) "
        "ORDER BY created_at",
        [local, now.millisecondsSinceEpoch],
      );
      expect(
        plan.any((p) => p.contains("idx_outbox_ready")),
        isTrue,
        reason: "Outbox drain must not full-scan: $plan",
      );
    });

    test("outbox coalesce lookup uses idx_outbox_entity", () async {
      final plan = await explainQuery(
        "SELECT * FROM outbox_operations WHERE account_id = ? AND "
        "coalesce_key = ?",
        [local, "collection:1"],
      );
      expect(
        plan.any((p) => p.contains("idx_outbox_entity")),
        isTrue,
        reason: "Outbox coalescing must not full-scan: $plan",
      );
    });

    test("due sync job pickup uses idx_sync_jobs_due", () async {
      final plan = await explainQuery(
        "SELECT * FROM sync_jobs WHERE account_id = ? AND state = 'pending' "
        "AND (not_before IS NULL OR not_before <= ?)",
        [local, now.millisecondsSinceEpoch],
      );
      expect(
        plan.any((p) => p.contains("idx_sync_jobs_due")),
        isTrue,
        reason: "Due-job pickup must not full-scan: $plan",
      );
    });

    test("remote cache read and stale sweep use their indexes", () async {
      final pointPlan = await explainQuery(
        "SELECT * FROM remote_cache_entries WHERE account_id = ? AND cache_key = ?",
        [local, "collection/page/1"],
      );
      expect(
        pointPlan.any(
          (p) => p.contains("USING INDEX") || p.contains("USING PRIMARY KEY"),
        ),
        isTrue,
        reason: "Cache point reads must use an index: $pointPlan",
      );

      final sweepPlan = await explainQuery(
        "SELECT * FROM remote_cache_entries WHERE account_id = ? AND stale_at < ?",
        [local, now.millisecondsSinceEpoch],
      );
      expect(
        sweepPlan.any((p) => p.contains("idx_remote_cache_expiry")),
        isTrue,
        reason: "Stale cache sweep must not full-scan: $sweepPlan",
      );
    });
  });

  group("query timings", () {
    test("outbox drain claim stays fast on a 300-row queue", () async {
      await expectFast(
        "outbox claimNextReady",
        () => db
            .customSelect(
              "SELECT * FROM outbox_operations WHERE account_id = ? AND state IN "
              "('pending', 'retry') AND (not_before IS NULL OR not_before <= ?) "
              "ORDER BY created_at LIMIT 1",
              variables: [
                const Variable<String>("local-user"),
                Variable.withInt(now.millisecondsSinceEpoch),
              ],
            )
            .get(),
      );
    });

    test("due sync job lookup stays fast on a 200-row table", () async {
      await expectFast(
        "sync job due lookup",
        () => db
            .customSelect(
              "SELECT * FROM sync_jobs WHERE account_id = ? AND state = 'pending' "
              "AND (not_before IS NULL OR not_before <= ?)",
              variables: [
                const Variable<String>("local-user"),
                Variable.withInt(now.millisecondsSinceEpoch),
              ],
            )
            .get(),
      );
    });

    test("library projection by ownership stays fast on 500 rows", () async {
      await expectFast(
        "library owned projection",
        () => (db.select(
          db.libraryItems,
        )..where((t) => t.ownershipStatus.equals("owned"))).get(),
        ceiling: const Duration(milliseconds: 600),
      );
    });

    test("remote cache point reads stay fast on 300 entries", () async {
      await expectFast(
        "remote cache point read",
        () =>
            (db.select(db.remoteCacheEntries)..where(
                  (t) =>
                      t.accountId.equals(local) &
                      t.cacheKey.equals("collection/page/1"),
                ))
                .get(),
      );
    });

    test("library projection scales to 1,000 and 10,000 local items", () async {
      // Scale checks from the overhaul plan: 100/1,000/10,000 local items.
      Future<void> seedRange(int from, int to) => db.batch((batch) {
        batch.insertAll(db.libraryItems, [
          for (var i = from; i < to; i++)
            LibraryItemsCompanion.insert(
              id: "lib-$i",
              userId: local,
              metronIssueId: i,
              metronSeriesId: i % 50,
              ownershipStatus: i.isEven ? "owned" : "wish",
              isRead: i % 3 == 0,
              format: "PRINT",
              createdAt: "2026-01-01T00:00:00.000Z",
              updatedAt: "2026-01-01T00:00:00.000Z",
            ),
        ]);
      });

      Future<void> expectLibraryFast(
        String label, {
        required int iterations,
        required Duration ceiling,
      }) {
        return expectFast(
          label,
          () =>
              (db.select(db.libraryItems)
                    ..where((t) => t.ownershipStatus.equals("owned"))
                    ..limit(100))
                  .get(),
          iterations: iterations,
          ceiling: ceiling,
        );
      }

      await seedRange(500, 1000);
      await expectLibraryFast(
        "library owned projection @1k",
        iterations: 10,
        ceiling: const Duration(milliseconds: 500),
      );

      await seedRange(1000, 10000);
      await expectLibraryFast(
        "library owned projection @10k",
        iterations: 10,
        ceiling: const Duration(milliseconds: 500),
      );

      await expectFast(
        "library issue lookup @10k",
        () => (db.select(
          db.libraryItems,
        )..where((t) => t.metronIssueId.equals(7777))).get(),
        iterations: 25,
        ceiling: const Duration(milliseconds: 250),
      );
    });
  });
}
