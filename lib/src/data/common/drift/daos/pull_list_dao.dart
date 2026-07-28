import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class PullListDao extends DatabaseAccessor<AppDatabase> {
  PullListDao(super.db);

  Future<List<PullListEntry>> getEntries({
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(attachedDatabase.pullListEntries);
    if (fromDate != null) {
      final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
      query.where(
        (t) =>
            t.releaseDate.isBiggerOrEqualValue(from) | t.releaseDate.isNull(),
      );
    }
    if (toDate != null) {
      final to = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
      query.where(
        (t) => t.releaseDate.isSmallerOrEqualValue(to) | t.releaseDate.isNull(),
      );
    }
    if (status != null) {
      query.where((t) => t.entryStatus.equals(status));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.releaseDate, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    query.limit(limit, offset: offset);
    return query.get();
  }

  Future<void> batchUpsert(List<PullListEntriesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.pullListEntries, entries);
    });
  }

  Stream<List<PullListEntry>> watchAll() {
    return select(attachedDatabase.pullListEntries).watch();
  }

  Stream<List<PullListEntry>> watchUpcoming() {
    final now = DateTime.now().toUtc();
    return (select(
      attachedDatabase.pullListEntries,
    )..where((t) => t.releaseDate.isBiggerThan(Constant(now)))).watch();
  }

  Stream<PullListEntry?> watchByIssueId(int metronIssueId) {
    return (select(
      attachedDatabase.pullListEntries,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).watchSingleOrNull();
  }

  Future<PullListEntry?> getByIssueId(int metronIssueId) async {
    return (select(
      attachedDatabase.pullListEntries,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).getSingleOrNull();
  }

  Future<void> upsert(PullListEntriesCompanion entry) async {
    await into(attachedDatabase.pullListEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteBySeriesId(int metronSeriesId) async {
    await transaction(() async {
      final entries = await (select(
        attachedDatabase.pullListEntries,
      )..where((t) => t.metronSeriesId.equals(metronSeriesId))).get();
      if (entries.isEmpty) return;
      final now = DateTime.now().toUtc().toIso8601String();
      await batch((b) {
        for (final entry in entries) {
          b.deleteWhere(
            attachedDatabase.pullListEntries,
            (t) => t.id.equals(entry.id),
          );
          b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
            SyncMetaCompanion.insert(
              key: 'delete:pull_list_entries:${entry.id}',
              value: now,
            ),
          ]);
        }
      });
    });
  }

  Future<void> deleteByIssueId(int metronIssueId) async {
    await transaction(() async {
      final existing = await getByIssueId(metronIssueId);
      if (existing != null) {
        await (delete(
          attachedDatabase.pullListEntries,
        )..where((t) => t.metronIssueId.equals(metronIssueId))).go();
        await attachedDatabase.syncMetaDao.set(
          'delete:pull_list_entries:${existing.id}',
          DateTime.now().toUtc().toIso8601String(),
        );
      }
    });
  }
}
