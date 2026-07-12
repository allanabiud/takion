import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

class SyncWatcher {
  final HiveService _hiveService;
  final List<StreamSubscription> _subscriptions = [];
  
  bool _isListening = true;
  late Box<String> _timestampsBox;
  late Box<String> _tombstonesBox;
  
  bool _initialized = false;

  SyncWatcher(this._hiveService);

  static const String timestampsBoxName = 'sync_timestamps_box';
  static const String tombstonesBoxName = 'sync_tombstones_box';

  static const Set<String> syncedBoxes = {
    'local_pull_list_box',
    'local_subscriptions_box',
    'local_library_items_box',
    'local_library_read_logs_box',
    'reading_lists_box',
    'local_favorite_series_box',
    'local_favorite_issues_box',
    'local_favorite_reading_lists_box',
    'local_favorite_characters_box',
    'local_favorite_creators_box',
    'local_profile_box',
    'profile_ui_box',
  };

  bool get isListening => _isListening;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    // Open metadata tracking boxes
    _timestampsBox = await _hiveService.openBox<String>(timestampsBoxName);
    _tombstonesBox = await _hiveService.openBox<String>(tombstonesBoxName);

    // Watch all boxes (use matching types to avoid Hive type-mismatch errors)
    for (final boxName in syncedBoxes) {
      Box box;
      if (boxName == 'reading_lists_box') {
        box = await _hiveService.openBox<ReadingList>(boxName);
      } else if (boxName == 'profile_ui_box') {
        box = await _hiveService.openBox<String>(boxName);
      } else {
        box = await _hiveService.openBox<Map>(boxName);
      }
      final sub = box.watch().listen((event) {
        if (!_isListening) return;
        _handleChange(boxName, event.key.toString(), event.value, event.deleted);
      });
      _subscriptions.add(sub);
    }
    
    _initialized = true;
    debugPrint('SyncWatcher initialized for ${syncedBoxes.length} boxes');
  }

  void pause() {
    _isListening = false;
    debugPrint('SyncWatcher paused');
  }

  void resume() {
    _isListening = true;
    debugPrint('SyncWatcher resumed');
  }

  void _handleChange(String boxName, String key, dynamic value, bool deleted) {
    final trackingKey = '$boxName-$key';
    
    if (deleted) {
      final nowStr = DateTime.now().toUtc().toIso8601String();
      _tombstonesBox.put(trackingKey, nowStr);
      _timestampsBox.delete(trackingKey);
      debugPrint('SyncWatcher: Recorded deletion of $trackingKey at $nowStr');
    } else {
      final timestamp = _getUpdatedAt(value) ?? DateTime.now().toUtc();
      final timeStr = timestamp.toIso8601String();
      _timestampsBox.put(trackingKey, timeStr);
      _tombstonesBox.delete(trackingKey);
      debugPrint('SyncWatcher: Recorded update of $trackingKey at $timeStr');
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

  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _initialized = false;
    debugPrint('SyncWatcher disposed');
  }
}
