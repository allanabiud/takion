import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class ReadingListDao extends DatabaseAccessor<AppDatabase> {
  ReadingListDao(super.db);

  Stream<List<ReadingList>> watchAll() {
    return (select(
      attachedDatabase.readingLists,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Stream<ReadingList?> watchById(String id) {
    return (select(
      attachedDatabase.readingLists,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<ReadingList?> getById(String id) async {
    return (select(
      attachedDatabase.readingLists,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertList(ReadingListsCompanion entry) async {
    await into(attachedDatabase.readingLists).insertOnConflictUpdate(entry);
  }

  Future<void> upsertItems(List<ReadingListItemsCompanion> entries) async {
    if (entries.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    final existingIds = (await (select(attachedDatabase.readingListItems)
          ..where((t) => t.id.isIn(entries.map((e) => e.id.value)))
          ..limit(entries.length))
        .get())
        .map((r) => r.id)
        .toSet();

    final stamped = entries.map((e) {
      final isNew = !existingIds.contains(e.id.value);
      return e.copyWith(
        updatedAt: Value(now),
        createdAt: isNew
            ? Value(e.createdAt.present ? e.createdAt.value : now)
            : e.createdAt,
      );
    }).toList();

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        attachedDatabase.readingListItems,
        stamped,
      );
    });
  }

  Future<void> deleteById(String id) async {
    await transaction(() async {
      await (delete(
        attachedDatabase.readingLists,
      )..where((t) => t.id.equals(id))).go();
      await attachedDatabase.syncMetaDao.set(
        'delete:reading_lists:$id',
        DateTime.now().toUtc().toIso8601String(),
      );

      final items = await (select(
        attachedDatabase.readingListItems,
      )..where((t) => t.listId.equals(id))).get();
      for (final item in items) {
        await attachedDatabase.syncMetaDao.set(
          'delete:reading_list_items:${item.id}',
          DateTime.now().toUtc().toIso8601String(),
        );
      }

      await (delete(
        attachedDatabase.readingListItems,
      )..where((t) => t.listId.equals(id))).go();
    });
  }
}
