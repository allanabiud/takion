import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/sync_diagnostics.dart";
import "package:takion/src/data/common/drift/daos/sync_meta_dao.dart";

/// Manages local sync state, watermarks, timestamps, locking, and diagnostic outcome logging.
class SyncJournal {
  final SyncMetaDao _dao;

  SyncJournal(this._dao);

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await _dao.get("last_sync_timestamp");
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<DateTime?> getLastUploadedTime() async {
    final raw = await _dao.get("last_uploaded_timestamp");
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setSyncTimestamps(String timestamp) async {
    await _dao.set("last_sync_timestamp", timestamp);
    await _dao.set("last_uploaded_timestamp", timestamp);
  }

  Future<void> setLastSyncTime(String timestamp) async {
    await _dao.set("last_sync_timestamp", timestamp);
  }

  Future<void> setLastSyncAttempt(DateTime attemptTime) async {
    await _dao.set("last_sync_attempt", attemptTime.toUtc().toIso8601String());
  }

  Future<void> setLastFullSnapshotUpload(DateTime time) async {
    await _dao.set("last_full_snapshot_upload", time.toUtc().toIso8601String());
  }

  Future<bool> isThrottled({
    Duration minInterval = const Duration(minutes: 5),
  }) async {
    final lastAttempt = await _dao.get("last_sync_attempt");
    if (lastAttempt == null) return false;
    final lastAttemptTime = DateTime.tryParse(lastAttempt);
    if (lastAttemptTime == null) return false;
    return DateTime.now().difference(lastAttemptTime) < minInterval;
  }

  Future<bool> acquireLock({
    Duration staleTimeout = const Duration(minutes: 10),
  }) async {
    final lockRaw = await _dao.get("sync_in_progress");
    if (lockRaw != null) {
      final lockTime = DateTime.tryParse(lockRaw);
      final isStale =
          lockTime != null &&
          DateTime.now().difference(lockTime) > staleTimeout;
      if (!isStale) {
        return false;
      }
      AppLogger.warning("Stale sync lock detected, clearing before proceeding");
    }
    await _dao.set(
      "sync_in_progress",
      DateTime.now().toUtc().toIso8601String(),
    );
    return true;
  }

  Future<void> releaseLock() async {
    await _dao.deleteByKey("sync_in_progress");
  }

  Future<void> record({
    required String phase,
    required bool success,
    String? error,
    String? detail,
    int? elapsedMs,
  }) async {
    try {
      await recordSyncAttempt(
        _dao,
        phase: phase,
        success: success,
        error: error,
        detail: detail,
        elapsedMs: elapsedMs,
      );
    } catch (e) {
      AppLogger.warning("Failed to record sync attempt for $phase", error: e);
    }
  }
}
