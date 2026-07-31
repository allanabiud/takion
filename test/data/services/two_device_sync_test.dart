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
}
