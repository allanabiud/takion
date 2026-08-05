import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/services/drive_backup_service.dart';

void main() {
  late AppDatabase db;
  late DriveSyncService syncService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    syncService = DriveSyncService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('extractDelta returns empty tables for fresh database', () async {
    final delta = await syncService.extractDelta(null);
    expect(delta['version'], equals(2));
    expect(delta['tables'], isA<Map<String, dynamic>>());
    final tables = delta['tables'] as Map<String, dynamic>;
    expect(tables['favorite_creators']['inserts'], isEmpty);
  });

  test('extractDelta extracts newly favorited creator', () async {
    await db.favoriteDao.toggleCreator(101);

    final delta = await syncService.extractDelta(null);
    final tables = delta['tables'] as Map<String, dynamic>;
    final creatorInserts = tables['favorite_creators']['inserts'] as List;

    expect(creatorInserts.length, equals(1));
    expect(creatorInserts.first['metronCreatorId'], equals(101));
  });

  test('applyDelta correctly inserts remote favorited creator', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'version': 1,
      'deviceId': 'remote-device-123',
      'toTimestamp': now,
      'tables': {
        'favorite_creators': {
          'inserts': [
            {'metronCreatorId': 202, 'createdAt': now, 'updatedAt': now},
          ],
          'updates': [],
          'deletes': [],
        },
      },
    };

    await syncService.applyDelta(payload);

    final creators = await db.favoriteDao.getAllCreators();
    expect(creators.length, equals(1));
    expect(creators.first.metronCreatorId, equals(202));
  });

  test('applyDelta respects LWW when local creator update is newer', () async {
    final past = DateTime.now()
        .toUtc()
        .subtract(const Duration(hours: 1))
        .toIso8601String();

    await db.favoriteDao.toggleCreator(303); // Inserted at now

    final payload = {
      'version': 1,
      'deviceId': 'remote-device-123',
      'toTimestamp': past,
      'tables': {
        'favorite_creators': {
          'inserts': [],
          'updates': [],
          'deletes': [303],
        },
      },
    };

    await syncService.applyDelta(payload);

    // Local row (now) is newer than remote (past), so it must not be deleted.
    final creators = await db.favoriteDao.getAllCreators();
    expect(creators.length, equals(1));
    expect(creators.first.metronCreatorId, equals(303));
  });

  test('applyDelta inserts remote reading_list_items row', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'version': 2,
      'deviceId': 'remote-device-123',
      'toTimestamp': now,
      'tables': {
        'reading_list_items': {
          'inserts': [
            {
              'id': 'list-1:ser-1',
              'listId': 'list-1',
              'targetId': 'ser-1',
              'isSeries': true,
              'role': 'main',
              'isRead': false,
              'sortOrder': 0,
              'createdAt': now,
              'updatedAt': now,
            },
          ],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>[],
        },
      },
    };

    await syncService.applyDelta(payload);

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(1));
    expect(rows.first.id, 'list-1:ser-1');
    expect(rows.first.updatedAt, now);
  });

  test('applyDelta keeps local reading_list_items row when it is newer (LWW)', () async {
    final past = DateTime.now()
        .toUtc()
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    final now = DateTime.now().toUtc().toIso8601String();

    await db.into(db.readingListItems).insert(
      ReadingListItemsCompanion.insert(
        id: 'list-1:ser-1',
        listId: 'list-1',
        targetId: 'ser-1',
        isSeries: true,
        role: 'main',
        isRead: true,
        sortOrder: 9,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final payload = {
      'version': 2,
      'deviceId': 'remote-device-123',
      'toTimestamp': now,
      'tables': {
        'reading_list_items': {
          'inserts': [
            {
              'id': 'list-1:ser-1',
              'listId': 'list-1',
              'targetId': 'ser-1',
              'isSeries': true,
              'role': 'main',
              'isRead': false,
              'sortOrder': 1,
              'createdAt': past,
              'updatedAt': past,
            },
          ],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>[],
        },
      },
    };

    await syncService.applyDelta(payload);

    final rows = await db.select(db.readingListItems).get();
    expect(rows, hasLength(1));
    expect(rows.first.isRead, isTrue);
    expect(rows.first.sortOrder, 9);
  });

  test('applyDelta deletes reading_list_items row when remote delete is newer', () async {
    final past = DateTime.now()
        .toUtc()
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    final now = DateTime.now().toUtc().toIso8601String();

    await db.into(db.readingListItems).insert(
      ReadingListItemsCompanion.insert(
        id: 'list-1:ser-1',
        listId: 'list-1',
        targetId: 'ser-1',
        isSeries: true,
        role: 'main',
        isRead: false,
        sortOrder: 0,
        createdAt: Value(past),
        updatedAt: Value(past),
      ),
    );

    final payload = {
      'version': 2,
      'deviceId': 'remote-device-123',
      'toTimestamp': now,
      'tables': {
        'reading_list_items': {
          'inserts': <Map<String, dynamic>>[],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>['list-1:ser-1'],
        },
      },
    };

    await syncService.applyDelta(payload);

    expect(await db.select(db.readingListItems).get(), isEmpty);
  });
}
