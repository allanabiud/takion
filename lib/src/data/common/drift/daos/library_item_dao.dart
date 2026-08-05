import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class LibraryItemStatusRow {
  const LibraryItemStatusRow({
    required this.metronIssueId,
    required this.ownershipStatus,
    required this.isRead,
    required this.rating,
  });

  final int metronIssueId;
  final String ownershipStatus;
  final bool isRead;
  final int? rating;
}

class SeriesSummaryDataRow {
  const SeriesSummaryDataRow({
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.issueCount,
    required this.categoryCount,
  });

  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final int? issueCount;
  final int categoryCount;
}

class LibraryItemDao extends DatabaseAccessor<AppDatabase> {
  LibraryItemDao(super.db);

  Future<List<SeriesSummaryDataRow>> getSeriesSummariesByCategory({
    String? ownershipStatus,
    bool? isRead,
    bool? isUnrated,
  }) async {
    final countCol = attachedDatabase.libraryItems.id.count();
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([
        attachedDatabase.libraryItems.metronSeriesId,
        countCol,
        attachedDatabase.metronSeries.name,
        attachedDatabase.metronSeries.volume,
        attachedDatabase.metronSeries.yearBegan,
        attachedDatabase.metronSeries.issueCount,
      ])
      ..join([
        leftOuterJoin(
          attachedDatabase.metronSeries,
          attachedDatabase.metronSeries.id.equalsExp(
            attachedDatabase.libraryItems.metronSeriesId,
          ),
        ),
      ]);

    if (ownershipStatus != null) {
      query.where(
        attachedDatabase.libraryItems.ownershipStatus.equals(ownershipStatus),
      );
    }
    if (isRead != null) {
      query.where(attachedDatabase.libraryItems.isRead.equals(isRead));
    }
    if (isUnrated == true) {
      query.where(attachedDatabase.libraryItems.rating.isNull());
    }

    query.where(
      attachedDatabase.libraryItems.metronSeriesId.isBiggerThanValue(0),
    );
    query.groupBy([attachedDatabase.libraryItems.metronSeriesId]);

    final rows = await query.get();

    return rows.map((row) {
      final seriesId =
          row.read(attachedDatabase.libraryItems.metronSeriesId) ?? 0;
      final name = row.read(attachedDatabase.metronSeries.name);
      final vol = row.read(attachedDatabase.metronSeries.volume);
      final year = row.read(attachedDatabase.metronSeries.yearBegan);
      final totalIssues = row.read(attachedDatabase.metronSeries.issueCount);
      final catCount = row.read(countCol) ?? 0;

      return SeriesSummaryDataRow(
        seriesId: seriesId,
        seriesName: (name != null && name.isNotEmpty)
            ? name
            : 'Series $seriesId',
        volume: vol,
        yearBegan: year,
        issueCount: totalIssues,
        categoryCount: catCount,
      );
    }).toList();
  }

  Future<List<LibraryItem>> getItems({
    String? ownershipStatus,
    bool? isRead,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = select(attachedDatabase.libraryItems);
    if (ownershipStatus != null) {
      query.where((t) => t.ownershipStatus.equals(ownershipStatus));
    }
    if (isRead != null) {
      query.where((t) => t.isRead.equals(isRead));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
    ]);
    query.limit(limit, offset: offset);
    return query.get();
  }

  Future<List<LibraryItem>> getItemsAfter({
    String? ownershipStatus,
    bool? isRead,
    required String cursorUpdatedAt,
    required String cursorId,
    int limit = 50,
  }) async {
    final query = select(attachedDatabase.libraryItems);
    if (ownershipStatus != null) {
      query.where((t) => t.ownershipStatus.equals(ownershipStatus));
    }
    if (isRead != null) {
      query.where((t) => t.isRead.equals(isRead));
    }
    query.where(
      (t) => (t.updatedAt.equals(cursorUpdatedAt) &
              t.id.isBiggerThan(Constant(cursorId))) |
          t.updatedAt.isBiggerThan(Constant(cursorUpdatedAt)),
    );
    query.orderBy([
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
    ]);
    query.limit(limit);
    return query.get();
  }

