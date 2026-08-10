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
    for (final entry in entries) {
      if (entry.id.present) {
        await attachedDatabase.syncMetaDao.deleteByKey(
          'delete:pull_list_entries:${entry.id.value}',
        );
      }
    }
  }

  /// Upserts pull list entries originating from an active subscription.
  /// Preserves the existing status and createdAt of entries that already exist.
  Future<void> upsertSubscriptionEntries(
    List<({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>
    entries,
  ) async {
    if (entries.isEmpty) return;
    const localUserId = 'local-user';
    final now = DateTime.now().toUtc();
    final companions = <PullListEntriesCompanion>[];

    for (final item in entries) {
      final existing = await getByIssueId(item.metronIssueId);
      final id = existing?.id ?? 'pull-${item.metronIssueId}';
      final createdAt = existing != null
          ? existing.createdAt
          : now.toIso8601String();
      final status = existing != null ? existing.entryStatus : 'upcoming';

      companions.add(
        PullListEntriesCompanion(
          id: Value(id),
          userId: const Value(localUserId),
          metronIssueId: Value(item.metronIssueId),
          metronSeriesId: Value(item.metronSeriesId),
          entryStatus: Value(status),
          releaseDate: Value(item.releaseDate),
          source: const Value('subscription'),
          generatedAt: Value(now.toIso8601String()),
          createdAt: Value(createdAt),
          updatedAt: Value(now.toIso8601String()),
        ),
      );
    }

    await batchUpsert(companions);
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
    await transaction(() async {
      await into(
        attachedDatabase.pullListEntries,
      ).insertOnConflictUpdate(entry);
      if (entry.id.present) {
        await attachedDatabase.syncMetaDao.deleteByKey(
          'delete:pull_list_entries:${entry.id.value}',
        );
      }
    });
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
