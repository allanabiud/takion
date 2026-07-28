import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class LibraryItemDao extends DatabaseAccessor<AppDatabase> {
  LibraryItemDao(super.db);

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

  Stream<List<LibraryItem>> watchAll() {
    return select(attachedDatabase.libraryItems).watch();
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
    await into(attachedDatabase.libraryItems).insertOnConflictUpdate(entry);
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
  }

  Future<void> batchDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await batch((b) {
      for (final id in ids) {
        b.deleteWhere(attachedDatabase.libraryItems, (t) => t.id.equals(id));
        b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
          SyncMetaCompanion.insert(key: 'delete:library_items:$id', value: now),
        ]);
      }
    });
  }

  Future<void> batchDeleteBySeriesId(int metronSeriesId) async {
    await transaction(() async {
      final items = await getBySeriesId(metronSeriesId);
      for (final item in items) {
        await (delete(
          attachedDatabase.libraryItems,
        )..where((t) => t.id.equals(item.id))).go();
        await attachedDatabase.syncMetaDao.set(
          'delete:library_items:${item.id}',
          DateTime.now().toUtc().toIso8601String(),
        );
      }
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
