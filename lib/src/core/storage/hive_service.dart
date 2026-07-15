import 'dart:io';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/hive_registrar.g.dart';
import 'package:takion/src/data/dto/issue_details_dto.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  bool _initialized = false;
  final _clearFns = <String, Future<void> Function()>{};
  static const Set<String> _recoverableCacheBoxes = {
    'weekly_releases_box',
    'foc_releases_box',
    'cache_meta_box',
    'issue_details_box',
    'issue_search_box',
    'issue_search_meta_box',
    'issue_list_box',
    'issue_list_meta_box',
    'series_search_box',
    'series_search_meta_box',
    'series_list_box',
    'series_list_meta_box',
    'series_details_box',
    'series_issue_list_box',
    'series_issue_list_meta_box',
    'character_search_box',
    'character_search_meta_box',
    'character_details_box',
    'character_issue_list_box',
    'character_issue_list_meta_box',
    'creator_search_box',
    'creator_search_meta_box',
    'creator_details_box',
    'universe_search_box',
    'universe_search_meta_box',
    'universe_details_box',
    'imprint_search_box',
    'imprint_search_meta_box',
    'imprint_details_box',
    'team_search_box',
    'team_search_meta_box',
    'team_details_box',
    'publisher_search_box',
    'publisher_search_meta_box',
    'publisher_details_box',
    'publisher_series_list_box',
    'publisher_series_list_meta_box',
    'arc_search_box',
    'arc_search_meta_box',
    'arc_details_box',
    'arc_issue_list_box',
    'arc_issue_list_meta_box',
    'home_content_box',
    'series_cover_cache_box',
    'subscriptions_cache_box',
    'series_name_index_box',
    'entity_image_cache_box',
  };

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    Hive.registerAdapters();
    _initialized = true;
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<T>(boxName);
      _clearFns[boxName] = box.clear;
      return box;
    }

    try {
      final box = await Hive.openBox<T>(boxName);
      _clearFns[boxName] = box.clear;
      return box;
    } on TypeError {
      if (!_recoverableCacheBoxes.contains(boxName)) rethrow;
      await _deleteCorruptedBoxFromDisk(boxName);
      final box = await Hive.openBox<T>(boxName);
      _clearFns[boxName] = box.clear;
      return box;
    }
  }

  Future<Box> _openBoxForBackup(String boxName) async {
    if (boxName == 'reading_lists_box') {
      return Hive.isBoxOpen(boxName)
          ? Hive.box<ReadingList>(boxName)
          : await Hive.openBox<ReadingList>(boxName);
    }
    return Hive.isBoxOpen(boxName)
        ? Hive.box<Map>(boxName)
        : await Hive.openBox<Map>(boxName);
  }

  Future<List<Map<String, dynamic>>> readAllEntries(String boxName) async {
    final box = await _openBoxForBackup(boxName);
    final tsBox = await _timestampsBox();
    final entries = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        final serialized = boxName == 'reading_lists_box'
            ? (value as ReadingList).toJson()
            : value;
        final entry = <String, dynamic>{
          'k': key,
          'v': serialized,
        };
        final ts = tsBox.get('$boxName:$key');
        if (ts != null) entry['t'] = ts;
        entries.add(entry);
      }
    }
    return entries;
  }

  Future<dynamic> readEntry(String boxName, String key) async {
    final box = await _openBoxForBackup(boxName);
    final value = box.get(key);
    if (value == null) return null;
    if (boxName == 'reading_lists_box') {
      return (value as ReadingList).toJson();
    }
    return value;
  }

  Future<void> putEntry(String boxName, String key, dynamic value) async {
    final box = await _openBoxForBackup(boxName);
    if (boxName == 'reading_lists_box') {
      await box.put(key, ReadingList.fromJson(value as Map<String, dynamic>));
    } else {
      await box.put(key, value);
    }
    await recordTimestamp(boxName, key);
  }

  Future<void> deleteEntry(String boxName, String key) async {
    final box = await _openBoxForBackup(boxName);
    await box.delete(key);
    await deleteTimestamp(boxName, key);
    await recordDeleteTimestamp(boxName, key);
  }

  static const _timestampsBoxName = 'sync_timestamps_box';
  static const _deletionsBoxName = 'sync_deletions_box';

  Future<Box> _timestampsBox() async {
    if (Hive.isBoxOpen(_timestampsBoxName)) {
      return Hive.box(_timestampsBoxName);
    }
    return Hive.openBox(_timestampsBoxName);
  }

  Future<Box> _deletionsBox() async {
    if (Hive.isBoxOpen(_deletionsBoxName)) {
      return Hive.box(_deletionsBoxName);
    }
    return Hive.openBox(_deletionsBoxName);
  }

  Future<void> recordTimestamp(String boxName, String key) async {
    final box = await _timestampsBox();
    await box.put('$boxName:$key', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> deleteTimestamp(String boxName, String key) async {
    final box = await _timestampsBox();
    await box.delete('$boxName:$key');
  }

  Future<Map<String, int>> getChangedKeysSince(DateTime since) async {
    final box = await _timestampsBox();
    final cutoff = since.millisecondsSinceEpoch;
    final result = <String, int>{};
    for (final entry in box.toMap().entries) {
      final timestamp = entry.value as int;
      if (timestamp > cutoff) {
        result[entry.key] = timestamp;
      }
    }
    return result;
  }

  Future<int> syncTimestampsCount() async {
    final box = await _timestampsBox();
    return box.length;
  }

  Future<void> resetSyncTimestamps() async {
    final box = await _timestampsBox();
    await box.clear();
    final delBox = await _deletionsBox();
    await delBox.clear();
  }

  Future<Map<String, int>> getAllTimestamps() async {
    final box = await _timestampsBox();
    return box.toMap().map((k, v) => MapEntry(k as String, v as int));
  }

  Future<void> clearBoxData(String boxName) async {
    final box = await _openBoxForBackup(boxName);
    await box.clear();
  }

  Future<double?> getIssuePrice(int metronIssueId) async {
    const boxName = 'issue_details_box';
    if (!Hive.isBoxOpen(boxName)) return null;
    final box = Hive.box<IssueDetailsDto>(boxName);
    final details = box.get(metronIssueId.toString());
    if (details == null) return null;
    final priceStr = details.price;
    if (priceStr == null) return null;
    return double.tryParse(priceStr);
  }

  Future<bool> hasBackupData() async {
    const backupBoxNames = [
      'local_profile_box',
      'local_library_items_box',
      'local_library_read_logs_box',
      'local_pull_list_box',
      'local_subscriptions_box',
      'local_favorite_series_box',
      'local_favorite_issues_box',
      'local_favorite_reading_lists_box',
      'local_favorite_characters_box',
      'local_favorite_creators_box',
      'reading_lists_box',
    ];
    for (final boxName in backupBoxNames) {
      final box = await _openBoxForBackup(boxName);
      if (box.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> recordDeleteTimestamp(String boxName, String key) async {
    final box = await _deletionsBox();
    await box.put('$boxName:$key', DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, int>> getDeletedKeysSince(DateTime since) async {
    final box = await _deletionsBox();
    final cutoff = since.millisecondsSinceEpoch;
    final result = <String, int>{};
    for (final entry in box.toMap().entries) {
      final timestamp = entry.value as int;
      if (timestamp > cutoff) {
        result[entry.key] = timestamp;
      }
    }
    return result;
  }

  Future<void> clearDeleteTimestamps() async {
    final box = await _deletionsBox();
    await box.clear();
  }

  Future<void> _deleteCorruptedBoxFromDisk(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      return;
    } on PathNotFoundException {
      // Another process or isolate may remove a file between exists() and delete().
      // Missing files are safe to ignore during recovery.
      return;
    }
  }

  Box<T>? getBoxIfOpen<T>(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return null;
  }

  static const Set<String> _imageCacheBoxes = {
    'entity_image_cache_box',
    'series_cover_cache_box',
  };

  Future<void> clearLocalCache() async {
    for (final boxName in _recoverableCacheBoxes) {
      if (Hive.isBoxOpen(boxName)) {
        final clearFn = _clearFns[boxName];
        if (clearFn != null) {
          await clearFn();
        }
      } else {
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } on PathNotFoundException {
          // Box file may not exist yet — safe to ignore.
        }
      }
    }
  }

  Future<void> clearImageCache() async {
    for (final boxName in _imageCacheBoxes) {
      if (Hive.isBoxOpen(boxName)) {
        final clearFn = _clearFns[boxName];
        if (clearFn != null) {
          await clearFn();
        }
      } else {
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } on PathNotFoundException {
          // Box file may not exist yet — safe to ignore.
        }
      }
    }
  }

  Future<int> cacheSize() async {
    final dir = Directory(Hive.box('settings_box').path!).parent;
    int total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<int> imageCacheSize() async {
    final dir = Directory(Hive.box('settings_box').path!).parent;
    int total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && _isImageCacheFile(entity.path)) {
        total += await entity.length();
      }
    }
    return total;
  }

  bool _isImageCacheFile(String path) {
    for (final boxName in _imageCacheBoxes) {
      if (path.contains(boxName)) return true;
    }
    return false;
  }
}
