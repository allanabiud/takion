import "dart:convert";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/data/common/services/sync_delta_applier.dart";

final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return LocalBackupService(db);
});

class LocalBackupService {
  final DriveSyncService _driveSyncService;

  LocalBackupService(AppDatabase db) : _driveSyncService = DriveSyncService(db);

  static const _maxBackupSizeBytes = 50 * 1024 * 1024;

  Future<Uint8List> exportBackupData() async {
    final delta = await _driveSyncService.extractDelta(null);
    return Uint8List.fromList(utf8.encode(jsonEncode(delta)));
  }

  BackupPreview previewBackup(Uint8List bytes) {
    final decoded = utf8.decode(bytes);
    final payload = jsonDecode(decoded) as Map<String, dynamic>;
    return SyncDeltaApplier.summarizePayload(payload);
  }

  Future<void> importBackupData(Uint8List bytes) async {
    if (bytes.length > _maxBackupSizeBytes) {
      throw StateError(
        "Backup file is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB). "
        "Maximum supported size is 50MB.",
      );
    }

    final decoded = utf8.decode(bytes);
    final payload = jsonDecode(decoded) as Map<String, dynamic>;

    if (payload["version"] != 1 && payload["version"] != 2) {
      throw FormatException(
        'Unsupported backup format version: ${payload['version']}',
      );
    }

    if (!SyncDeltaApplier.validateChecksum(payload)) {
      AppLogger.warning("Backup checksum mismatch — file may be corrupted");
      throw StateError(
        "Backup file integrity check failed. The file may be corrupted.",
      );
    }

    await _driveSyncService.applyDelta(payload);
  }
}
