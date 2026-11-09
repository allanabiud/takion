import "dart:io";

import "package:drift/native.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/cache_header_store.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";

/// Phase 5 Step 4: the cache rebuild escape hatch must clear only rebuildable
/// caches and never touch user tables (`library_items`, `outbox_operations`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late ProviderContainer container;
  late CacheHeaderStore cacheHeaderStore;
  late Directory sharedTempDir;

  setUpAll(() {
    sharedTempDir = Directory.systemTemp.createTempSync("takion_cache_rebuild");
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = sharedTempDir;

    // flutter_cache_manager resolves its disk cache through path_provider;
    // point it at a real temp directory so emptyCache() works in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("plugins.flutter.io/path_provider"),
          (call) async => tempDir.path,
        );

    cacheHeaderStore = CacheHeaderStore();
    container = ProviderContainer(
      overrides: [
        driftDatabaseProvider.overrideWithValue(db),
        cacheHeaderStoreProvider.overrideWithValue(cacheHeaderStore),
      ],
    );
    // settingsProvider is autoDispose; keep it alive for the test body.
    final subscription = container.listen(settingsProvider, (_, _) {});
    addTearDown(subscription.close);
    addTearDown(container.dispose);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("plugins.flutter.io/path_provider"),
          null,
        );
    await db.close();
  });

  tearDownAll(() {
    if (sharedTempDir.existsSync()) {
      sharedTempDir.deleteSync(recursive: true);
    }
  });

  const local = "local-user";
  final now = DateTime.utc(2026, 10, 30);

  Future<void> seedRebuildableCache() async {
    await db.remoteCacheDao.upsertEntry(
      accountId: local,
      cacheKey: "collection/page/1",
      etag: '"etag-1"',
      payloadJson: '{"results":[]}',
      fetchedAt: now,
      staleAt: now.add(const Duration(hours: 1)),
    );
    await db.remoteCacheDao.upsertEntry(
      accountId: local,
      cacheKey: "issue/42",
      payloadJson: '{"id":42}',
      fetchedAt: now,
      staleAt: now.add(const Duration(hours: 1)),
      isPinned: true,
    );
    await cacheHeaderStore.store(
      db,
      "https://metron.cloud/api/collection/",
      etag: '"abc"',
      lastModified: "Wed, 21 Oct 2026 07:28:00 GMT",
    );
    // Rate-limit state lives in SyncMeta too and must survive a rebuild.
    await db.syncMetaDao.set("ratelimit:$local", '{"burstRemaining":7}');
  }

  Future<void> seedUserData() async {
    await db.libraryItemDao.upsert(
      LibraryItemsCompanion.insert(
        id: "lib-101",
        userId: local,
        metronIssueId: 101,
        metronSeriesId: 20,
        ownershipStatus: "owned",
        isRead: false,
        format: "PRINT",
        createdAt: "2026-01-01T00:00:00.000Z",
        updatedAt: "2026-01-01T00:00:00.000Z",
      ),
    );
    await db.outboxDao.upsert(
      OutboxOperationsCompanion.insert(
        id: "op-1",
        accountId: local,
        entityType: OutboxEntityType.collection,
        entityLocalId: "lib-101",
        operation: OutboxOperationType.create,
        payloadJson: '{"issue":101}',
        coalesceKey: "collection:101",
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<String>> remainingCacheKeys() async {
    final rows = await (db.select(
      db.remoteCacheEntries,
    )..where((t) => t.accountId.equals(local))).get();
    return rows.map((e) => e.cacheKey).toList();
  }

  group("SettingsNotifier.clearCache", () {
    test("keepPinned clears unpinned metadata but preserves pinned entries, "
        "user data, and pending sync work", () async {
      await seedRebuildableCache();
      await seedUserData();

      await container
          .read(settingsProvider.notifier)
          .clearCache(keepPinned: true);

      // Unpinned remote metadata is gone; pinned survives.
      final remaining = await remainingCacheKeys();
      expect(remaining, ["issue/42"]);

      // HTTP validators cleared, rate-limit state untouched.
      expect(
        cacheHeaderStore.getEtag("https://metron.cloud/api/collection/"),
        isNull,
      );
      expect(
        cacheHeaderStore.getLastModified(
          "https://metron.cloud/api/collection/",
        ),
        isNull,
      );
      expect(await db.syncMetaDao.get("ratelimit:$local"), isNotNull);

      // User tables are untouched.
      final libItem = await db.libraryItemDao.getByIssueId(101);
      expect(libItem, isNotNull);
      expect(libItem!.ownershipStatus, "owned");
      final pendingOps = await db.outboxDao.getPendingEntries();
      expect(pendingOps.length, 1);
      expect(pendingOps.first.id, "op-1");

      final settings = container.read(settingsProvider);
      expect(settings.isBusy, isFalse);
      expect(settings.statusMessage, contains("preserved"));
    });

    test("keepPinned false clears pinned entries too", () async {
      await seedRebuildableCache();
      await seedUserData();

      await container
          .read(settingsProvider.notifier)
          .clearCache(keepPinned: false);

      expect(await remainingCacheKeys(), isEmpty);

      // Even a full rebuild leaves user data and pending sync alone.
      expect(await db.libraryItemDao.getByIssueId(101), isNotNull);
      expect((await db.outboxDao.getPendingEntries()).length, 1);
    });

    test("rebuild does not clear rate-limit cooldown state", () async {
      await seedRebuildableCache();

      await container.read(settingsProvider.notifier).clearCache();

      // A rebuild must not silently reset a persisted 429 cooldown.
      final raw = await db.syncMetaDao.get("ratelimit:$local");
      expect(raw, '{"burstRemaining":7}');
    });
  });
}
