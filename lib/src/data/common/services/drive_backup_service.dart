import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:http/http.dart" as http;
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/core/sync/sync_diagnostics.dart";
import "package:takion/src/data/common/services/drive_rest_client.dart";
import "package:takion/src/data/common/services/sync_delta_applier.dart";
import "package:takion/src/data/common/services/sync_delta_extractor.dart";

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return DriveSyncService(db);
});

/// Orchestrates Google Drive backup/sync for user data:
/// downloads remote snapshots/deltas, applies them via [SyncDeltaApplier],
/// extracts local changes via [SyncDeltaExtractor], and uploads via
/// [DriveRestClient]. Keeps the sync metadata watermarks up to date.
class DriveSyncService {
  static const _deltaFileName = "takion_delta_v1.json";
  static const _fullFileName = "takion_full_v1.json";

  final AppDatabase _db;
  final DriveRestClient _restClient;
  final SyncDeltaExtractor _extractor;
  final SyncDeltaApplier _applier;

  DriveSyncService(
    this._db, {
    Dio? dio,
    http.Client? httpClient,
    Future<String> Function()? accessTokenProvider,
  })  : _restClient = DriveRestClient(
          dio: dio,
          httpClient: httpClient,
          accessTokenProvider: accessTokenProvider,
        ),
        _extractor = SyncDeltaExtractor(_db),
        _applier = SyncDeltaApplier(_db);

  GoogleSignInAccount? get currentUser => _restClient.currentUser;
  bool get isSignedIn => _restClient.isSignedIn;

  Future<GoogleSignInAccount?> signIn() => _restClient.signIn();

  Future<GoogleSignInAccount?> signInSilently({
    bool reAuthenticate = false,
  }) =>
      _restClient.signInSilently(reAuthenticate: reAuthenticate);

