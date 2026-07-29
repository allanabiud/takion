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
    if (eventType != null) {
      await (delete(attachedDatabase.activityEvents)
            ..where((t) => t.issueId.isIn(issueIds))
            ..where((t) => t.eventType.equals(eventType)))
          .go();
    } else {
      await (delete(
        attachedDatabase.activityEvents,
      )..where((t) => t.issueId.isIn(issueIds))).go();
    }
  }
}
