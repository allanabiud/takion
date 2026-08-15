import "dart:convert";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";

final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return LocalBackupService(db);
});

class LocalBackupService {
  final DriveSyncService _driveSyncService;

  LocalBackupService(AppDatabase db) : _driveSyncService = DriveSyncService(db);

  Future<Uint8List> exportBackupData() async {
    final delta = await _driveSyncService.extractDelta(null);
    return Uint8List.fromList(utf8.encode(jsonEncode(delta)));
  }

  Future<void> importBackupData(Uint8List bytes) async {
    final decoded = utf8.decode(bytes);
    final payload = jsonDecode(decoded) as Map<String, dynamic>;

    if (payload["version"] != 1 && payload["version"] != 2) {
      throw FormatException(
        'Unsupported backup format version: ${payload['version']}',
      );
    }

    await _driveSyncService.applyDelta(payload);
  }
}
