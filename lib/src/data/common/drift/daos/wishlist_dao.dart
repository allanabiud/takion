import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";

part "wishlist_dao.g.dart";

@DriftAccessor(tables: [WishlistItems])
class WishlistDao extends DatabaseAccessor<AppDatabase> with _$WishlistDaoMixin {
  WishlistDao(super.db);

  Stream<List<WishlistItem>> watchAll() {
    return (select(wishlistItems)
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.addedOn, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<WishlistItem>> watchBySeries(int seriesId) {
    return (select(wishlistItems)
          ..where((t) => t.seriesId.equals(seriesId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.addedOn, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<WishlistItem?> watchItem(int id) {
    return (select(wishlistItems)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<List<WishlistItem>> getAll() {
    return (select(wishlistItems)
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.addedOn, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<WishlistItem?> getById(int id) {
    return (select(wishlistItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<WishlistItem?> getByIssueId(int issueId) {
    return (select(wishlistItems)..where((t) => t.issueId.equals(issueId)))
        .getSingleOrNull();
  }

  Future<List<WishlistItem>> getByIssueIds(List<int> issueIds) {
    if (issueIds.isEmpty) return Future.value([]);
    return (select(wishlistItems)..where((t) => t.issueId.isIn(issueIds)))
        .get();
  }

  Future<int> getItemCount() async {
    final countExp = wishlistItems.id.count();
    final query = selectOnly(wishlistItems)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  Future<List<WishlistItem>> getBySyncStatus(String syncStatus) {
    return (select(wishlistItems)..where((t) => t.syncStatus.equals(syncStatus)))
        .get();
  }

  Stream<Map<int, String>> watchSyncStatusSummaryBySeries() {
    return watchAll().map((items) {
      final result = <int, String>{};
      for (final item in items) {
        final seriesId = item.seriesId;
        final status = item.syncStatus;
        final existing = result[seriesId];
        if (existing == null) {
          result[seriesId] = status;
        } else if (existing == "synced" && status != "synced") {
          result[seriesId] = status;
        } else if (existing == "pending" && status == "failed") {
          result[seriesId] = status;
        }
      }
      return result;
    });
  }

  Future<void> upsert(WishlistItemsCompanion item) {
    return into(wishlistItems).insertOnConflictUpdate(item);
  }

  Future<void> batchUpsert(List<WishlistItemsCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(wishlistItems, items);
    });
  }

  Future<int> deleteById(int id) {
    return (delete(wishlistItems)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteByIssueId(int issueId) {
    return (delete(wishlistItems)..where((t) => t.issueId.equals(issueId))).go();
  }

  Future<int> batchDeleteByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value(0);
    return (delete(wishlistItems)..where((t) => t.id.isIn(ids))).go();
  }

  Future<int> batchDeleteByIssueIds(List<int> issueIds) {
    if (issueIds.isEmpty) return Future.value(0);
    return (delete(wishlistItems)..where((t) => t.issueId.isIn(issueIds))).go();
  }

  Future<int> clearAll() {
    return delete(wishlistItems).go();
  }

  Future<void> updateSyncStatusByIssueId(int issueId, String syncStatus) async {
    await (update(wishlistItems)..where((t) => t.issueId.equals(issueId))).write(
      WishlistItemsCompanion(
        syncStatus: Value(syncStatus),
      ),
    );
  }

  Future<List<SeriesSummaryDataRow>> getSeriesSummaries() async {
    final countCol = attachedDatabase.wishlistItems.id.count();
    final query = selectOnly(attachedDatabase.wishlistItems)
      ..addColumns([
        attachedDatabase.wishlistItems.seriesId,
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
            attachedDatabase.wishlistItems.seriesId,
          ),
        ),
      ]);

    query.where(attachedDatabase.wishlistItems.seriesId.isBiggerThanValue(0));
    query.groupBy([attachedDatabase.wishlistItems.seriesId]);

    final rows = await query.get();

    return rows.map((row) {
      final seriesId =
          row.read(attachedDatabase.wishlistItems.seriesId) ?? 0;
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
}
