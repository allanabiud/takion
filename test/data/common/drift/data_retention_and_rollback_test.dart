import "dart:convert";
import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/local_backup_service.dart";

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group("Schema, Rollback/Backup, and Data Retention Suite", () {
    late AppDatabase db;
    late LocalBackupService backupService;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      backupService = LocalBackupService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test("backup export and restore preserves user state completely", () async {
      // 1. Populate user data across library, wishlist, and favorites
      await db.libraryItemDao.upsert(
        const LibraryItemsCompanion(
          id: Value("lib-1"),
          userId: Value("local"),
          metronIssueId: Value(101),
          metronSeriesId: Value(201),
          ownershipStatus: Value("owned"),
          isRead: Value(true),
          rating: Value(5),
          format: Value("print"),
          createdAt: Value("2026-01-01T00:00:00Z"),
          updatedAt: Value("2026-01-02T00:00:00Z"),
        ),
      );
      await db.favoriteDao.toggleSeries(201);

      // 2. Export backup
      final backupBytes = await backupService.exportBackupData();
      expect(backupBytes, isNotEmpty);

      // 3. Clear or mutate data
      await db.libraryItemDao.deleteByIssueId(101);
      expect(await db.libraryItemDao.getByIssueId(101), isNull);

      // 4. Restore from backup
      await backupService.importBackupData(backupBytes);

      // 5. Verify restored data
      final restored = await db.libraryItemDao.getByIssueId(101);
      expect(restored, isNotNull);
      expect(restored!.metronSeriesId, 201);
      expect(restored.isRead, isTrue);
      expect(restored.rating, 5);
      final favorite = await db.favoriteDao.getSeriesBySeriesId(201);
      expect(favorite, isNotNull);
    });

    test(
      "invalid or corrupted backup aborts without corrupting local data",
      () async {
        await db.libraryItemDao.upsert(
          const LibraryItemsCompanion(
            id: Value("survivor"),
            userId: Value("local"),
            metronIssueId: Value(999),
            metronSeriesId: Value(100),
            ownershipStatus: Value("owned"),
            isRead: Value(false),
            format: Value("print"),
            createdAt: Value("2026-01-01T00:00:00Z"),
            updatedAt: Value("2026-01-01T00:00:00Z"),
          ),
        );

        final corruptBytes = utf8.encode(
          jsonEncode({"version": 999, "corrupt": true}),
        );

        expect(
          () => backupService.importBackupData(corruptBytes),
          throwsFormatException,
        );

        // Verify original data survived untouched
        final survivor = await db.libraryItemDao.getByIssueId(999);
        expect(survivor, isNotNull);
        expect(survivor!.id, "survivor");
      },
    );

    test(
      "cache eviction never purges user entities or pinned cache items",
      () async {
        // 1. Insert user library item
        await db.libraryItemDao.upsert(
          const LibraryItemsCompanion(
            id: Value("lib-pinned"),
            userId: Value("local"),
            metronIssueId: Value(500),
            metronSeriesId: Value(100),
            ownershipStatus: Value("owned"),
            isRead: Value(false),
            format: Value("print"),
            createdAt: Value("2026-01-01T00:00:00Z"),
            updatedAt: Value("2026-01-01T00:00:00Z"),
          ),
        );

        // 2. Insert cache entries: one pinned, one unpinned expired
        final now = DateTime.now().toUtc();
        await db.remoteCacheDao.upsertEntry(
          accountId: "default",
          cacheKey: "issue:500",
          payloadJson: '{"id": 500, "name": "Pinned Issue"}',
          etag: '"etag-500"',
          fetchedAt: now.subtract(const Duration(days: 30)),
          staleAt: now.subtract(const Duration(days: 10)), // expired
          isPinned: true,
        );

        await db.remoteCacheDao.upsertEntry(
          accountId: "default",
          cacheKey: "issue:9999",
          payloadJson: '{"id": 9999, "name": "Ephemeral Issue"}',
          etag: '"etag-9999"',
          fetchedAt: now.subtract(const Duration(days: 30)),
          staleAt: now.subtract(const Duration(days: 10)), // expired
          isPinned: false,
        );

        // 3. Run cache eviction
        final evictedCount = await db.remoteCacheDao.evictStale(
          accountId: "default",
          before: now,
        );
        expect(evictedCount, 1);

        // Pinned cache entry survives despite expiration
        final pinnedEntry = await db.remoteCacheDao.getEntry(
          "default",
          "issue:500",
        );
        expect(pinnedEntry, isNotNull);
        expect(pinnedEntry!.isPinned, isTrue);

        // Ephemeral cache entry was evicted
        final ephemeralEntry = await db.remoteCacheDao.getEntry(
          "default",
          "issue:9999",
        );
        expect(ephemeralEntry, isNull);

        // User library item is unaffected by cache eviction
        final libItem = await db.libraryItemDao.getByIssueId(500);
        expect(libItem, isNotNull);
      },
    );

    test(
      "tombstones with deletedAt are retained for sync propagation",
      () async {
        final deleteTimestamp = DateTime.now().toUtc().toIso8601String();
        await db.libraryItemDao.upsert(
          LibraryItemsCompanion(
            id: const Value("lib-deleted"),
            userId: const Value("local"),
            metronIssueId: const Value(777),
            metronSeriesId: const Value(888),
            ownershipStatus: const Value("owned"),
            isRead: const Value(false),
            format: const Value("print"),
            deletedAt: Value(deleteTimestamp),
            syncStatus: const Value("pending_delete"),
            createdAt: const Value("2026-01-01T00:00:00Z"),
            updatedAt: const Value("2026-01-01T00:00:00Z"),
          ),
        );

        final row = await db.libraryItemDao.getByIssueId(777);
        expect(row, isNotNull);
        expect(row!.deletedAt, deleteTimestamp);
        expect(row.syncStatus, "pending_delete");
      },
    );
  });
}
