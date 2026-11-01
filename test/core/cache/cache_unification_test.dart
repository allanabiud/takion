import "dart:convert";
import "package:dio/dio.dart";
import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/cache/cache_mode.dart";
import "package:takion/src/core/cache/cache_pinning_service.dart";
import "package:takion/src/core/cache/cache_policy.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/repositories/primitives/entity_detail_repository.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;
  late CachePinningService pinningService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    pinningService = CachePinningService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group("RemoteCacheDao & CachePinningService", () {
    test("upsert, get, touch, and pin operations work properly", () async {
      final now = DateTime.now().toUtc();
      await db.remoteCacheDao.upsertEntry(
        accountId: "local-user",
        cacheKey: "test:key:1",
        etag: '"123"',
        payloadJson: '{"test": 1}',
        fetchedAt: now,
        staleAt: now.add(const Duration(hours: 1)),
      );

      final entry = await db.remoteCacheDao.getEntry(
        "local-user",
        "test:key:1",
      );
      expect(entry, isNotNull);
      expect(entry!.etag, '"123"');
      expect(entry.payloadJson, '{"test": 1}');
      expect(entry.isPinned, isFalse);

      await db.remoteCacheDao.setPinned("local-user", "test:key:1", true);
      final pinnedEntry = await db.remoteCacheDao.getEntry(
        "local-user",
        "test:key:1",
      );
      expect(pinnedEntry!.isPinned, isTrue);
    });

    test(
      "LRU eviction respects maxEntries and never evicts pinned items",
      () async {
        final now = DateTime.now().toUtc();

        // Insert 5 entries with different lastAccessedAt
        for (var i = 1; i <= 5; i++) {
          await db.remoteCacheDao.upsertEntry(
            accountId: "local-user",
            cacheKey: "key:$i",
            payloadJson: '{"i": $i}',
            fetchedAt: now,
            staleAt: now.add(const Duration(days: 1)),
            lastAccessedAt: now.add(Duration(minutes: i)),
            isPinned: i == 1, // key:1 is pinned!
          );
        }

        // Evict to maxEntries: 2 (unpinned count is 4, so 2 excess unpinned)
        final evicted = await db.remoteCacheDao.evictLru(
          accountId: "local-user",
          maxEntries: 2,
        );
        expect(evicted, 2);

        // key:1 must survive because it's pinned
        expect(await db.remoteCacheDao.get("local-user", "key:1"), isNotNull);
        // Oldest unpinned (key:2 and key:3) should be evicted
        expect(await db.remoteCacheDao.get("local-user", "key:2"), isNull);
        expect(await db.remoteCacheDao.get("local-user", "key:3"), isNull);
        // Newest unpinned (key:4 and key:5) should survive
        expect(await db.remoteCacheDao.get("local-user", "key:4"), isNotNull);
        expect(await db.remoteCacheDao.get("local-user", "key:5"), isNotNull);
      },
    );

    test(
      "pinEssentialEntities pins library items, subscriptions, wishlist",
      () async {
        // Seed user data
        final nowStr = DateTime.now().toUtc().toIso8601String();
        await db
            .into(db.libraryItems)
            .insert(
              LibraryItemsCompanion.insert(
                id: "lib-1",
                userId: "local-user",
                metronIssueId: 101,
                metronSeriesId: 201,
                ownershipStatus: "owned",
                isRead: false,
                format: "print",
                createdAt: nowStr,
                updatedAt: nowStr,
              ),
            );

        await db
            .into(db.seriesSubscriptions)
            .insert(
              SeriesSubscriptionsCompanion.insert(
                id: "sub-1",
                userId: "local-user",
                metronSeriesId: 202,
                subscribedAt: nowStr,
                isActive: true,
                createdAt: nowStr,
                updatedAt: nowStr,
              ),
            );

        await db
            .into(db.wishlistItems)
            .insert(
              WishlistItemsCompanion.insert(
                id: const Value(1),
                issueId: 102,
                seriesId: 203,
                seriesName: "Batman",
                issueNumber: "1",
                createdAt: nowStr,
                updatedAt: nowStr,
              ),
            );

        // Create unpinned cache entries for these items
        final now = DateTime.now().toUtc();
        for (final key in [
          "details:issue_details:101",
          "details:series_details:201",
          "details:series_details:202",
          "details:issue_details:102",
          "details:series_details:203",
          "unrelated:key",
        ]) {
          await db.remoteCacheDao.upsertEntry(
            accountId: "local-user",
            cacheKey: key,
            payloadJson: "{}",
            fetchedAt: now,
            staleAt: now.add(const Duration(days: 1)),
            isPinned: false,
          );
        }

        await pinningService.pinEssentialEntities(accountId: "local-user");

        // Verify essential keys are now pinned
        expect(
          (await db.remoteCacheDao.get(
            "local-user",
            "details:issue_details:101",
          ))!.isPinned,
          isTrue,
        );
        expect(
          (await db.remoteCacheDao.get(
            "local-user",
            "details:series_details:202",
          ))!.isPinned,
          isTrue,
        );
        expect(
          (await db.remoteCacheDao.get(
            "local-user",
            "details:issue_details:102",
          ))!.isPinned,
          isTrue,
        );
        // Unrelated key is still unpinned
        expect(
          (await db.remoteCacheDao.get(
            "local-user",
            "unrelated:key",
          ))!.isPinned,
          isFalse,
        );
      },
    );
  });

  group("DetailsLocalCache migration and persistence", () {
    test("transparently migrates legacy app_settings detail cache", () async {
      // Write legacy entries directly into app_settings
      const prefix = "issue_details";
      const id = "456";
      final legacyPayload = jsonEncode({"id": 456, "number": "1"});
      await db.settingsDao.setString(
        "details_cache:$prefix:$id",
        legacyPayload,
      );
      await db.settingsDao.setString(
        "details_cache_at:$prefix:$id",
        DateTime.now().toUtc().toIso8601String(),
      );

      final cache = DetailsLocalCache(
        db: db,
        cacheKeyPrefix: prefix,
        entityType: prefix,
      );

      // Read from DetailsLocalCache
      final result = await cache.get(id);
      expect(result, isNotNull);
      expect(result!["id"], 456);

      // Verify that legacy settings keys were cleaned up
      expect(
        await db.settingsDao.getString("details_cache:$prefix:$id"),
        isNull,
      );
      expect(
        await db.settingsDao.getString("details_cache_at:$prefix:$id"),
        isNull,
      );

      // Verify that the entry now lives in remote_cache_entries
      final migratedEntry = await db.remoteCacheDao.get(
        "local-user",
        "details:$prefix:$id",
      );
      expect(migratedEntry, isNotNull);
      expect(migratedEntry!.payloadJson, legacyPayload);
    });
  });

  group("EntityDetailRepository with CacheMode", () {
    test("returns local cache without remote call when cacheFirst", () async {
      var remoteCalled = false;
      final repo = EntityDetailRepository<Map<String, dynamic>, String>(
        resourceName: "test_entity",
        cachePolicy: const CachePolicy(ttl: Duration(hours: 1)),
        getRemote: (id) async {
          remoteCalled = true;
          return Response(
            requestOptions: RequestOptions(path: "/test/$id"),
            statusCode: 200,
            data: {"name": "remote"},
          );
        },
        getLocalCachedJson: (id) async => {"name": "cached"},
        getCachedAt: (id) async => DateTime.now().toUtc(),
        cacheLocalJson: (id, json) async {},
        dtoFromJson: (json) => json,
        dtoToEntity: (dto) => dto["name"] as String,
      );

      final result = await repo.getDetails(1, cacheMode: CacheMode.cacheFirst);
      expect(result, "cached");
      expect(remoteCalled, isFalse);
    });

    test("falls back to local cache when network fails", () async {
      final repo = EntityDetailRepository<Map<String, dynamic>, String>(
        resourceName: "test_entity",
        cachePolicy: const CachePolicy(ttl: Duration(hours: 1)),
        getRemote: (id) async {
          throw DioException(
            requestOptions: RequestOptions(path: "/test/$id"),
            type: DioExceptionType.connectionError,
          );
        },
        getLocalCachedJson: (id) async => {"name": "offline_cached"},
        getCachedAt: (id) async =>
            DateTime.now().toUtc().subtract(const Duration(days: 2)),
        cacheLocalJson: (id, json) async {},
        dtoFromJson: (json) => json,
        dtoToEntity: (dto) => dto["name"] as String,
      );

      final result = await repo.getDetails(1, forceRefresh: true);
      expect(result, "offline_cached");
    });
  });
}
