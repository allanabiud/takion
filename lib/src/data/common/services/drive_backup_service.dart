import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:http/http.dart" as http;
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/core/sync/conflict_resolver.dart";
import "package:takion/src/core/sync/sync_journal.dart";
import "package:takion/src/core/sync/sync_progress_notifier.dart";
import "package:takion/src/data/common/services/drive_rest_client.dart";
import "package:takion/src/data/common/services/sync_delta_applier.dart";
import "package:takion/src/data/common/services/sync_delta_extractor.dart";
import "package:takion/src/data/common/services/sync_transport.dart";

export "package:takion/src/core/sync/conflict_resolver.dart";
export "package:takion/src/core/sync/sync_journal.dart";
export "package:takion/src/core/sync/sync_progress_notifier.dart";
export "package:takion/src/data/common/services/sync_transport.dart";

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return DriveSyncService(db);
});

/// Orchestrates Google Drive backup and sync by delegating to
/// [SyncTransport], [SyncJournal], [ConflictResolver], [SyncDeltaExtractor],
/// [SyncDeltaApplier], and [SyncProgressNotifier].
class DriveSyncService {
  static const _deltaFileName = "takion_delta_v1.json";
  static const _fullFileName = "takion_full_v1.json";

  final SyncTransport _transport;
  final SyncJournal _journal;
  final ConflictResolver _resolver;
  final SyncDeltaExtractor _extractor;
  final SyncDeltaApplier _applier;
  final SyncProgressNotifier progressNotifier;

  DriveSyncService(
    AppDatabase db, {
    Dio? dio,
    http.Client? httpClient,
    Future<String> Function()? accessTokenProvider,
    SyncTransport? transport,
    SyncJournal? journal,
    ConflictResolver? resolver,
    SyncDeltaExtractor? extractor,
    SyncDeltaApplier? applier,
    SyncProgressNotifier? notifier,
  }) : _transport =
           transport ??
           DriveSyncTransport(
             DriveRestClient(
               dio: dio,
               httpClient: httpClient,
               accessTokenProvider: accessTokenProvider,
             ),
           ),
       _journal = journal ?? SyncJournal(db.syncMetaDao),
       _resolver = resolver ?? const ConflictResolver(),
       _extractor = extractor ?? SyncDeltaExtractor(db),
       _applier = applier ?? SyncDeltaApplier(db),
       progressNotifier = notifier ?? SyncProgressNotifier();

  GoogleSignInAccount? get currentUser => _transport.currentUser;
  bool get isSignedIn => _transport.isSignedIn;

  Future<GoogleSignInAccount?> signIn() => _transport.signIn();

  Future<GoogleSignInAccount?> signInSilently({bool reAuthenticate = false}) =>
      _transport.signInSilently(reAuthenticate: reAuthenticate);

  Future<void> signOut() => _transport.signOut();

  Future<DateTime?> getLastSyncTime() => _journal.getLastSyncTime();

  Future<bool> isThrottled({
    Duration minInterval = const Duration(minutes: 5),
  }) => _journal.isThrottled(minInterval: minInterval);

