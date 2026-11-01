import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class LibraryItemStatusRow {
  const LibraryItemStatusRow({
    required this.metronIssueId,
    required this.ownershipStatus,
    required this.isRead,
    required this.rating,
    this.syncStatus = "synced",
  });

  final int metronIssueId;
  final String ownershipStatus;
  final bool isRead;
  final int? rating;
  final String syncStatus;
}

class HydratedLibraryItemRow {
  const HydratedLibraryItemRow({
    required this.libraryItem,
    this.issue,
    this.series,
  });

  final LibraryItem libraryItem;
  final MetronIssue? issue;
  final MetronSery? series;
}

class SeriesSummaryItem {
  const SeriesSummaryItem({
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.issueCount,
    this.computedCoverUrl,
    required this.ownedCount,
    required this.readCount,
    this.isSubscribed = false,
  });

  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final int? issueCount;
  final String? computedCoverUrl;
  final int ownedCount;
  final int readCount;
  final bool isSubscribed;
}

class SeriesSummaryDataRow {
  const SeriesSummaryDataRow({
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.issueCount,
    this.computedCoverUrl,
    required this.categoryCount,
  });

  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final int? issueCount;
  final String? computedCoverUrl;
  final int categoryCount;
}

class LibraryItemDao extends DatabaseAccessor<AppDatabase> {
  LibraryItemDao(super.db);

