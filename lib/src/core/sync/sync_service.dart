import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/sync/sync_watcher.dart';
import 'package:takion/src/core/sync/cloud_sync_transport.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

enum SyncState { idle, syncing, success, error }

class SyncStatus {
  final SyncState state;
  final String? message;
  final DateTime? lastSyncAt;

  SyncStatus({
    required this.state,
    this.message,
    this.lastSyncAt,
  });

  SyncStatus copyWith({
    SyncState? state,
    String? message,
    DateTime? lastSyncAt,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      message: message ?? this.message,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

class SyncEngine extends ChangeNotifier {
  final HiveService _hiveService;
  final SyncWatcher _watcher;
  final CloudSyncTransport _transport;
  final Connectivity _connectivity;

  SyncState _state = SyncState.idle;
  String? _message;
  DateTime? _lastSyncAt;

  SyncEngine(
    this._hiveService,
    this._watcher,
    this._transport,
    this._connectivity,
  );

  SyncState get state => _state;
  String? get message => _message;
  DateTime? get lastSyncAt => _lastSyncAt;

  SyncStatus get status => SyncStatus(
        state: _state,
        message: _message,
        lastSyncAt: _lastSyncAt,
      );

  Future<void> init() async {
    final settingsBox = await _hiveService.openBox('settings_box');
    final raw = settingsBox.get('last_cloud_sync') as String?;
    if (raw != null) {
      _lastSyncAt = DateTime.tryParse(raw)?.toUtc();
    }
  }

  void _updateStatus(SyncState state, {String? message}) {
    _state = state;
    _message = message;
    notifyListeners();
  }

  Future<void> syncAll() async {
    if (_state == SyncState.syncing) return;
    _updateStatus(SyncState.syncing, message: 'Starting sync...');

    try {
      // 1. Check Connectivity
      final results = await _connectivity.checkConnectivity();
      final hasNetwork = results.any((result) => result != ConnectivityResult.none);
      if (!hasNetwork) {
        _updateStatus(SyncState.error, message: 'No internet connection');
        return;
      }

      // 2. Ensure signed in
      if (!_transport.isSignedIn) {
        await _transport.signInSilently();
        if (!_transport.isSignedIn) {
          _updateStatus(SyncState.error, message: 'Not signed in to Google Drive');
          return;
        }
      }

      // 3. Ensure Device ID & Name
      final settingsBox = await _hiveService.openBox('settings_box');
      var deviceId = settingsBox.get('sync_device_id') as String?;
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = const Uuid().v4();
        await settingsBox.put('sync_device_id', deviceId);
      }
      var deviceName = settingsBox.get('sync_device_name') as String?;
      if (deviceName == null || deviceName.isEmpty) {
        deviceName = await _defaultDeviceName();
        await settingsBox.put('sync_device_name', deviceName);
      }

      // 4. Download remote JSON
      _updateStatus(SyncState.syncing, message: 'Downloading cloud data...');
      final remoteJsonStr = await _transport.downloadSyncData();
      
      Map<String, dynamic> remoteData = {};
      if (remoteJsonStr != null && remoteJsonStr.isNotEmpty) {
        try {
          remoteData = jsonDecode(remoteJsonStr) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('SyncEngine: Error decoding remote JSON, starting fresh: $e');
        }
      }

      final remoteBoxes = remoteData['boxes'] as Map<String, dynamic>? ?? {};

      // Prepare local tracking boxes
      final timestampBox = await _hiveService.openBox<String>(SyncWatcher.timestampsBoxName);
      final tombstoneBox = await _hiveService.openBox<String>(SyncWatcher.tombstonesBoxName);

      // Maps to track what we need to write/delete locally
      final Map<String, List<MapEntry<String, dynamic>>> localPuts = {};
      final Map<String, List<String>> localDeletes = {};

      // The new merged remote state
      final Map<String, Map<String, dynamic>> mergedBoxes = {};

      _updateStatus(SyncState.syncing, message: 'Merging data...');

      // 5. Merge each box
      for (final boxName in SyncWatcher.syncedBoxes) {
        localPuts[boxName] = [];
        localDeletes[boxName] = [];
        mergedBoxes[boxName] = {};

        // A. Load local active entries
        final localActiveEntries = await _hiveService.readAllEntries(boxName);
        final Map<String, dynamic> localActiveValues = {};
        final Map<String, DateTime> localActiveTimes = {};

        for (final entry in localActiveEntries) {
          final key = entry['k'] as String;
          final val = entry['v'];
          localActiveValues[key] = val;
          
          // Determine updatedAt
          final valTime = _getUpdatedAt(val);
          if (valTime != null) {
            localActiveTimes[key] = valTime;
          } else {
            final storedTimeStr = timestampBox.get('$boxName-$key');
            localActiveTimes[key] = storedTimeStr != null 
                ? DateTime.parse(storedTimeStr).toUtc() 
                : DateTime.fromMillisecondsSinceEpoch(0).toUtc();
          }
        }

        // B. Load local tombstones
        final Map<String, DateTime> localTombstones = {};
        final prefix = '$boxName-';
        for (final keyObj in tombstoneBox.keys) {
          final fullKey = keyObj.toString();
          if (fullKey.startsWith(prefix)) {
            final key = fullKey.substring(prefix.length);
            final timeStr = tombstoneBox.get(fullKey);
            if (timeStr != null) {
              localTombstones[key] = DateTime.parse(timeStr).toUtc();
            }
          }
        }

        // C. Load remote entries for this box
        final remoteBox = remoteBoxes[boxName] as Map<String, dynamic>? ?? {};

        // Gather all keys
        final allKeys = <String>{
          ...localActiveValues.keys,
          ...localTombstones.keys,
          ...remoteBox.keys,
        };

        for (final key in allKeys) {
          // Local State
          final bool isLocalActive = localActiveValues.containsKey(key);
          final bool isLocalDeleted = localTombstones.containsKey(key);
          
          final localVal = localActiveValues[key];
          final localTime = localActiveTimes[key] ?? localTombstones[key];

          // Remote State
          final remoteEntry = remoteBox[key] as Map<String, dynamic>?;
          final bool isRemoteActive = remoteEntry != null && remoteEntry['d'] == false;
          final bool isRemoteDeleted = remoteEntry != null && remoteEntry['d'] == true;
          
          final remoteVal = remoteEntry?['v'];
          final remoteTime = remoteEntry != null 
              ? DateTime.parse(remoteEntry['m'] as String).toUtc() 
              : null;

          // Merge Logic
          if (isLocalActive && remoteEntry == null) {
            // New local item
            mergedBoxes[boxName]![key] = {
              'v': localVal,
              'm': localTime!.toIso8601String(),
              'd': false,
            };
          } 
          else if (isLocalDeleted && remoteEntry == null) {
            // Deleted locally before ever synced
            mergedBoxes[boxName]![key] = {
              'm': localTime!.toIso8601String(),
              'd': true,
            };
          } 
          else if (!isLocalActive && !isLocalDeleted && isRemoteActive) {
            // New remote item
            localPuts[boxName]!.add(MapEntry(key, remoteVal));
            mergedBoxes[boxName]![key] = remoteEntry;
          } 
          else if (!isLocalActive && !isLocalDeleted && isRemoteDeleted) {
            // Already deleted remotely
            mergedBoxes[boxName]![key] = remoteEntry;
          } 
          else if (isLocalActive && isRemoteActive) {
            // Edit conflict
            if (localTime!.isAfter(remoteTime!)) {
              // Local wins
              mergedBoxes[boxName]![key] = {
                'v': localVal,
                'm': localTime.toIso8601String(),
                'd': false,
              };
            } else {
              // Remote wins
              localPuts[boxName]!.add(MapEntry(key, remoteVal));
              mergedBoxes[boxName]![key] = remoteEntry;
            }
          } 
          else if (isLocalActive && isRemoteDeleted) {
            // Delete vs Edit
            if (localTime!.isAfter(remoteTime!)) {
              // Local re-activated
              mergedBoxes[boxName]![key] = {
                'v': localVal,
                'm': localTime.toIso8601String(),
                'd': false,
              };
            } else {
              // Remote delete wins
              localDeletes[boxName]!.add(key);
              mergedBoxes[boxName]![key] = remoteEntry;
            }
          } 
          else if (isLocalDeleted && isRemoteActive) {
            // Edit vs Delete
            if (localTime!.isAfter(remoteTime!)) {
              // Local delete wins
              mergedBoxes[boxName]![key] = {
                'm': localTime.toIso8601String(),
                'd': true,
              };
            } else {
              // Remote edit re-creates
              localPuts[boxName]!.add(MapEntry(key, remoteVal));
              mergedBoxes[boxName]![key] = remoteEntry;
            }
          } 
          else if (isLocalDeleted && isRemoteDeleted) {
            // Redundant delete
            mergedBoxes[boxName]![key] = localTime!.isAfter(remoteTime!) 
                ? { 'm': localTime.toIso8601String(), 'd': true }
                : remoteEntry;
          }
        }
      }

      // 6. Apply local changes (pause watcher first!)
      _updateStatus(SyncState.syncing, message: 'Applying local updates...');
      _watcher.pause();
      
      try {
        for (final boxName in SyncWatcher.syncedBoxes) {
          // Apply deletes
          for (final key in localDeletes[boxName]!) {
            await _hiveService.deleteEntry(boxName, key);
            await timestampBox.delete('$boxName-$key');
            await tombstoneBox.delete('$boxName-$key');
          }
          
          // Apply updates
          for (final entry in localPuts[boxName]!) {
            await _hiveService.putEntry(boxName, entry.key, entry.value);
            final remoteTimeStr = mergedBoxes[boxName]![entry.key]['m'] as String;
            await timestampBox.put('$boxName-${entry.key}', remoteTimeStr);
            await tombstoneBox.delete('$boxName-${entry.key}');
          }
        }
      } finally {
        _watcher.resume();
      }

      // 7. Update devices list & lastSyncAt
      final nowUtc = DateTime.now().toUtc();
      final devices = remoteData['devices'] as Map<String, dynamic>? ?? {};
      devices[deviceId] = {
        'name': deviceName,
        'lastSeen': nowUtc.toIso8601String(),
      };

      final payload = {
        'formatVersion': 1,
        'lastSyncAt': nowUtc.toIso8601String(),
        'devices': devices,
        'boxes': mergedBoxes,
      };

      // 8. Upload consolidated JSON to Drive
      _updateStatus(SyncState.syncing, message: 'Uploading to cloud...');
      final uploadJsonStr = jsonEncode(payload);
      await _transport.uploadSyncData(uploadJsonStr);

      // 9. Clear synced local tombstones
      for (final boxName in SyncWatcher.syncedBoxes) {
        final prefix = '$boxName-';
        final keysToRemove = <String>[];
        for (final keyObj in tombstoneBox.keys) {
          final fullKey = keyObj.toString();
          if (fullKey.startsWith(prefix)) {
            keysToRemove.add(fullKey);
          }
        }
        for (final k in keysToRemove) {
          await tombstoneBox.delete(k);
        }
      }

      // Save last sync time in settings_box
      await settingsBox.put('last_cloud_sync', nowUtc.toIso8601String());
      _lastSyncAt = nowUtc;

      _updateStatus(SyncState.success, message: 'Sync completed successfully');
    } catch (e, stack) {
      debugPrint('SyncEngine: Error during sync: $e\n$stack');
      _updateStatus(SyncState.error, message: 'Sync failed: $e');
    }
  }

  DateTime? _getUpdatedAt(dynamic value) {
    if (value == null) return null;
    
    if (value is Map) {
      final updatedRaw = value['updated_at'] ?? value['updatedAt'];
      if (updatedRaw != null) {
        return DateTime.tryParse(updatedRaw.toString());
      }
    }
    
    if (value is ReadingList) {
      return value.updatedAt;
    }
    
    return null;
  }

  Future<String> _defaultDeviceName() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      if (info is AndroidDeviceInfo) return info.model;
      if (info is IosDeviceInfo) return info.modelName;
      if (info is WindowsDeviceInfo) return info.computerName;
      if (info is LinuxDeviceInfo) return info.name;
      if (info is MacOsDeviceInfo) return info.modelName;
    } catch (_) {}
    return 'My Device';
  }
}