  Future<void> recordSyncOutcome({
    required String phase,
    required bool success,
    Object? error,
    int? elapsedMs,
  }) {
    return _journal.record(
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

  Future<T> _guarded<T>(
    String phase,
    SyncPhase syncPhase,
    Future<T> Function() action,
  ) async {
    progressNotifier.setPhase(syncPhase);
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      await _journal.record(
        phase: phase,
        success: true,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      return result;
    } catch (error) {
      progressNotifier.setPhase(SyncPhase.failed, message: error.toString());
      await _journal.record(
        phase: phase,
        success: false,
        error: error.toString(),
        detail: _describeError(error),
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      rethrow;
    }
  }

  Future<bool> triggerSync({bool ignoreThrottle = false}) async {
    AppLogger.info("Drive sync triggered (ignoreThrottle: $ignoreThrottle)");

    if (!ignoreThrottle && await isThrottled()) {
      AppLogger.info("Sync skipped: throttled (< 5m since last sync attempt)");
      return false;
    }

    final acquired = await _journal.acquireLock();
    if (!acquired) {
      AppLogger.info("Sync skipped: another sync is already in progress");
      return false;
    }

    try {
      return await _triggerSync();
    } finally {
      await _journal.releaseLock();
    }
  }

  Future<bool> _triggerSync() async {
    await _journal.setLastSyncAttempt(DateTime.now());

    final deltaFileId = await _guarded(
      "folder",
      SyncPhase.checking,
      () => _transport.findFileId(_deltaFileName),
    );
    final lastSyncTime = await getLastSyncTime();
    final lastUploaded = await _journal.getLastUploadedTime();
    final localDeviceId = await _extractor.getDeviceId();
    bool remoteChangesApplied = false;
    String? remoteToTimestamp;

    if (lastSyncTime == null) {
      // First sync on this device: prefer complete full snapshot.
      final fullFileId = await _guarded(
        "folder",
        SyncPhase.checking,
        () => _transport.findFileId(_fullFileName),
      );
      if (fullFileId != null) {
        AppLogger.info("First sync: downloading full snapshot");
        remoteToTimestamp = await _applyRemoteFile(fullFileId, localDeviceId);
        remoteChangesApplied = remoteToTimestamp != null;
      } else {
        AppLogger.info("First sync: no full snapshot found, will seed Drive");
      }
    } else if (deltaFileId != null) {
      final remoteModified = await _guarded(
        "meta",
        SyncPhase.checking,
        () => _transport.getFileModificationTime(deltaFileId),
      );
      final remoteIsNewer = _resolver.isRemoteNewer(
        remoteModified: remoteModified,
        lastSyncTime: lastSyncTime,
        lastUploaded: lastUploaded,
      );
      if (remoteIsNewer) {
        AppLogger.info(
          "Remote sync data is available, downloading and checking",
        );
        final bytes = await _guarded(
          "download",
          SyncPhase.downloading,
          () => _transport.downloadFile(deltaFileId),
        );
        if (bytes != null) {
          final payload = await _guarded(
            "parse",
            SyncPhase.parsing,
            () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
          );
          if (_resolver.isSupportedVersion(payload["version"])) {
            final remoteDeviceId = payload["deviceId"] as String?;
            if (_resolver.shouldApplyRemote(
              remoteDeviceId: remoteDeviceId,
              localDeviceId: localDeviceId,
            )) {
              final fromTimestamp = payload["fromTimestamp"] as String?;
              final hasGap = _resolver.hasDeltaGap(
                fromTimestampStr: fromTimestamp,
                lastSyncTime: lastSyncTime,
              );
              if (hasGap) {
                // Fall back to full snapshot when intermediate deltas were missed.
                AppLogger.info(
                  "Delta gap detected (from $fromTimestamp, local lastSync "
                  "$lastSyncTime); downloading full snapshot instead",
                );
                final fullFileId = await _guarded(
                  "folder",
                  SyncPhase.checking,
                  () => _transport.findFileId(_fullFileName),
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
                    SyncPhase.applying,
                    () => _applier.applyDelta(payload),
                  );
                  remoteChangesApplied = true;
                  remoteToTimestamp = payload["toTimestamp"] as String?;
                }
              } else {
                await _guarded(
                  "apply",
                  SyncPhase.applying,
                  () => _applier.applyDelta(payload),
                );
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
      SyncPhase.extracting,
      () => _extractor.extractDelta(lastUploaded),
    );

    final hasLocalChanges = _resolver.hasLocalChanges(localChangesDelta);
    final shouldUpload =
        hasLocalChanges || deltaFileId == null || lastSyncTime == null;

    if (shouldUpload) {
      final insertCount = _resolver.countChanges(localChangesDelta, "inserts");
      final deleteCount = _resolver.countChanges(localChangesDelta, "deletes");
      AppLogger.info(
        "Uploading local sync data ($insertCount inserts, $deleteCount deletes)",
      );

      final deltaPayload = localChangesDelta;
      final jsonBytes = utf8.encode(jsonEncode(deltaPayload));

      await _guarded(
        "upload",
        SyncPhase.uploading,
        () => _transport.uploadFile(
          _deltaFileName,
          Uint8List.fromList(jsonBytes),
        ),
      );

      final nowStr = deltaPayload["toTimestamp"] as String;
      await _journal.setSyncTimestamps(nowStr);

      final now = DateTime.parse(nowStr);
      await _guarded(
        "prune",
        SyncPhase.pruning,
        () =>
            _extractor.pruneDeletedRows(now.subtract(const Duration(days: 30))),
      );
    } else if (remoteChangesApplied && remoteToTimestamp != null) {
      await _journal.setLastSyncTime(remoteToTimestamp);
      AppLogger.info(
        "Remote changes were applied from $remoteToTimestamp, no local changes to upload",
      );
    } else {
      AppLogger.info("No changes to sync");
    }

    // Refresh full snapshot when local/remote changes are applied or file is missing.
    final fullFileId = await _guarded(
      "folder",
      SyncPhase.checking,
      () => _transport.findFileId(_fullFileName),
    );
    if (fullFileId == null || hasLocalChanges || remoteChangesApplied) {
      AppLogger.info("Refreshing full snapshot on Drive");
      final fullPayload = await _guarded(
        "extract",
        SyncPhase.extracting,
        () => _extractor.extractDelta(null),
      );
      final jsonBytes = utf8.encode(jsonEncode(fullPayload));
      await _guarded(
        "upload",
        SyncPhase.uploading,
        () => _transport.uploadFile(
          _fullFileName,
          Uint8List.fromList(jsonBytes),
        ),
      );
      await _journal.setLastFullSnapshotUpload(DateTime.now());
    }

    progressNotifier.setPhase(SyncPhase.completed);
    return true;
  }

  /// Downloads and applies a remote sync file, returning [toTimestamp] if applied.
  Future<String?> _applyRemoteFile(String fileId, String localDeviceId) async {
    final bytes = await _guarded(
      "download",
      SyncPhase.downloading,
      () => _transport.downloadFile(fileId),
    );
    if (bytes == null) return null;
    final payload = await _guarded(
      "parse",
      SyncPhase.parsing,
      () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
    if (!_resolver.isSupportedVersion(payload["version"])) {
      AppLogger.warning(
        'Skipping unsupported sync format version: ${payload['version']}',
      );
      return null;
    }
    final remoteDeviceId = payload["deviceId"] as String?;
    if (!_resolver.shouldApplyRemote(
      remoteDeviceId: remoteDeviceId,
      localDeviceId: localDeviceId,
    )) {
      AppLogger.info(
        "Remote sync file was created by this device ($localDeviceId); skipping remote apply",
      );
      return null;
    }
    await _guarded(
      "apply",
      SyncPhase.applying,
      () => _applier.applyDelta(payload),
    );
    return payload["toTimestamp"] as String?;
  }

  Future<void> forceSync() async {
    AppLogger.info("Forcing full sync snapshot upload");
    final delta = await _guarded(
      "extract",
      SyncPhase.extracting,
      () => _extractor.extractDelta(null),
    );
    final jsonBytes = utf8.encode(jsonEncode(delta));
    await _guarded(
      "upload",
      SyncPhase.uploading,
      () => _transport.uploadFile(_fullFileName, Uint8List.fromList(jsonBytes)),
    );

    await _guarded(
      "upload",
      SyncPhase.uploading,
      () =>
          _transport.uploadFile(_deltaFileName, Uint8List.fromList(jsonBytes)),
    );

    final nowStr = delta["toTimestamp"] as String;
    await _journal.setSyncTimestamps(nowStr);

    final now = DateTime.parse(nowStr);
    await _guarded(
      "prune",
      SyncPhase.pruning,
      () => _extractor.pruneDeletedRows(now.subtract(const Duration(days: 30))),
    );
    progressNotifier.setPhase(SyncPhase.completed);
  }

  Future<void> restoreFromDrive() async {
    AppLogger.info("Restore from Drive started");

    final String? fileId = await _guarded(
      "folder",
      SyncPhase.checking,
      () => _transport.findFileId(_fullFileName),
    );

    if (fileId == null) {
      throw StateError("No sync data found on Google Drive");
    }
    final safeFileId = fileId;

    final bytes = await _guarded(
      "download",
      SyncPhase.downloading,
      () => _transport.downloadFile(safeFileId),
    );
    if (bytes == null) {
      throw StateError("Failed to download sync data");
    }

    final payload = await _guarded(
      "parse",
      SyncPhase.parsing,
      () async => jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
    if (!_resolver.isSupportedVersion(payload["version"])) {
      throw StateError(
        'Unsupported sync format version: ${payload['version']}',
      );
    }

    await _guarded(
      "apply",
      SyncPhase.applying,
      () => _applier.applyDelta(payload),
    );

    final toTimestamp = payload["toTimestamp"] ?? payload["timestamp"];
    if (toTimestamp != null) {
      final timestamp = toTimestamp as String;
      await _journal.setSyncTimestamps(timestamp);
    }
    await _journal.record(phase: "restore", success: true);
    progressNotifier.setPhase(SyncPhase.completed);
    AppLogger.info("Restore from Drive completed");
  }

  Future<void> deleteRemoteData() async {
    AppLogger.info("Deleting sync data from Google Drive");
    await _transport.deleteAllSyncFiles();
  }

  Future<Map<String, dynamic>> extractDelta(DateTime? since) =>
      _extractor.extractDelta(since);

  Future<void> applyDelta(Map<String, dynamic> payload) =>
      _applier.applyDelta(payload);
}
