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
    expect(delta['version'], equals(1));
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

    // Should NOT delete local row because local timestamp (now) is newer than remote toTimestamp (past)
    final creators = await db.favoriteDao.getAllCreators();
    expect(creators.length, equals(1));
    expect(creators.first.metronCreatorId, equals(303));
  });
}
