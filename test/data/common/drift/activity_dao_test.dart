import "package:drift/drift.dart" show Value;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test("deleteByIssueIds records delete markers for matching events", () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.activityDao.batchInsert([
      ActivityEventsCompanion.insert(
        id: "evt-1",
        userId: "u",
        seriesId: const Value(1),
        issueId: const Value(10),
        eventType: "added",
        timestamp: now,
      ),
      ActivityEventsCompanion.insert(
        id: "evt-2",
        userId: "u",
        seriesId: const Value(1),
        issueId: const Value(10),
        eventType: "removed",
        timestamp: now,
      ),
      ActivityEventsCompanion.insert(
        id: "evt-3",
        userId: "u",
        seriesId: const Value(2),
        issueId: const Value(20),
        eventType: "added",
        timestamp: now,
      ),
    ]);

    await db.activityDao.deleteByIssueIds([10], eventType: "added");

    expect(await db.syncMetaDao.get("delete:activity_events:evt-1"), isNotNull);
    expect(await db.syncMetaDao.get("delete:activity_events:evt-2"), isNull);
    expect(await db.syncMetaDao.get("delete:activity_events:evt-3"), isNull);

    final remaining = await db.select(db.activityEvents).get();
    expect(remaining.map((e) => e.id).toSet(), {"evt-2", "evt-3"});
  });

  test("deleteByIssueIds records markers for all matching events without eventType",
      () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.activityDao.batchInsert([
      ActivityEventsCompanion.insert(
        id: "evt-1",
        userId: "u",
        seriesId: const Value(1),
        issueId: const Value(10),
        eventType: "added",
        timestamp: now,
      ),
      ActivityEventsCompanion.insert(
        id: "evt-2",
        userId: "u",
        seriesId: const Value(1),
        issueId: const Value(10),
        eventType: "removed",
        timestamp: now,
      ),
    ]);

    await db.activityDao.deleteByIssueIds([10]);

    expect(await db.syncMetaDao.get("delete:activity_events:evt-1"), isNotNull);
    expect(await db.syncMetaDao.get("delete:activity_events:evt-2"), isNotNull);
    expect(await db.select(db.activityEvents).get(), isEmpty);
  });
}
