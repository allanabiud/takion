@Tags(["rollback"])
library;

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  group("Drift Schema & Migration Smoke Suite", () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test("Initializes full schema at current version idempotently", () async {
      expect(db.schemaVersion, equals(20));

      // Verify essential DAOs and tables are accessible
      final seriesNames = await db.seriesNameDao.getAll();
      expect(seriesNames, isEmpty);

      final series = await db.metronEntityDao.getAllSeriesNames();
      expect(series, isEmpty);

      final syncWatermark = await db.syncMetaDao.get("sync_watermark");
      expect(syncWatermark, isNull);

      final queueEntries = await db.offlineQueueDao.getPendingEntries();
      expect(queueEntries, isEmpty);

      final wishlist = await db.wishlistDao.getAll();
      expect(wishlist, isEmpty);
    });

    test(
      "Schema tables support CRUD operations without constraint errors",
      () async {
        // Insert sample entity and verify retrieval
        await db.seriesNameDao.add("action comics", "Action Comics");
        final names = await db.seriesNameDao.getAll();
        expect(names.length, equals(1));
        expect(names.first.originalName, equals("Action Comics"));

        // Verify settings KV store
        await db.settingsDao.setBool("test_key", true);
        final boolVal = await db.settingsDao.getBool(
          "test_key",
          defaultValue: false,
        );
        expect(boolVal, isTrue);

        // Verify sync log entry
        await db.syncMetaDao.set("last_sync_status", "success");
        final status = await db.syncMetaDao.get("last_sync_status");
        expect(status, equals("success"));

        // Verify offline write queue entry
        final queueId = await db.offlineQueueDao.enqueue(
          operation: "create",
          entityType: "collection",
          payload: "{}",
        );
        expect(queueId, isPositive);
        final pending = await db.offlineQueueDao.getPendingEntries();
        expect(pending.length, equals(1));
        expect(pending.first.operation, equals("create"));
      },
    );

    test("durable sync primitives persist typed state", () async {
      final now = DateTime.utc(2026, 10, 25);

      await db.outboxDao.upsert(
        OutboxOperationsCompanion.insert(
          id: "op-1",
          accountId: "local-user",
          entityType: "collection",
          entityLocalId: "lib-42",
          operation: "create",
          payloadJson: '{"issue_id":42}',
          coalesceKey: "collection:lib-42",
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(
        (await db.outboxDao.getReady(
          accountId: "local-user",
          now: now,
        )).single.id,
        "op-1",
      );

      await db.syncCursorDao.upsert(
        accountId: "local-user",
        resource: "collection",
        cursorJson: '{"next":null}',
        isComplete: true,
        updatedAt: now,
      );
      expect(
        (await db.syncCursorDao.get("local-user", "collection"))!.isComplete,
        isTrue,
      );

      await db.remoteCacheDao.upsert(
        RemoteCacheEntriesCompanion.insert(
          accountId: "local-user",
          cacheKey: "GET:/issue/42/",
          fetchedAt: now,
          staleAt: now.add(const Duration(days: 1)),
          lastAccessedAt: now,
        ),
      );
      expect(
        await db.remoteCacheDao.get("local-user", "GET:/issue/42/"),
        isNotNull,
      );
    });
  });
}