  Stream<List<LibraryItem>> watchByOwnershipStatus(String ownershipStatus) {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals(ownershipStatus))).watch();
  }

  Stream<List<LibraryItem>> watchByIsRead(bool isRead) {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.isRead.equals(isRead))).watch();
  }

  Future<List<LibraryItemStatusRow>> getStatusRows() async {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([
        attachedDatabase.libraryItems.metronIssueId,
        attachedDatabase.libraryItems.ownershipStatus,
        attachedDatabase.libraryItems.isRead,
        attachedDatabase.libraryItems.rating,
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        LibraryItemStatusRow(
          metronIssueId: row.read(
                attachedDatabase.libraryItems.metronIssueId,
              ) ??
              0,
          ownershipStatus: row.read(
                attachedDatabase.libraryItems.ownershipStatus,
              ) ??
              'notOwned',
          isRead: row.read(attachedDatabase.libraryItems.isRead) ?? false,
          rating: row.read(attachedDatabase.libraryItems.rating),
        ),
    ];
  }

  Stream<List<LibraryItemStatusRow>> watchStatusRows() {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([
        attachedDatabase.libraryItems.metronIssueId,
        attachedDatabase.libraryItems.ownershipStatus,
        attachedDatabase.libraryItems.isRead,
        attachedDatabase.libraryItems.rating,
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          LibraryItemStatusRow(
            metronIssueId: row.read(
                  attachedDatabase.libraryItems.metronIssueId,
                ) ??
                0,
            ownershipStatus: row.read(
                  attachedDatabase.libraryItems.ownershipStatus,
                ) ??
                'notOwned',
            isRead: row.read(attachedDatabase.libraryItems.isRead) ?? false,
            rating: row.read(attachedDatabase.libraryItems.rating),
          ),
      ],
    );
  }

  Future<int> getItemCount({String? ownershipStatus}) async {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([countAll()]);
    if (ownershipStatus != null) {
      query.where(
        attachedDatabase.libraryItems.ownershipStatus.equals(ownershipStatus),
      );
    }
    final result = await query.getSingle();
    return result.read(countAll()) as int;
  }

  Future<int> getOwnedCountBySeries(int metronSeriesId) async {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([countAll()])
      ..where(
        attachedDatabase.libraryItems.metronSeriesId.equals(metronSeriesId) &
            attachedDatabase.libraryItems.ownershipStatus.equals('owned'),
      );
    final result = await query.getSingle();
    return result.read(countAll()) as int;
  }

  Future<Map<int, int>> getOwnedCountsBySeries(List<int> seriesIds) async {
    if (seriesIds.isEmpty) return {};
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([
        attachedDatabase.libraryItems.metronSeriesId,
        countAll(),
      ])
      ..where(
        attachedDatabase.libraryItems.metronSeriesId.isIn(seriesIds) &
            attachedDatabase.libraryItems.ownershipStatus.equals('owned'),
      )
      ..groupBy([attachedDatabase.libraryItems.metronSeriesId]);
    final rows = await query.get();
    final counts = <int, int>{};
    for (final row in rows) {
      final seriesId =
          row.read(attachedDatabase.libraryItems.metronSeriesId) ?? 0;
      if (seriesId > 0) {
        counts[seriesId] = row.read(countAll()) as int;
      }
    }
    return counts;
  }

  Stream<List<LibraryItem>> watchAll() {
    return select(attachedDatabase.libraryItems).watch();
  }

  Future<Map<String, LibraryItem>> getItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<List<LibraryItem>> watchByIssueIds(List<int> metronIssueIds) {
    if (metronIssueIds.isEmpty) {
      return const Stream.empty();
    }
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronIssueId.isIn(metronIssueIds))).watch();
  }

  Stream<List<LibraryItem>> watchByIssueId(int metronIssueId) {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).watch();
  }

  Future<LibraryItem?> getByIssueId(int metronIssueId) async {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).getSingleOrNull();
  }

  Future<void> upsert(LibraryItemsCompanion entry) async {
    await transaction(() async {
      await into(attachedDatabase.libraryItems).insertOnConflictUpdate(entry);
      if (entry.id.present) {
        await attachedDatabase.syncMetaDao.deleteByKey(
          'delete:library_items:${entry.id.value}',
        );
      }
    });
  }

  Future<void> deleteById(String id) async {
    await transaction(() async {
      await (delete(
        attachedDatabase.libraryItems,
      )..where((t) => t.id.equals(id))).go();
      await attachedDatabase.syncMetaDao.set(
        'delete:library_items:$id',
        DateTime.now().toUtc().toIso8601String(),
      );
    });
  }

  Stream<List<LibraryItem>> watchCollected() {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals('owned'))).watch();
  }

  Stream<List<LibraryItem>> watchWishlist() {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals('wishlist'))).watch();
  }

  Future<List<int>> getOwnedIssueIds() async {
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals('owned'))).get();
    return rows.map((r) => r.metronIssueId).toList();
  }

  Future<List<int>> getWishlistedIssueIds() async {
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals('wishlist'))).get();
    return rows.map((r) => r.metronIssueId).toList();
  }

  Future<List<LibraryItem>> getBySeriesId(int metronSeriesId) async {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronSeriesId.equals(metronSeriesId))).get();
  }

  Future<Map<int, LibraryItem>> getByIssueIds(List<int> metronIssueIds) async {
    if (metronIssueIds.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronIssueId.isIn(metronIssueIds))).get();
    return {for (final r in rows) r.metronIssueId: r};
  }

  Future<void> batchUpdatePricePaid(Map<int, double> priceByIssueId) async {
    if (priceByIssueId.isEmpty) return;
    final issueIds = priceByIssueId.keys.toList();
    final existingMap = await getByIssueIds(issueIds);
    if (existingMap.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    final updates = <LibraryItemsCompanion>[];
    for (final entry in priceByIssueId.entries) {
      final existing = existingMap[entry.key];
      if (existing == null || existing.pricePaid != null) continue;
      updates.add(
        LibraryItemsCompanion(
          id: Value(existing.id),
          userId: Value(existing.userId),
          metronIssueId: Value(existing.metronIssueId),
          metronSeriesId: Value(existing.metronSeriesId),
          ownershipStatus: Value(existing.ownershipStatus),
          isRead: Value(existing.isRead),
          rating: Value(existing.rating),
          purchaseDate: Value(existing.purchaseDate),
          pricePaid: Value(entry.value),
          quantityOwned: Value(existing.quantityOwned),
          format: Value(existing.format),
          firstReadAt: Value(existing.firstReadAt),
          conditionGrade: Value(existing.conditionGrade),
          acquiredOn: Value(existing.acquiredOn),
          notes: Value(existing.notes),
          createdAt: Value(existing.createdAt),
          updatedAt: Value(now),
        ),
      );
    }
    if (updates.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.libraryItems, updates);
    });
  }

  Stream<List<LibraryItem>> watchBySeriesId(int metronSeriesId) {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronSeriesId.equals(metronSeriesId))).watch();
  }

  Future<void> batchUpsert(List<LibraryItemsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.libraryItems, entries);
    });
    for (final entry in entries) {
      if (entry.id.present) {
        await attachedDatabase.syncMetaDao.deleteByKey(
          'delete:library_items:${entry.id.value}',
        );
      }
    }
  }

  Future<void> batchDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await transaction(() async {
      await (delete(
        attachedDatabase.libraryItems,
      )..where((t) => t.id.isIn(ids))).go();
      await batch((b) {
        b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
          for (final id in ids)
            SyncMetaCompanion.insert(
              key: 'delete:library_items:$id',
              value: now,
            ),
        ]);
      });
    });
  }

  Future<void> batchDeleteBySeriesId(int metronSeriesId) async {
    await transaction(() async {
      final items = await getBySeriesId(metronSeriesId);
      if (items.isEmpty) return;
      final ids = items.map((item) => item.id).toList();
      final now = DateTime.now().toUtc().toIso8601String();
      await (delete(
        attachedDatabase.libraryItems,
      )..where((t) => t.id.isIn(ids))).go();
      await batch((b) {
        b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
          for (final id in ids)
            SyncMetaCompanion.insert(
              key: 'delete:library_items:$id',
              value: now,
            ),
        ]);
      });
    });
  }

  Future<void> insertReadLog(LibraryReadLogsCompanion entry) async {
    await into(attachedDatabase.libraryReadLogs).insert(entry);
  }

  Stream<List<LibraryReadLog>> watchReadLogsByIssueId(int metronIssueId) {
    final itemId = 'lib-$metronIssueId';
    return (select(
      attachedDatabase.libraryReadLogs,
    )..where((t) => t.collectionItemId.equals(itemId))).watch();
  }
}
