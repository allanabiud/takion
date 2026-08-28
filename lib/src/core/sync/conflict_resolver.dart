import "package:takion/src/data/common/services/sync_delta_applier.dart";

/// Resolves synchronization conflicts, version compatibility, gap detection,
/// and change counting across local and remote snapshots.
class ConflictResolver {
  const ConflictResolver();

  /// Checks whether a remote payload's version is supported by the app.
  bool isSupportedVersion(dynamic version) =>
      SyncDeltaApplier.isSupportedVersion(version);

  /// Checks whether a remote payload should be applied to local storage.
  /// Skips application if the remote file originated from this device.
  bool shouldApplyRemote({
    required String? remoteDeviceId,
    required String localDeviceId,
  }) {
    if (remoteDeviceId == null) return true;
    return remoteDeviceId != localDeviceId;
  }

  /// Determines whether remote file is newer than local sync and upload timestamps.
  bool isRemoteNewer({
    required DateTime? remoteModified,
    required DateTime? lastSyncTime,
    required DateTime? lastUploaded,
  }) {
    if (remoteModified == null) return false;
    if (lastSyncTime == null) return true;
    final isAfterSync = remoteModified.isAfter(lastSyncTime);
    final isAfterUpload =
        lastUploaded == null || remoteModified.isAfter(lastUploaded);
    return isAfterSync && isAfterUpload;
  }

  /// Checks if there is an unapplied gap between local lastSync and remote fromTimestamp.
  bool hasDeltaGap({
    required String? fromTimestampStr,
    required DateTime? lastSyncTime,
  }) {
    if (fromTimestampStr == null || lastSyncTime == null) return false;
    final fromTs = DateTime.tryParse(fromTimestampStr);
    if (fromTs == null) return false;
    return fromTs.isAfter(lastSyncTime);
  }

  /// Checks whether the extracted local delta contains actual inserts or deletes.
  bool hasLocalChanges(Map<String, dynamic> delta) {
    final tables = delta["tables"] as Map<String, dynamic>? ?? {};
    for (final table in tables.values) {
      final tableMap = table as Map<String, dynamic>;
      final inserts = tableMap["inserts"] as List? ?? [];
      final deletes = tableMap["deletes"] as List? ?? [];
      if (inserts.isNotEmpty || deletes.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Counts total change records of the specified [kind] ("inserts" or "deletes").
  int countChanges(Map<String, dynamic> delta, String kind) {
    final tables = delta["tables"] as Map<String, dynamic>? ?? {};
    var count = 0;
    for (final table in tables.values) {
      final items = (table as Map<String, dynamic>)[kind] as List?;
      if (items != null) count += items.length;
    }
    return count;
  }
}
