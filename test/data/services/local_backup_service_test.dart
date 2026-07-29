import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/data/common/services/local_backup_service.dart';

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
    'exportBackupData exports database content as valid json bytes',
    () async {
      await db.favoriteDao.toggleCreator(505);

      final bytes = await backupService.exportBackupData();
      expect(bytes, isNotEmpty);

      final jsonStr = utf8.decode(bytes);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(map['version'], equals(1));
      final tables = map['tables'] as Map<String, dynamic>;
      final creatorInserts = tables['favorite_creators']['inserts'] as List;

      expect(creatorInserts.length, equals(1));
      expect(creatorInserts.first['metronCreatorId'], equals(505));
    },
  );

  test('importBackupData imports valid backup bytes into database', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final backupMap = {
      'version': 1,
      'deviceId': 'backup-export-device',
      'toTimestamp': now,
      'tables': {
        'favorite_creators': {
          'inserts': [
            {'metronCreatorId': 707, 'createdAt': now, 'updatedAt': now},
          ],
          'updates': [],
          'deletes': [],
        },
      },
    };

    final bytes = utf8.encode(jsonEncode(backupMap));
    await backupService.importBackupData(bytes);

    final creators = await db.favoriteDao.getAllCreators();
    expect(creators.length, equals(1));
    expect(creators.first.metronCreatorId, equals(707));
  });

  test('importBackupData throws FormatException for invalid version', () async {
    final backupMap = {'version': 99, 'tables': {}};
    final bytes = utf8.encode(jsonEncode(backupMap));

    expect(
      () => backupService.importBackupData(bytes),
      throwsA(isA<FormatException>()),
    );
  });
}
