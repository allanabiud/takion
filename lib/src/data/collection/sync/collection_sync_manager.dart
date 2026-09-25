import "package:drift/drift.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/collection/entities/collection_item.dart";
import "package:takion/src/domain/collection/repositories/collection_repository.dart";

class CollectionSyncResult {
  const CollectionSyncResult({
    required this.itemsFetched,
    required this.itemsUpdated,
    required this.isFullSync,
    this.errorMessage,
  });

  final int itemsFetched;
  final int itemsUpdated;
  final bool isFullSync;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class CollectionSyncManager {
  CollectionSyncManager({
    required db.AppDatabase database,
    required CollectionRepository collectionRepository,
  })  : _database = database,
        _collectionRepository = collectionRepository;

  static const String _syncMetaKey = "metron_last_collection_sync";
  static const String _localUserId = "local-user";

  final db.AppDatabase _database;
  final CollectionRepository _collectionRepository;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<DateTime?> getLastSyncTime() async {
    final str = await _database.syncMetaDao.get(_syncMetaKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<CollectionSyncResult> syncCollection({
    bool forceFullSync = false,
    void Function(int count)? onProgress,
  }) async {
    if (_isSyncing) {
      return const CollectionSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isFullSync: false,
        errorMessage: "Sync already in progress",
      );
    }

    _isSyncing = true;
    try {
      final lastSync = forceFullSync ? null : await getLastSyncTime();
      final isFullSync = lastSync == null;

      var page = 1;
      var totalFetched = 0;
      var totalUpdated = 0;
      final now = DateTime.now().toUtc();

      while (true) {
        final items = await _collectionRepository.getCollection(
          page: page,
          modifiedGt: lastSync,
        );

        if (items.isEmpty) break;

        totalFetched += items.length;
        onProgress?.call(totalFetched);
        final updatedCount = await _ingestCollectionItems(items);
        totalUpdated += updatedCount;

        if (items.length < 20) {
          // Metron default page size is 20, so fewer items means last page
          break;
        }
        page++;
      }

      await _database.syncMetaDao.set(_syncMetaKey, now.toIso8601String());

      AppLogger.info(
        "Collection sync completed: $totalFetched fetched, $totalUpdated updated (fullSync: $isFullSync)",
      );

      return CollectionSyncResult(
        itemsFetched: totalFetched,
        itemsUpdated: totalUpdated,
        isFullSync: isFullSync,
      );
    } catch (e, st) {
      AppLogger.error("Collection sync failed", error: e, stackTrace: st);
      return CollectionSyncResult(
        itemsFetched: 0,
        itemsUpdated: 0,
        isFullSync: forceFullSync,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _ingestCollectionItems(List<CollectionItem> items) async {
    if (items.isEmpty) return 0;

    final issueIds = items.map((i) => i.issueId).where((id) => id > 0).toList();
    final existingLocal = await _database.libraryItemDao.getByIssueIds(issueIds);

    final companions = <db.LibraryItemsCompanion>[];

    for (final item in items) {
      final existing = existingLocal[item.issueId];

      // If existing item has unsaved local changes pending offline sync, don't overwrite
      if (existing != null && existing.syncStatus != "synced") {
        continue;
      }

      final itemId = existing?.id ?? "lib-${item.issueId}";
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final createdAtIso = existing?.createdAt ?? item.modified?.toIso8601String() ?? nowIso;
      final updatedAtIso = item.modified?.toIso8601String() ?? nowIso;

      companions.add(
        db.LibraryItemsCompanion(
          id: Value(itemId),
          userId: const Value(_localUserId),
          metronIssueId: Value(item.issueId),
          metronSeriesId: Value(item.seriesId),
          ownershipStatus: const Value("owned"),
          isRead: Value(item.isRead),
          metronCollectionId: Value(item.id),
          syncStatus: const Value("synced"),
          rating: Value(item.rating),
          purchaseDate: Value(item.purchaseDate?.toIso8601String()),
          pricePaid: Value(item.purchasePrice ?? existing?.pricePaid),
          quantityOwned: Value(item.quantity),
          format: Value(item.bookFormat?.toLowerCase() ?? existing?.format ?? "print"),
          firstReadAt: Value(existing?.firstReadAt),
          conditionGrade: Value(item.grade != null ? item.grade.toString() : existing?.conditionGrade),
          acquiredOn: Value(existing?.acquiredOn),
          notes: Value(item.notes ?? existing?.notes),
          createdAt: Value(createdAtIso),
          updatedAt: Value(updatedAtIso),
        ),
      );
    }

    if (companions.isNotEmpty) {
      await _database.libraryItemDao.batchUpsert(companions);
    }

    return companions.length;
  }
}
