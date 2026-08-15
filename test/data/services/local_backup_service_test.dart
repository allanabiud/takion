import "dart:convert";
import "package:drift/drift.dart" hide isNull, isNotNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/common/services/local_backup_service.dart";

void main() {
  late AppDatabase db;
  late LocalBackupService backupService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backupService = LocalBackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    "exportBackupData exports database content as valid json bytes",
    () async {
      await db.favoriteDao.toggleCreator(505);

      final bytes = await backupService.exportBackupData();
      expect(bytes, isNotEmpty);

      final jsonStr = utf8.decode(bytes);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(map["version"], equals(2));
      final tables = map["tables"] as Map<String, dynamic>;
      final creatorInserts = tables["favorite_creators"]["inserts"] as List;

      expect(creatorInserts.length, equals(1));
      expect(creatorInserts.first["metronCreatorId"], equals(505));
    },
  );

  test("importBackupData imports valid backup bytes into database", () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final backupMap = {
      "version": 1,
      "deviceId": "backup-export-device",
      "toTimestamp": now,
      "tables": {
        "favorite_creators": {
          "inserts": [
            {"metronCreatorId": 707, "createdAt": now, "updatedAt": now},
          ],
          "updates": [],
          "deletes": [],
        },
      },
    };

    final bytes = utf8.encode(jsonEncode(backupMap));
    await backupService.importBackupData(bytes);

    final creators = await db.favoriteDao.getAllCreators();
    expect(creators.length, equals(1));
    expect(creators.first.metronCreatorId, equals(707));
  });

  test("importBackupData throws FormatException for invalid version", () async {
    final backupMap = {"version": 99, "tables": {}};
    final bytes = utf8.encode(jsonEncode(backupMap));

    expect(
      () => backupService.importBackupData(bytes),
      throwsA(isA<FormatException>()),
    );
  });

  test("full round trip restores data across multiple tables", () async {
    final now = DateTime.now().toUtc().toIso8601String();

    await db.favoriteDao.toggleCreator(808);
    await db.favoriteDao.toggleSeries(909);

    await db.into(db.libraryItems).insert(
      LibraryItemsCompanion.insert(
        id: "lib-500",
        userId: "local-user",
        metronIssueId: 500,
        metronSeriesId: 9,
        ownershipStatus: "owned",
        isRead: true,
        format: "digital",
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.into(db.libraryReadLogs).insert(
      LibraryReadLogsCompanion.insert(
        id: "log-500",
        userId: "local-user",
        collectionItemId: "lib-500",
        readAt: now,
        createdAt: now,
      ),
    );
    await db.readingListDao.upsertList(
      ReadingListsCompanion.insert(
        id: "list-1",
        title: "Weekly Pulls",
        description: "desc",
        isOrdered: true,
        contentType: "series",
        itemsJson: "[]",
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.readingListDao.upsertItems([
      ReadingListItemsCompanion.insert(
        id: "item-1",
        listId: "list-1",
        targetId: "ser-9",
        isSeries: true,
        role: "main",
        isRead: false,
        sortOrder: 0,
      ),
    ]);
    await db.into(db.activityEvents).insert(
      ActivityEventsCompanion.insert(
        id: "act-1",
        userId: "local-user",
        seriesId: const Value(9),
        issueId: const Value(500),
        eventType: "read",
        seriesName: const Value("X-Men"),
        issueNumber: const Value("1"),
        timestamp: now,
      ),
    );

    final bytes = await backupService.exportBackupData();
    expect(bytes, isNotEmpty);

    final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(freshDb.close);
    final freshService = LocalBackupService(freshDb);

    await freshService.importBackupData(bytes);

    expect(await freshDb.favoriteDao.getAllCreators(), hasLength(1));
    expect(await freshDb.favoriteDao.getAllSeries(), hasLength(1));
    expect((await freshDb.libraryItemDao.getItems()).length, 1);
    expect(await freshDb.readingListDao.watchAll().first, hasLength(1));

    final events = await freshDb.select(freshDb.activityEvents).get();
    expect(events, hasLength(1));
  });
}
