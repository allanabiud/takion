import 'package:drift/drift.dart';
import 'package:takion/src/core/cache/user_state_cache.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/domain/repositories.dart';

class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository(this._database, this._cache);

  static const _localUserId = 'local-user';

  final db.AppDatabase _database;
  final UserStateCache _cache;

  String _idForIssue(int issueId) => 'lib-$issueId';

  String _readLogId(int issueId) =>
      'read-$issueId-${DateTime.now().microsecondsSinceEpoch}';

  String _ownershipToRaw(LibraryOwnershipStatus status) {
    switch (status) {
      case LibraryOwnershipStatus.owned:
        return 'owned';
      case LibraryOwnershipStatus.notOwned:
        return 'not_owned';
      case LibraryOwnershipStatus.wishlist:
        return 'wishlist';
    }
  }

  LibraryOwnershipStatus _ownershipFromRaw(String raw) {
    switch (raw) {
      case 'owned':
        return LibraryOwnershipStatus.owned;
      case 'wishlist':
        return LibraryOwnershipStatus.wishlist;
      case 'not_owned':
      default:
        return LibraryOwnershipStatus.notOwned;
    }
  }

  String _formatToRaw(LibraryItemFormat format) {
    switch (format) {
      case LibraryItemFormat.print:
        return 'print';
      case LibraryItemFormat.digital:
        return 'digital';
      case LibraryItemFormat.both:
        return 'both';
    }
  }

  LibraryItemFormat _formatFromRaw(String raw) {
    switch (raw) {
      case 'digital':
        return LibraryItemFormat.digital;
      case 'both':
        return LibraryItemFormat.both;
      case 'print':
      default:
        return LibraryItemFormat.print;
    }
  }

  LibraryItem _toDomain(db.LibraryItem d) {
    return LibraryItem(
      id: d.id,
      userId: d.userId,
      metronIssueId: d.metronIssueId,
      metronSeriesId: d.metronSeriesId,
      ownershipStatus: _ownershipFromRaw(d.ownershipStatus),
      isRead: d.isRead,
      rating: d.rating,
      purchaseDate: d.purchaseDate != null
          ? DateTime.tryParse(d.purchaseDate!)
          : null,
      pricePaid: d.pricePaid,
      quantityOwned: d.quantityOwned,
      format: _formatFromRaw(d.format),
      firstReadAt: d.firstReadAt != null
          ? DateTime.tryParse(d.firstReadAt!)
          : null,
      conditionGrade: d.conditionGrade,
      acquiredOn: d.acquiredOn != null
          ? DateTime.tryParse(d.acquiredOn!)
          : null,
      notes: d.notes,
      createdAt: DateTime.parse(d.createdAt),
      updatedAt: DateTime.parse(d.updatedAt),
    );
  }

  LibraryReadLog _readLogToDomain(db.LibraryReadLog d) {
    return LibraryReadLog(
      id: d.id,
      userId: d.userId,
      collectionItemId: d.collectionItemId,
      readAt: DateTime.parse(d.readAt),
      notes: d.notes,
      createdAt: DateTime.parse(d.createdAt),
    );
  }

  @override
  Future<int> getItemCount() async => _database.libraryItemDao.getItemCount();

  @override
  Future<List<LibraryItem>> listItems({int limit = 50, int offset = 0}) async {
    final rows = await _database.libraryItemDao.getItems(
      limit: limit,
      offset: offset,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<LibraryItem?> getItemByIssueId(int metronIssueId) async {
    final cached = _cache.getLibraryItem(metronIssueId);
    if (cached != null) return cached;
    final d = await _database.libraryItemDao.getByIssueId(metronIssueId);
    if (d != null) {
      final item = _toDomain(d);
      _cache.setLibraryItem(metronIssueId, item);
      return item;
    }
    return null;
  }

  @override
  Future<List<LibraryItem>> getItemsBySeriesId(int metronSeriesId) async {
    final rows = await _database.libraryItemDao.getBySeriesId(metronSeriesId);
    return rows.map(_toDomain).toList();
  }

  db.LibraryItemsCompanion _itemToCompanion(LibraryItem item) {
    return db.LibraryItemsCompanion(
      id: Value(item.id),
      userId: Value(item.userId),
      metronIssueId: Value(item.metronIssueId),
      metronSeriesId: Value(item.metronSeriesId),
      ownershipStatus: Value(_ownershipToRaw(item.ownershipStatus)),
      isRead: Value(item.isRead),
      rating: Value(item.rating),
      purchaseDate: Value(item.purchaseDate?.toIso8601String()),
      pricePaid: Value(item.pricePaid),
      quantityOwned: Value(item.quantityOwned),
      format: Value(_formatToRaw(item.format)),
      firstReadAt: Value(item.firstReadAt?.toIso8601String()),
      conditionGrade: Value(item.conditionGrade),
      acquiredOn: Value(item.acquiredOn?.toIso8601String()),
      notes: Value(item.notes),
      createdAt: Value(item.createdAt.toIso8601String()),
      updatedAt: Value(item.updatedAt.toIso8601String()),
    );
  }

  @override
  Future<void> batchUpsertItems(int seriesId, List<LibraryItem> items) async {
    if (items.isEmpty) return;
    final companions = items.map(_itemToCompanion).toList();
    await _database.libraryItemDao.batchUpsert(companions);
    for (final item in items) {
      _cache.setLibraryItem(item.metronIssueId, item);
    }
  }

  @override
  Future<void> batchDeleteItemsByIssueId(List<int> metronIssueIds) async {
    if (metronIssueIds.isEmpty) return;
    final ids = metronIssueIds.map(_idForIssue).toList();
    await _database.libraryItemDao.batchDeleteByIds(ids);
    for (final id in metronIssueIds) {
      _cache.removeLibraryItem(id);
    }
  }

  @override
  Future<void> batchAddReadLogs(List<LibraryReadLog> logs) async {
    if (logs.isEmpty) return;
    final companions = logs
        .map(
          (log) => db.LibraryReadLogsCompanion(
            id: Value(log.id),
            userId: Value(log.userId),
            collectionItemId: Value(log.collectionItemId),
            readAt: Value(log.readAt.toIso8601String()),
            notes: Value(log.notes),
            createdAt: Value(log.createdAt.toIso8601String()),
          ),
        )
        .toList();
    await _database.readLogDao.batchInsert(companions);
  }

  @override
  Future<void> batchDeleteReadLogsByItemIds(
    List<String> collectionItemIds,
  ) async {
    if (collectionItemIds.isEmpty) return;
    await _database.readLogDao.batchDeleteByItemIds(collectionItemIds);
  }

  @override
  Future<LibraryItem> upsertItem({
    required int metronIssueId,
    required int metronSeriesId,
    required LibraryOwnershipStatus ownershipStatus,
    bool isRead = false,
    int? rating,
    DateTime? purchaseDate,
    double? pricePaid,
    int quantityOwned = 1,
    LibraryItemFormat format = LibraryItemFormat.print,
    DateTime? firstReadAt,
    String? conditionGrade,
    DateTime? acquiredOn,
    String? notes,
  }) async {
    final existing = await _database.libraryItemDao.getByIssueId(metronIssueId);

    double? resolvedPricePaid;
    if (pricePaid != null) {
      resolvedPricePaid = pricePaid;
    } else if (existing != null) {
      resolvedPricePaid = existing.pricePaid;
    }

    final now = DateTime.now().toUtc();
    final item = LibraryItem(
      id: existing?.id ?? _idForIssue(metronIssueId),
      userId: _localUserId,
      metronIssueId: metronIssueId,
      metronSeriesId: metronSeriesId,
      ownershipStatus: ownershipStatus,
      isRead: isRead,
      rating: rating,
      purchaseDate: purchaseDate,
      pricePaid: resolvedPricePaid,
      quantityOwned: quantityOwned,
      format: format,
      firstReadAt: firstReadAt,
      conditionGrade: conditionGrade,
      acquiredOn: acquiredOn,
      notes: notes,
      createdAt:
          (existing?.createdAt != null
              ? DateTime.tryParse(existing!.createdAt)
              : null) ??
          now,
      updatedAt: now,
    );

    await _database.libraryItemDao.upsert(
      db.LibraryItemsCompanion(
        id: Value(item.id),
        userId: Value(item.userId),
        metronIssueId: Value(item.metronIssueId),
        metronSeriesId: Value(item.metronSeriesId),
        ownershipStatus: Value(_ownershipToRaw(item.ownershipStatus)),
        isRead: Value(item.isRead),
        rating: Value(item.rating),
        purchaseDate: Value(item.purchaseDate?.toIso8601String()),
        pricePaid: Value(item.pricePaid),
        quantityOwned: Value(item.quantityOwned),
        format: Value(_formatToRaw(item.format)),
        firstReadAt: Value(item.firstReadAt?.toIso8601String()),
        conditionGrade: Value(item.conditionGrade),
        acquiredOn: Value(item.acquiredOn?.toIso8601String()),
        notes: Value(item.notes),
        createdAt: Value(item.createdAt.toIso8601String()),
        updatedAt: Value(item.updatedAt.toIso8601String()),
      ),
    );

    _cache.setLibraryItem(metronIssueId, item);
    return item;
  }

  @override
  Future<List<LibraryReadLog>> getReadLogsByIssueId(int metronIssueId) async {
    return _database.readLogDao
        .watchByIssueId(metronIssueId)
        .first
        .then((rows) => rows.map(_readLogToDomain).toList());
  }

  @override
  Future<LibraryReadLog> addReadLog({
    required int metronIssueId,
    required DateTime readAt,
    String? notes,
  }) async {
    final item = await _database.libraryItemDao.getByIssueId(metronIssueId);
    if (item == null) {
      throw StateError('Library item does not exist for issue $metronIssueId');
    }

    final now = DateTime.now().toUtc();
    final log = LibraryReadLog(
      id: _readLogId(metronIssueId),
      userId: _localUserId,
      collectionItemId: item.id,
      readAt: readAt,
      notes: notes,
      createdAt: now,
    );

    await _database.libraryItemDao.insertReadLog(
      db.LibraryReadLogsCompanion(
        id: Value(log.id),
        userId: Value(log.userId),
        collectionItemId: Value(log.collectionItemId),
        readAt: Value(log.readAt.toIso8601String()),
        notes: Value(log.notes),
        createdAt: Value(log.createdAt.toIso8601String()),
      ),
    );

    return log;
  }

  @override
  Future<void> deleteReadLogById(String readLogId) async {
    await _database.readLogDao.deleteById(readLogId);
  }

  @override
  Future<void> deleteItemByIssueId(int metronIssueId) async {
    await _database.libraryItemDao.deleteById(_idForIssue(metronIssueId));
    _cache.removeLibraryItem(metronIssueId);
  }

  @override
  Future<Set<int>> getOwnedIssueIds(List<int> metronIssueIds) async {
    if (metronIssueIds.isEmpty) return <int>{};
    final owned = await _database.libraryItemDao.getOwnedIssueIds();
    final set = metronIssueIds.toSet();
    return owned.where(set.contains).toSet();
  }

  @override
  Future<void> updateItemPricePaid(int metronIssueId, double pricePaid) async {
    final existing = await _database.libraryItemDao.getByIssueId(metronIssueId);
    if (existing == null) return;
    if (existing.pricePaid != null) return;

    final now = DateTime.now().toUtc();
    await _database.libraryItemDao.upsert(
      db.LibraryItemsCompanion(
        id: Value(existing.id),
        userId: Value(existing.userId),
        metronIssueId: Value(existing.metronIssueId),
        metronSeriesId: Value(existing.metronSeriesId),
        ownershipStatus: Value(existing.ownershipStatus),
        isRead: Value(existing.isRead),
        rating: Value(existing.rating),
        purchaseDate: Value(existing.purchaseDate),
        pricePaid: Value(pricePaid),
        quantityOwned: Value(existing.quantityOwned),
        format: Value(existing.format),
        firstReadAt: Value(existing.firstReadAt),
        conditionGrade: Value(existing.conditionGrade),
        acquiredOn: Value(existing.acquiredOn),
        notes: Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now.toIso8601String()),
      ),
    );
  }

  @override
  Future<void> batchUpdatePricePaid(Map<int, double> priceByIssueId) async {
    if (priceByIssueId.isEmpty) return;
    await _database.libraryItemDao.batchUpdatePricePaid(priceByIssueId);
    final updatedMap = await _database.libraryItemDao.getByIssueIds(
      priceByIssueId.keys.toList(),
    );
    for (final entry in updatedMap.entries) {
      final item = _toDomain(entry.value);
      _cache.setLibraryItem(entry.key, item);
    }
  }
}