  Future<void> signOut() => _restClient.signOut();

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await _db.syncMetaDao.get("last_sync_timestamp");
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> _record({
    required String phase,
    required bool success,
    String? error,
    String? detail,
    int? elapsedMs,
  }) async {
    try {
      await recordSyncAttempt(
        _db.syncMetaDao,
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

  /// Public wrapper so the WorkManager background isolate can persist sync outcomes outside [triggerSync].
  Future<void> recordSyncOutcome({
    required String phase,
    required bool success,
    Object? error,
    int? elapsedMs,
  }) {
    return _record(
      phase: phase,
      success: success,
      error: error?.toString(),
      detail: error == null ? null : _describeError(error),
      elapsedMs: elapsedMs,
    );
  }

  String _describeError(Object error) {
    if (error is DioException) {
      return "DioException(${error.type}) HTTP ${error.response?.statusCode}";
    }
    if (error is StateError) return "StateError: ${error.message}";
    if (error is FormatException) return "FormatException: ${error.message}";
    return "${error.runtimeType}";
  }

  Future<T> _guarded<T>(String phase, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      await _record(
        phase: phase,
        success: true,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      return result;
    } catch (error) {
      await _record(
        phase: phase,
        success: false,
        error: error.toString(),
        detail: _describeError(error),
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    }
  }

  Future<void> triggerSync({bool ignoreThrottle = false}) async {
    AppLogger.info("Drive sync triggered (ignoreThrottle: $ignoreThrottle)");

    final lockRaw = await _db.syncMetaDao.get("sync_in_progress");
    if (lockRaw != null) {
      final lockTime = DateTime.tryParse(lockRaw);
      final isStale =
          lockTime != null &&
          DateTime.now().difference(lockTime) > const Duration(minutes: 10);
      if (!isStale) {
        AppLogger.info("Sync skipped: another sync is already in progress");
        return;
      }
      AppLogger.warning("Stale sync lock detected, clearing before proceeding");
    }
    await _db.syncMetaDao.set(
      "sync_in_progress",
      DateTime.now().toUtc().toIso8601String(),
    );

    try {
      await _triggerSync(ignoreThrottle: ignoreThrottle);
    } finally {
      await _db.syncMetaDao.deleteByKey("sync_in_progress");
    }
  }

  Future<void> _triggerSync({required bool ignoreThrottle}) async {
    if (!ignoreThrottle) {
      final lastAttempt = await _db.syncMetaDao.get("last_sync_attempt");
      if (lastAttempt != null) {
        final lastAttemptTime = DateTime.tryParse(lastAttempt);
        if (lastAttemptTime != null &&
            DateTime.now().difference(lastAttemptTime) <
                const Duration(minutes: 5)) {
          AppLogger.info("Sync skipped: throttled");
          return;
        }
      }
    }
    await _db.syncMetaDao.set(
      "last_sync_attempt",
      DateTime.now().toUtc().toIso8601String(),
    );

    final deltaFileId = await _guarded(
      "folder",
      () => _restClient.findFileId(_deltaFileName),
    );
    final lastSyncTime = await getLastSyncTime();
    final lastUploadedRaw = await _db.syncMetaDao.get(
      "last_uploaded_timestamp",
    );
    final lastUploaded = lastUploadedRaw == null
        ? null
        : DateTime.tryParse(lastUploadedRaw);
    final localDeviceId = await _extractor.getDeviceId();
    bool remoteChangesApplied = false;
    String? remoteToTimestamp;

    if (lastSyncTime == null) {
      // First sync on this device: always prefer the complete full snapshot.
      final fullFileId = await _guarded(
        "folder",
        () => _restClient.findFileId(_fullFileName),
      );
      if (fullFileId != null) {
        AppLogger.info("First sync: downloading full snapshot");
        remoteToTimestamp = await _applyRemoteFile(fullFileId, localDeviceId);
        remoteChangesApplied = remoteToTimestamp != null;
      } else {
        // No full snapshot exists yet — this device seeds Drive below.
        AppLogger.info("First sync: no full snapshot found, will seed Drive");
      }
    } else if (deltaFileId != null) {
      final remoteModified = await _guarded(
        "meta",
        () => _restClient.getFileModificationTime(deltaFileId),
      );
      final remoteIsNewer =
          remoteModified != null &&
          remoteModified.isAfter(lastSyncTime) &&
          (lastUploaded == null || remoteModified.isAfter(lastUploaded));
      if (remoteIsNewer) {
        AppLogger.info(
          "Remote sync data is available, downloading and checking",
        );
        final bytes = await _guarded(
          "download",
          () => _restClient.downloadFile(deltaFileId),
        );
        if (bytes != null) {
          final payload = await _guarded(
            "parse",
            () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
          );
          if (SyncDeltaApplier.isSupportedVersion(payload["version"])) {
            final remoteDeviceId = payload["deviceId"] as String?;
            if (remoteDeviceId != localDeviceId) {
              final fromTimestamp = payload["fromTimestamp"] as String?;
              final fromTs = fromTimestamp == null
                  ? null
                  : DateTime.tryParse(fromTimestamp);
              final hasGap = fromTs != null && fromTs.isAfter(lastSyncTime);
              if (hasGap) {
                // The delta file only holds the last sync's changes; the local
                // device missed intermediate deltas, so fall back to the
                // always-current full snapshot.
                AppLogger.info(
                  "Delta gap detected (from $fromTimestamp, local lastSync "
                  "$lastSyncTime); downloading full snapshot instead",
                );
                final fullFileId = await _guarded(
                  "folder",
                  () => _restClient.findFileId(_fullFileName),
                );
                if (fullFileId != null) {
                  remoteToTimestamp = await _applyRemoteFile(
                    fullFileId,
                    localDeviceId,
                  );
                  remoteChangesApplied = remoteToTimestamp != null;
                } else {
                  AppLogger.warning(
                    "Gap detected but no full snapshot found; applying delta anyway",
                  );
                  await _guarded(
                    "apply",
                    () => _applier.applyDelta(payload),
                  );
                  remoteChangesApplied = true;
                  remoteToTimestamp = payload["toTimestamp"] as String?;
                }
              } else {
                await _guarded("apply", () => _applier.applyDelta(payload));
                remoteChangesApplied = true;
                remoteToTimestamp = payload["toTimestamp"] as String?;
              }
            } else {
              AppLogger.info(
                "Remote sync file was created by this device ($localDeviceId); skipping remote apply",
              );
            }
          }
        }
      }
    }

    final localChangesDelta = await _guarded(
      "extract",
      () => _extractor.extractDelta(lastUploaded),
    );

    final tables = localChangesDelta["tables"] as Map<String, dynamic>;
    bool hasLocalChanges = false;
    for (final table in tables.values) {
      final inserts = table["inserts"] as List;
      final deletes = table["deletes"] as List;
      if (inserts.isNotEmpty || deletes.isNotEmpty) {
        hasLocalChanges = true;
        break;
      }
    }

    final shouldUpload =
        hasLocalChanges || deltaFileId == null || lastSyncTime == null;

    if (shouldUpload) {
      final insertCount = _countChanges(localChangesDelta, "inserts");
      final deleteCount = _countChanges(localChangesDelta, "deletes");
      AppLogger.info(
        "Uploading local sync data ($insertCount inserts, $deleteCount deletes)",
      );

      final deltaPayload = localChangesDelta;
      final jsonBytes = utf8.encode(jsonEncode(deltaPayload));

      await _guarded(
        "upload",
        () => _restClient.uploadFile(
          _deltaFileName,
          Uint8List.fromList(jsonBytes),
        ),
      );

      final nowStr = deltaPayload["toTimestamp"] as String;
      await _db.syncMetaDao.set("last_sync_timestamp", nowStr);
      await _db.syncMetaDao.set("last_uploaded_timestamp", nowStr);

      final now = DateTime.parse(nowStr);
      await _guarded(
        "prune",
        () => _extractor.pruneDeletedRows(now.subtract(const Duration(days: 30))),
      );
    } else if (remoteChangesApplied && remoteToTimestamp != null) {
      await _db.syncMetaDao.set("last_sync_timestamp", remoteToTimestamp);
      AppLogger.info(
        "Remote changes were applied from $remoteToTimestamp, no local changes to upload",
      );
    } else {
      AppLogger.info("No changes to sync");
    }

    // Keep the full snapshot on Drive current so it always holds the complete
    // dataset (missing snapshot, local changes, or applied remote changes).
    final fullFileId = await _guarded(
      "folder",
      () => _restClient.findFileId(_fullFileName),
    );
    if (fullFileId == null || hasLocalChanges || remoteChangesApplied) {
      AppLogger.info("Refreshing full snapshot on Drive");
      final fullPayload = await _guarded("extract", () => _extractor.extractDelta(null));
      final jsonBytes = utf8.encode(jsonEncode(fullPayload));
      await _guarded(
        "upload",
        () => _restClient.uploadFile(
          _fullFileName,
          Uint8List.fromList(jsonBytes),
        ),
      );
    }
  }

  /// Downloads and applies a remote snapshot/delta file, returning the
  /// payload's [toTimestamp] if it was applied, or null if it was skipped.
  Future<String?> _applyRemoteFile(
    String fileId,
    String localDeviceId,
  ) async {
    final bytes = await _guarded(
      "download",
      () => _restClient.downloadFile(fileId),
    );
    if (bytes == null) return null;
    final payload = await _guarded(
      "parse",
      () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
    if (!SyncDeltaApplier.isSupportedVersion(payload["version"])) {
      AppLogger.warning(
        'Skipping unsupported sync format version: ${payload['version']}',
      );
      return null;
    }
    final remoteDeviceId = payload["deviceId"] as String?;
    if (remoteDeviceId == localDeviceId) {
      AppLogger.info(
        "Remote sync file was created by this device ($localDeviceId); skipping remote apply",
      );
      return null;
    }
    await _guarded("apply", () => _applier.applyDelta(payload));
    return payload["toTimestamp"] as String?;
  }

  int _countChanges(Map<String, dynamic> delta, String kind) {
    final tables = delta["tables"] as Map<String, dynamic>? ?? {};
    var count = 0;
    for (final table in tables.values) {
      final items = (table as Map<String, dynamic>)[kind] as List?;
      if (items != null) count += items.length;
    }
    return count;
  }

  Future<void> forceSync() async {
    AppLogger.info("Forcing full sync snapshot upload");
    final delta = await _guarded("extract", () => _extractor.extractDelta(null));
    final jsonBytes = utf8.encode(jsonEncode(delta));
    await _guarded(
      "upload",
      () => _restClient.uploadFile(
        _fullFileName,
        Uint8List.fromList(jsonBytes),
      ),
    );

    await _guarded(
      "upload",
      () => _restClient.uploadFile(
        _deltaFileName,
        Uint8List.fromList(jsonBytes),
      ),
    );

    final nowStr = delta["toTimestamp"] as String;
    await _db.syncMetaDao.set("last_sync_timestamp", nowStr);
    await _db.syncMetaDao.set("last_uploaded_timestamp", nowStr);

    final now = DateTime.parse(nowStr);
    await _guarded(
      "prune",
      () => _extractor.pruneDeletedRows(now.subtract(const Duration(days: 30))),
    );
  }

  Future<void> restoreFromDrive() async {
    AppLogger.info("Restore from Drive started");

    final String? fileId = await _guarded(
      "folder",
      () => _restClient.findFileId(_fullFileName),
    );

    if (fileId == null) {
      throw StateError("No sync data found on Google Drive");
    }
    final safeFileId = fileId;

    final bytes = await _guarded(
      "download",
      () => _restClient.downloadFile(safeFileId),
    );
    if (bytes == null) {
      throw StateError("Failed to download sync data");
    }

    final payload = await _guarded(
      "parse",
      () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
    if (!SyncDeltaApplier.isSupportedVersion(payload["version"])) {
      throw StateError(
        'Unsupported sync format version: ${payload['version']}',
      );
    }

    await _guarded("apply", () => _applier.applyDelta(payload));

    final toTimestamp = payload["toTimestamp"] ?? payload["timestamp"];
    if (toTimestamp != null) {
      final timestamp = toTimestamp as String;
      await _db.syncMetaDao.set("last_sync_timestamp", timestamp);
      await _db.syncMetaDao.set("last_uploaded_timestamp", timestamp);
    }
    await _record(phase: "restore", success: true);
    AppLogger.info("Restore from Drive completed");
  }

  Future<void> deleteRemoteData() async {
    AppLogger.info("Deleting sync data from Google Drive");
    await _restClient.deleteAllSyncFiles();
  }

  Future<Map<String, dynamic>> extractDelta(DateTime? since) =>
      _extractor.extractDelta(since);

  Future<void> applyDelta(Map<String, dynamic> payload) =>
      _applier.applyDelta(payload);
}