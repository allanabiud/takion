import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/services/drive_backup_service.dart';

void main() {
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

  test('two devices converge on the same favorites', () async {
    await dbA.favoriteDao.toggleCreator(101);
    await dbA.favoriteDao.toggleCreator(102);

    final deltaFromA = await serviceA.extractDelta(null);
    expect(
      (deltaFromA['tables'] as Map)['favorite_creators']['inserts'],
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

  test('extractDelta(since) only returns newer changes', () async {
    await dbA.favoriteDao.toggleCreator(301);
    final firstDelta = await serviceA.extractDelta(null);
    final since = DateTime.parse(firstDelta['toTimestamp'] as String);

    await dbA.favoriteDao.toggleCreator(302);

    final secondDelta = await serviceA.extractDelta(since);
    final inserts = (secondDelta['tables'] as Map)['favorite_creators']
        ['inserts'] as List;
    expect(inserts, hasLength(1));
    expect(inserts.first['metronCreatorId'], 302);
  });

  test('local deletes are synced to the other device', () async {
    await dbA.favoriteDao.toggleCreator(401);
    final deltaA = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaA);
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));

    await dbA.favoriteDao.toggleCreator(401);
    final deltaB = await serviceA.extractDelta(null);
    await serviceB.applyDelta(deltaB);
    expect(await dbB.favoriteDao.getAllCreators(), isEmpty);
  });

  test('extractDelta(since) sets fromTimestamp watermark and version 2', () async {
    await dbA.favoriteDao.toggleCreator(801);
    final first = await serviceA.extractDelta(null);
    expect(first['version'], 2);
    final since = DateTime.parse(first['toTimestamp'] as String);

    await dbA.favoriteDao.toggleCreator(802);

    final second = await serviceA.extractDelta(since);
    expect(second['version'], 2);
    expect(second['fromTimestamp'], since.toUtc().toIso8601String());
    final inserts = (second['tables'] as Map)['favorite_creators']
        ['inserts'] as List;
    expect(inserts, hasLength(1));
    expect(inserts.first['metronCreatorId'], 802);
  });

  test('applyDelta skips v2 deltas already covered by the remote watermark', () async {
    final t1 = DateTime.now().toUtc().toIso8601String();
    final first = {
      'version': 2,
      'deviceId': 'device-a',
      'fromTimestamp': null,
      'toTimestamp': t1,
      'tables': {
        'favorite_creators': {
          'inserts': [
            {'metronCreatorId': 701, 'createdAt': t1, 'updatedAt': t1},
          ],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>[],
        },
      },
    };
    await serviceB.applyDelta(first);
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));

    final stale = {
      'version': 2,
      'deviceId': 'device-a',
      'fromTimestamp': t1,
      'toTimestamp': t1,
      'tables': {
        'favorite_creators': {
          'inserts': [
            {'metronCreatorId': 702, 'createdAt': t1, 'updatedAt': t1},
          ],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>[],
        },
      },
    };
    await serviceB.applyDelta(stale);
    // 702 must NOT be applied: the delta is fully covered by the watermark.
    expect(await dbB.favoriteDao.getAllCreators(), hasLength(1));
  });

  test('reading_list_items merge watermark lets remote snapshot overwrite local', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await dbB.into(dbB.readingListItems).insert(
      ReadingListItemsCompanion.insert(
        id: 'item-x',
        listId: 'list-1',
        targetId: 'ser-1',
        isSeries: true,
        role: 'main',
        isRead: false,
        sortOrder: 0,
      ),
    );

    final snapshot = {
      'version': 2,
      'deviceId': 'device-a',
      'toTimestamp': now,
      'tables': {
        'reading_list_items': {
          'inserts': [
            {
              'id': 'item-x',
              'listId': 'list-1',
              'targetId': 'ser-1',
              'isSeries': true,
              'role': 'main',
              'isRead': true,
              'sortOrder': 5,
            },
          ],
          'updates': <Map<String, dynamic>>[],
          'deletes': <String>[],
        },
      },
    };
    await serviceB.applyDelta(snapshot);

    final rows = await dbB.select(dbB.readingListItems).get();
    expect(rows, hasLength(1));
    expect(rows.first.isRead, isTrue);
    expect(rows.first.sortOrder, 5);
  });
}
