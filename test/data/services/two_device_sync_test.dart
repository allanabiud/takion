import "package:drift/drift.dart" show Value, driftRuntimeOptions;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase dbA;
  late AppDatabase dbB;
  late DriveSyncService serviceA;
  late DriveSyncService serviceB;

  setUp(() {
    dbA = AppDatabase.forTesting(NativeDatabase.memory());
    dbB = AppDatabase.forTesting(NativeDatabase.memory());
    serviceA = DriveSyncService(dbA);
    serviceB = DriveSyncService(dbB);
  });

  tearDown(() async {
    await dbA.close();
    await dbB.close();
  });

  test("two devices converge on the same favorites", () async {
    await dbA.favoriteDao.toggleCreator(101);
    await dbA.favoriteDao.toggleCreator(102);

    final deltaFromA = await serviceA.extractDelta(null);
    expect(
      (deltaFromA["tables"] as Map)["favorite_creators"]["inserts"],
      hasLength(2),
    );

    await serviceB.applyDelta(deltaFromA);
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(2));

    await dbB.favoriteDao.toggleCreator(202);

    final deltaFromB = await serviceB.extractDelta(null);
    await serviceA.applyDelta(deltaFromB);

    expect(await dbA.favoriteDao.getAllCreators(), hasLength(3));
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(3));
  });

  test("extractDelta(since) only returns newer changes", () async {
    await dbA.favoriteDao.toggleCreator(301);
    final firstDelta = await serviceA.extractDelta(null);
    final since = DateTime.parse(firstDelta["toTimestamp"] as String);

    await dbA.favoriteDao.toggleCreator(302);

    final secondDelta = await serviceA.extractDelta(since);
    final inserts =
        (secondDelta["tables"] as Map)["favorite_creators"]["inserts"] as List;
    expect(inserts, hasLength(1));
    expect(inserts.first["metronCreatorId"], 302);
  });

  test("local deletes are synced to the other device", () async {
    await dbA.favoriteDao.toggleCreator(401);
    final deltaA = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaA);
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));

    await dbA.favoriteDao.toggleCreator(401);
    final deltaB = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaB);
    expect(await dbB.favoriteDao.getAllCreators(), isEmpty);
  });

  test(
    "extractDelta(since) sets fromTimestamp watermark and version 2",
    () async {
      await dbA.favoriteDao.toggleCreator(801);
      final first = await serviceA.extractDelta(null);
      expect(first["version"], 2);
      final since = DateTime.parse(first["toTimestamp"] as String);

      await dbA.favoriteDao.toggleCreator(802);

      final second = await serviceA.extractDelta(since);
      expect(second["version"], 2);
      expect(second["fromTimestamp"], since.toUtc().toIso8601String());
      final inserts =
          (second["tables"] as Map)["favorite_creators"]["inserts"] as List;
      expect(inserts, hasLength(1));
      expect(inserts.first["metronCreatorId"], 802);
    },
  );

  test(
    "applyDelta skips v2 deltas already covered by the remote watermark",
    () async {
      final t1 = DateTime.now().toUtc().toIso8601String();
      final first = {
        "version": 2,
        "deviceId": "device-a",
        "fromTimestamp": null,
        "toTimestamp": t1,
        "tables": {
          "favorite_creators": {
            "inserts": [
              {"metronCreatorId": 701, "createdAt": t1, "updatedAt": t1},
            ],
            "updates": <Map<String, dynamic>>[],
            "deletes": <String>[],
          },
        },
      };
      await serviceB.applyDelta(first);
      expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));

      final stale = {
        "version": 2,
        "deviceId": "device-a",
        "fromTimestamp": t1,
        "toTimestamp": t1,
        "tables": {
          "favorite_creators": {
            "inserts": [
              {"metronCreatorId": 702, "createdAt": t1, "updatedAt": t1},
            ],
            "updates": <Map<String, dynamic>>[],
            "deletes": <String>[],
          },
        },
      };
      await serviceB.applyDelta(stale);
      expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));
    },
  );

  test(
    "reading_list_items remote row overwrites local when its updatedAt is newer",
    () async {
      final past = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 1))
          .toIso8601String();
      final now = DateTime.now().toUtc().toIso8601String();
      await dbB
          .into(dbB.readingListItems)
          .insert(
            ReadingListItemsCompanion.insert(
              id: "item-x",
              listId: "list-1",
              targetId: "ser-1",
              isSeries: true,
              role: "main",
              isRead: false,
              sortOrder: 0,
              createdAt: Value(past),
              updatedAt: Value(past),
            ),
          );

      final snapshot = {
        "version": 2,
        "deviceId": "device-a",
        "toTimestamp": now,
        "tables": {
          "reading_list_items": {
            "inserts": [
              {
                "id": "item-x",
                "listId": "list-1",
                "targetId": "ser-1",
                "isSeries": true,
                "role": "main",
                "isRead": true,
                "sortOrder": 5,
                "createdAt": now,
                "updatedAt": now,
              },
            ],
            "updates": <Map<String, dynamic>>[],
            "deletes": <String>[],
          },
        },
      };
      await serviceB.applyDelta(snapshot);

      final rows = await dbB.select(dbB.readingListItems).get();
      expect(rows, hasLength(1));
      expect(rows.first.isRead, isTrue);
      expect(rows.first.sortOrder, 5);
    },
  );

  test("extractDelta(since) omits unchanged reading_list_items", () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await dbA
        .into(dbA.readingListItems)
        .insert(
          ReadingListItemsCompanion.insert(
            id: "item-1",
            listId: "list-1",
            targetId: "ser-1",
            isSeries: true,
            role: "main",
            isRead: false,
            sortOrder: 0,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    final full = await serviceA.extractDelta(null);
    expect(
      ((full["tables"] as Map)["reading_list_items"]["inserts"] as List),
      hasLength(1),
    );

    final since = DateTime.parse(full["toTimestamp"] as String);
    final delta = await serviceA.extractDelta(since);
    expect(
      ((delta["tables"] as Map)["reading_list_items"]["inserts"] as List),
      isEmpty,
    );
  });

  test("reading_list_items delete propagates to the other device", () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await dbA
        .into(dbA.readingListItems)
        .insert(
          ReadingListItemsCompanion.insert(
            id: "item-del",
            listId: "list-1",
            targetId: "ser-1",
            isSeries: true,
            role: "main",
            isRead: false,
            sortOrder: 0,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final deltaA = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaA);
    expect(await dbB.select(dbB.readingListItems).get(), hasLength(1));

    await dbA.syncMetaDao.set(
      "delete:reading_list_items:item-del",
      DateTime.now().toUtc().toIso8601String(),
    );
    await dbA.delete(dbA.readingListItems).go();

    final deltaB = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaB);

    expect(await dbB.select(dbB.readingListItems).get(), isEmpty);
  });
}
