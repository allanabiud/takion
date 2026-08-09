import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class ActivityDao extends DatabaseAccessor<AppDatabase> {
  ActivityDao(super.db);

  Stream<List<ActivityEvent>> watchAll() {
    return (select(
      attachedDatabase.activityEvents,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  }

  Stream<List<ActivityEvent>> watchRecent({int limit = 100}) {
    return (select(attachedDatabase.activityEvents)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch();
  }

  Stream<List<ActivityEvent>> watchBySeriesId(int seriesId) {
    return (select(attachedDatabase.activityEvents)
          ..where((t) => t.seriesId.equals(seriesId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  Future<void> insert(ActivityEventsCompanion entry) async {
    await into(attachedDatabase.activityEvents).insert(entry);
  }

  Future<void> batchInsert(List<ActivityEventsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAll(attachedDatabase.activityEvents, entries);
    });
  }

  Future<void> deleteByIssueIds(List<int> issueIds, {String? eventType}) async {
    if (issueIds.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();

    final rows = await (select(attachedDatabase.activityEvents)
          ..where(
            (t) {
              final expr = t.issueId.isIn(issueIds);
              if (eventType != null) {
                return expr & t.eventType.equals(eventType);
              }
              return expr;
            },
          ))
        .get();
    if (rows.isEmpty) return;

    final ids = rows.map((r) => r.id).toList();
    await transaction(() async {
      await (delete(
        attachedDatabase.activityEvents,
      )..where((t) => t.id.isIn(ids))).go();
      await batch((b) {
        b.insertAllOnConflictUpdate(attachedDatabase.syncMeta, [
          for (final id in ids)
            SyncMetaCompanion.insert(
              key: 'delete:activity_events:$id',
              value: now,
            ),
        ]);
      });
    });
  }
}