  Stream<List<SeriesSummaryItem>> watchSeriesSummaries({
    String? ownershipStatus,
    bool? isRead,
  }) {
    final ownedCountCol = attachedDatabase.libraryItems.id.count(
      filter: attachedDatabase.libraryItems.ownershipStatus.equals("owned"),
    );
    final readCountCol = attachedDatabase.libraryItems.id.count(
      filter: attachedDatabase.libraryItems.isRead.equals(true),
    );
    final subCountCol = attachedDatabase.seriesSubscriptions.id.count(
      filter: attachedDatabase.seriesSubscriptions.isActive.equals(true),
    );

    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([
        attachedDatabase.libraryItems.metronSeriesId,
        ownedCountCol,
        readCountCol,
        subCountCol,
        attachedDatabase.metronSeries.name,
        attachedDatabase.metronSeries.volume,
        attachedDatabase.metronSeries.yearBegan,
        attachedDatabase.metronSeries.issueCount,
        attachedDatabase.metronSeries.computedCoverUrl,
      ])
      ..join([
        leftOuterJoin(
          attachedDatabase.metronSeries,
          attachedDatabase.metronSeries.id.equalsExp(
            attachedDatabase.libraryItems.metronSeriesId,
          ),
        ),
        leftOuterJoin(
          attachedDatabase.seriesSubscriptions,
          attachedDatabase.seriesSubscriptions.metronSeriesId.equalsExp(
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

    query.where(
      attachedDatabase.libraryItems.metronSeriesId.isBiggerThanValue(0),
    );
    query.groupBy([attachedDatabase.libraryItems.metronSeriesId]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final seriesId =
            row.read(attachedDatabase.libraryItems.metronSeriesId) ?? 0;
        final name = row.read(attachedDatabase.metronSeries.name);
        final vol = row.read(attachedDatabase.metronSeries.volume);
        final year = row.read(attachedDatabase.metronSeries.yearBegan);
        final totalIssues = row.read(attachedDatabase.metronSeries.issueCount);
        final coverUrl = row.read(
          attachedDatabase.metronSeries.computedCoverUrl,
        );
        final ownedCount = row.read(ownedCountCol) ?? 0;
        final readCount = row.read(readCountCol) ?? 0;
        final subCount = row.read(subCountCol) ?? 0;

        return SeriesSummaryItem(
          seriesId: seriesId,
          seriesName: (name != null && name.isNotEmpty)
              ? name
              : "Series $seriesId",
          volume: vol,
          yearBegan: year,
          issueCount: totalIssues,
          computedCoverUrl: coverUrl,
          ownedCount: ownedCount,
          readCount: readCount,
          isSubscribed: subCount > 0,
        );
      }).toList();
    });
  }

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
        attachedDatabase.metronSeries.computedCoverUrl,
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
      query.where(
        attachedDatabase.libraryItems.rating.isNull() |
            attachedDatabase.libraryItems.rating.isSmallerOrEqualValue(0),
      );
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
      final coverUrl = row.read(attachedDatabase.metronSeries.computedCoverUrl);
      final catCount = row.read(countCol) ?? 0;

      return SeriesSummaryDataRow(
        seriesId: seriesId,
        seriesName: (name != null && name.isNotEmpty)
            ? name
            : "Series $seriesId",
        volume: vol,
        yearBegan: year,
        issueCount: totalIssues,
        computedCoverUrl: coverUrl,
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
      (t) =>
          (t.updatedAt.equals(cursorUpdatedAt) &
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

  Stream<List<HydratedLibraryItemRow>> watchHydratedItems({
    String? ownershipStatus,
    bool? isRead,
    bool? isUnrated,
  }) {
    final query = select(attachedDatabase.libraryItems).join([
      leftOuterJoin(
        attachedDatabase.metronIssues,
        attachedDatabase.metronIssues.id.equalsExp(
          attachedDatabase.libraryItems.metronIssueId,
        ),
      ),
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
      query.where(
        attachedDatabase.libraryItems.rating.isNull() |
            attachedDatabase.libraryItems.rating.isSmallerOrEqualValue(0),
      );
    }

    query.orderBy([
      OrderingTerm(
        expression: attachedDatabase.libraryItems.updatedAt,
        mode: OrderingMode.desc,
      ),
      OrderingTerm(
        expression: attachedDatabase.libraryItems.id,
        mode: OrderingMode.desc,
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return HydratedLibraryItemRow(
          libraryItem: row.readTable(attachedDatabase.libraryItems),
          issue: row.readTableOrNull(attachedDatabase.metronIssues),
          series: row.readTableOrNull(attachedDatabase.metronSeries),
        );
      }).toList();
    });
  }

  Future<List<HydratedLibraryItemRow>> getHydratedItems({
    String? ownershipStatus,
    bool? isRead,
    bool? isUnrated,
    int? limit,
    int? offset,
  }) async {
    final query = select(attachedDatabase.libraryItems).join([
      leftOuterJoin(
        attachedDatabase.metronIssues,
        attachedDatabase.metronIssues.id.equalsExp(
          attachedDatabase.libraryItems.metronIssueId,
        ),
      ),
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
      query.where(
        attachedDatabase.libraryItems.rating.isNull() |
            attachedDatabase.libraryItems.rating.isSmallerOrEqualValue(0),
      );
    }

    query.orderBy([
      OrderingTerm(
        expression: attachedDatabase.libraryItems.updatedAt,
        mode: OrderingMode.desc,
      ),
      OrderingTerm(
        expression: attachedDatabase.libraryItems.id,
        mode: OrderingMode.desc,
      ),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final rows = await query.get();
    return rows.map((row) {
      return HydratedLibraryItemRow(
        libraryItem: row.readTable(attachedDatabase.libraryItems),
        issue: row.readTableOrNull(attachedDatabase.metronIssues),
        series: row.readTableOrNull(attachedDatabase.metronSeries),
      );
    }).toList();
  }

  Future<List<LibraryItemStatusRow>> getStatusRows() async {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..where(attachedDatabase.libraryItems.deletedAt.isNull())
      ..addColumns([
        attachedDatabase.libraryItems.metronIssueId,
        attachedDatabase.libraryItems.ownershipStatus,
        attachedDatabase.libraryItems.isRead,
        attachedDatabase.libraryItems.rating,
        attachedDatabase.libraryItems.syncStatus,
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        LibraryItemStatusRow(
          metronIssueId:
              row.read(attachedDatabase.libraryItems.metronIssueId) ?? 0,
          ownershipStatus:
              row.read(attachedDatabase.libraryItems.ownershipStatus) ??
              "notOwned",
          isRead: row.read(attachedDatabase.libraryItems.isRead) ?? false,
          rating: row.read(attachedDatabase.libraryItems.rating),
          syncStatus:
              row.read(attachedDatabase.libraryItems.syncStatus) ?? "synced",
        ),
    ];
  }

  Stream<List<LibraryItemStatusRow>> watchStatusRows() {
    final query = selectOnly(attachedDatabase.libraryItems)
      ..where(attachedDatabase.libraryItems.deletedAt.isNull())
      ..addColumns([
        attachedDatabase.libraryItems.metronIssueId,
        attachedDatabase.libraryItems.ownershipStatus,
        attachedDatabase.libraryItems.isRead,
        attachedDatabase.libraryItems.rating,
        attachedDatabase.libraryItems.syncStatus,
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          LibraryItemStatusRow(
            metronIssueId:
                row.read(attachedDatabase.libraryItems.metronIssueId) ?? 0,
            ownershipStatus:
                row.read(attachedDatabase.libraryItems.ownershipStatus) ??
                "notOwned",
            isRead: row.read(attachedDatabase.libraryItems.isRead) ?? false,
            rating: row.read(attachedDatabase.libraryItems.rating),
            syncStatus:
                row.read(attachedDatabase.libraryItems.syncStatus) ?? "synced",
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
            attachedDatabase.libraryItems.ownershipStatus.equals("owned"),
      );
    final result = await query.getSingle();
    return result.read(countAll()) as int;
  }

  Future<Map<int, int>> getOwnedCountsBySeries(List<int> seriesIds) async {
    if (seriesIds.isEmpty) return {};
    final query = selectOnly(attachedDatabase.libraryItems)
      ..addColumns([attachedDatabase.libraryItems.metronSeriesId, countAll()])
      ..where(
        attachedDatabase.libraryItems.metronSeriesId.isIn(seriesIds) &
            attachedDatabase.libraryItems.ownershipStatus.equals("owned"),
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

  Future<LibraryItem?> getById(String id) => (select(
    attachedDatabase.libraryItems,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<LibraryItem> requireById(String id) async {
    final item = await getById(id);
    if (item == null) {
      throw StateError("Library item $id not found");
    }
    return item;
  }

  Future<void> applyOptimisticPatch(
    String id, {
    Value<bool>? isRead,
    Value<int?>? rating,
    Value<String>? syncStatus,
    Value<String?>? notes,
    Value<String>? format,
    Value<String?>? conditionGrade,
    Value<double?>? pricePaid,
    Value<String?>? purchaseDate,
    Value<String?>? acquiredOn,
    Value<int>? quantityOwned,
    Value<String>? ownershipStatus,
    Value<String?>? remoteModified,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (update(
      attachedDatabase.libraryItems,
    )..where((t) => t.id.equals(id))).write(
      LibraryItemsCompanion(
        isRead: isRead ?? const Value.absent(),
        rating: rating ?? const Value.absent(),
        syncStatus: syncStatus ?? const Value.absent(),
        notes: notes ?? const Value.absent(),
        format: format ?? const Value.absent(),
        conditionGrade: conditionGrade ?? const Value.absent(),
        pricePaid: pricePaid ?? const Value.absent(),
        purchaseDate: purchaseDate ?? const Value.absent(),
        acquiredOn: acquiredOn ?? const Value.absent(),
        quantityOwned: quantityOwned ?? const Value.absent(),
        ownershipStatus: ownershipStatus ?? const Value.absent(),
        remoteModified: remoteModified ?? const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> applyOptimisticDelete(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (update(
      attachedDatabase.libraryItems,
    )..where((t) => t.id.equals(id))).write(
      LibraryItemsCompanion(
        deletedAt: Value(now),
        syncStatus: const Value("pending"),
        updatedAt: Value(now),
      ),
    );
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
          "delete:library_items:${entry.id.value}",
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
        "delete:library_items:$id",
        DateTime.now().toUtc().toIso8601String(),
      );
    });
  }

  Future<void> deleteByIssueId(int metronIssueId) async {
    final item = await getByIssueId(metronIssueId);
    if (item != null) {
      await deleteById(item.id);
    }
  }

  /// Removes local synced library items that were missing during a full collection scan [scanId].
  /// Preserves pending or locally modified rows.
  Future<int> reconcileMissingFromScan(String scanId) async {
    final missing =
        await (select(attachedDatabase.libraryItems)..where(
              (t) =>
                  t.syncStatus.equals("synced") &
                  t.deletedAt.isNull() &
                  (t.lastSeenScanId.isNull() |
                      t.lastSeenScanId.equals(scanId).not()),
            ))
            .get();

    for (final item in missing) {
      await deleteById(item.id);
    }
    return missing.length;
  }

  Stream<List<LibraryItem>> watchCollected() {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals("owned"))).watch();
  }

  Stream<List<LibraryItem>> watchWishlist() {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals("wishlist"))).watch();
  }

  Future<List<int>> getOwnedIssueIds() async {
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals("owned"))).get();
    return rows.map((r) => r.metronIssueId).toList();
  }

  Future<List<int>> getWishlistedIssueIds() async {
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.ownershipStatus.equals("wishlist"))).get();
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
          "delete:library_items:${entry.id.value}",
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
              key: "delete:library_items:$id",
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
              key: "delete:library_items:$id",
              value: now,
            ),
        ]);
      });
    });
  }

  Future<List<LibraryItem>> getUnsyncedItems() async {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.syncStatus.isNotValue("synced"))).get();
  }

  Stream<List<LibraryItem>> watchUnsyncedItems() {
    return (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.syncStatus.isNotValue("synced"))).watch();
  }

  Future<LibraryItem?> getByMetronCollectionId(int metronCollectionId) async {
    return (select(attachedDatabase.libraryItems)
          ..where((t) => t.metronCollectionId.equals(metronCollectionId)))
        .getSingleOrNull();
  }

  Future<Map<int, LibraryItem>> getByMetronCollectionIds(
    List<int> metronCollectionIds,
  ) async {
    if (metronCollectionIds.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.libraryItems,
    )..where((t) => t.metronCollectionId.isIn(metronCollectionIds))).get();
    return {
      for (final r in rows)
        if (r.metronCollectionId != null) r.metronCollectionId!: r,
    };
  }

  Future<void> updateSyncStatus(
    String id,
    String syncStatus, {
    int? metronCollectionId,
  }) async {
    await (update(
      attachedDatabase.libraryItems,
    )..where((t) => t.id.equals(id))).write(
      LibraryItemsCompanion(
        syncStatus: Value(syncStatus),
        metronCollectionId: metronCollectionId != null
            ? Value(metronCollectionId)
            : const Value.absent(),
      ),
    );
  }

  Future<void> insertReadLog(LibraryReadLogsCompanion entry) async {
    await into(attachedDatabase.libraryReadLogs).insert(entry);
  }

  Stream<List<LibraryReadLog>> watchReadLogsByIssueId(int metronIssueId) {
    final itemId = "lib-$metronIssueId";
    return (select(
      attachedDatabase.libraryReadLogs,
    )..where((t) => t.collectionItemId.equals(itemId))).watch();
  }

  // ---------------------------------------------------------------------------
  // Aggregate Stats Methods
  // ---------------------------------------------------------------------------

  Stream<int> watchOwnedCount() {
    final col = countAll(
      filter: attachedDatabase.libraryItems.ownershipStatus.equals("owned"),
    );
    return (selectOnly(attachedDatabase.libraryItems)..addColumns([col]))
        .watch()
        .map((rows) => rows.isNotEmpty ? (rows.first.read(col) ?? 0) : 0);
  }

  Stream<int> watchOwnedQuantitySum() {
    final col = attachedDatabase.libraryItems.quantityOwned.sum(
      filter: attachedDatabase.libraryItems.ownershipStatus.equals("owned"),
    );
    return (selectOnly(attachedDatabase.libraryItems)..addColumns([col]))
        .watch()
        .map((rows) => rows.isNotEmpty ? (rows.first.read(col) ?? 0) : 0);
  }

  Stream<int> watchReadsCount({String? startDate}) {
    if (startDate != null) {
      return customSelect(
        "SELECT COUNT(*) AS cnt FROM library_items "
        "WHERE is_read = 1 AND first_read_at >= ?",
        variables: [Variable.withString(startDate)],
        readsFrom: {attachedDatabase.libraryItems},
      ).watch().map(
        (rows) => rows.isNotEmpty ? rows.first.read<int>("cnt") : 0,
      );
    }
    return customSelect(
      "SELECT COUNT(*) AS cnt FROM library_items WHERE is_read = 1",
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) => rows.isNotEmpty ? rows.first.read<int>("cnt") : 0);
  }

  Stream<double> watchAverageRating() {
    return customSelect(
      "SELECT AVG(rating) AS avg_rating FROM library_items "
      "WHERE rating IS NOT NULL AND rating > 0 AND is_read = 1",
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      if (rows.isEmpty) return 0.0;
      return rows.first.read<double>("avg_rating");
    });
  }

  Stream<({String name, int yearBegan, int count})?> watchMostReadSeries() {
    return customSelect(
      "SELECT ms.name, ms.year_began, COUNT(*) AS cnt "
      "FROM library_items li "
      "INNER JOIN metron_series ms ON ms.id = li.metron_series_id "
      "WHERE li.is_read = 1 AND li.metron_series_id > 0 "
      "GROUP BY li.metron_series_id "
      "ORDER BY cnt DESC LIMIT 1",
      readsFrom: {attachedDatabase.libraryItems, attachedDatabase.metronSeries},
    ).watch().map((rows) {
      if (rows.isEmpty) return null;
      return (
        name: rows.first.read<String>("name"),
        yearBegan: rows.first.read<int>("year_began"),
        count: rows.first.read<int>("cnt"),
      );
    });
  }

  Stream<List<({String label, int count, DateTime date})>>
  watchReadingTrendsByDay(String startDate, String endDate) {
    return customSelect(
      "SELECT substr(first_read_at, 1, 10) AS day, COUNT(*) AS cnt "
      "FROM library_items "
      "WHERE is_read = 1 AND first_read_at IS NOT NULL "
      "AND first_read_at >= ? AND first_read_at < ? "
      "GROUP BY day ORDER BY day",
      variables: [Variable.withString(startDate), Variable.withString(endDate)],
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows.map((r) {
        final day = r.read<String>("day");
        return (
          label: day.length >= 5 ? day.substring(5) : day,
          count: r.read<int>("cnt"),
          date: DateTime.parse(day),
        );
      }).toList();
    });
  }

  Stream<List<({String label, int count, DateTime date})>>
  watchReadingTrendsByMonth(int year) {
    final start = "$year-01-01";
    final end = "${year + 1}-01-01";
    return customSelect(
      "SELECT substr(first_read_at, 1, 7) AS month, COUNT(*) AS cnt "
      "FROM library_items "
      "WHERE is_read = 1 AND first_read_at IS NOT NULL "
      "AND first_read_at >= ? AND first_read_at < ? "
      "GROUP BY month ORDER BY month",
      variables: [Variable.withString(start), Variable.withString(end)],
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows.map((r) {
        final month = r.read<String>("month");
        return (
          label: month.length >= 5 ? month.substring(5) : month,
          count: r.read<int>("cnt"),
          date: DateTime.parse("$month-01"),
        );
      }).toList();
    });
  }

  Stream<List<({String label, int count, DateTime date})>>
  watchReadingTrendsAllTime() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5, 1);
    final startStr =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-01";
    final endStr =
        "${now.year}-${(now.month + 1).toString().padLeft(2, '0')}-01";
    return customSelect(
      "SELECT substr(first_read_at, 1, 7) AS month, COUNT(*) AS cnt "
      "FROM library_items "
      "WHERE is_read = 1 AND first_read_at IS NOT NULL "
      "AND first_read_at >= ? AND first_read_at < ? "
      "GROUP BY month ORDER BY month",
      variables: [Variable.withString(startStr), Variable.withString(endStr)],
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows.map((r) {
        final month = r.read<String>("month");
        return (
          label: month.length >= 5 ? month.substring(5) : month,
          count: r.read<int>("cnt"),
          date: DateTime.parse("$month-01"),
        );
      }).toList();
    });
  }

  Stream<List<LibraryItem>> watchRecentlyRead({int limit = 5}) {
    return (select(attachedDatabase.libraryItems)
          ..where((t) => t.isRead.equals(true) & t.firstReadAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.firstReadAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<List<DateTime>> watchAllReadDates() {
    return customSelect(
      "SELECT first_read_at FROM library_items "
      "WHERE is_read = 1 AND first_read_at IS NOT NULL",
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows
          .map((r) => DateTime.parse(r.read<String>("first_read_at")).toLocal())
          .toList();
    });
  }

  Stream<List<({String format, int count})>> watchFormatBreakdown() {
    final col = attachedDatabase.libraryItems.id.count();
    return (selectOnly(attachedDatabase.libraryItems)
          ..addColumns([attachedDatabase.libraryItems.format, col])
          ..where(attachedDatabase.libraryItems.ownershipStatus.equals("owned"))
          ..groupBy([attachedDatabase.libraryItems.format]))
        .watch()
        .map((rows) {
          return rows
              .map(
                (r) => (
                  format:
                      r.read(attachedDatabase.libraryItems.format) ?? "UNKNOWN",
                  count: r.read(col) ?? 0,
                ),
              )
              .toList();
        });
  }

  Stream<double> watchTotalSpending({String? startDate, String? endDate}) {
    final conditions = <String>["price_paid IS NOT NULL"];
    final vars = <Variable>[];
    if (startDate != null) {
      conditions.add("first_read_at >= ?");
      vars.add(Variable.withString(startDate));
    }
    if (endDate != null) {
      conditions.add("first_read_at < ?");
      vars.add(Variable.withString(endDate));
    }
    final where = conditions.join(" AND ");
    return customSelect(
      "SELECT COALESCE(SUM(price_paid * quantity_owned), 0.0) AS total "
      "FROM library_items WHERE $where",
      variables: vars,
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      if (rows.isEmpty) return 0.0;
      return rows.first.read<double>("total");
    });
  }

  Stream<List<({String label, double amount, DateTime date})>>
  watchSpendingTrendsByDay(String startDate, String endDate) {
    return customSelect(
      "SELECT substr(first_read_at, 1, 10) AS day, "
      "COALESCE(SUM(price_paid * quantity_owned), 0.0) AS amount "
      "FROM library_items "
      "WHERE price_paid IS NOT NULL "
      "AND first_read_at >= ? AND first_read_at < ? "
      "GROUP BY day ORDER BY day",
      variables: [Variable.withString(startDate), Variable.withString(endDate)],
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows.map((r) {
        final day = r.read<String>("day");
        return (
          label: day.length >= 5 ? day.substring(5) : day,
          amount: r.read<double>("amount"),
          date: DateTime.parse(day),
        );
      }).toList();
    });
  }

  Stream<List<({String label, double amount, DateTime date})>>
  watchSpendingTrendsByMonth(
    int year, {
    int startMonth = 1,
    int endMonth = 12,
  }) {
    final start = "$year-${startMonth.toString().padLeft(2, '0')}-01";
    final endMonthStr = endMonth >= 12 ? 1 : endMonth + 1;
    final endYear = endMonth >= 12 ? year + 1 : year;
    final end = "$endYear-${endMonthStr.toString().padLeft(2, '0')}-01";
    return customSelect(
      "SELECT substr(first_read_at, 1, 7) AS month, "
      "COALESCE(SUM(price_paid * quantity_owned), 0.0) AS amount "
      "FROM library_items "
      "WHERE price_paid IS NOT NULL "
      "AND first_read_at >= ? AND first_read_at < ? "
      "GROUP BY month ORDER BY month",
      variables: [Variable.withString(start), Variable.withString(end)],
      readsFrom: {attachedDatabase.libraryItems},
    ).watch().map((rows) {
      return rows.map((r) {
        final month = r.read<String>("month");
        return (
          label: month.length >= 5 ? month.substring(5) : month,
          amount: r.read<double>("amount"),
          date: DateTime.parse("$month-01"),
        );
      }).toList();
    });
  }
}
