import 'dart:io';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/hive_registrar.g.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  bool _initialized = false;
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
    'home_content_box',
    'series_cover_cache_box',
    'library_items_cache_box',
    'subscriptions_cache_box',
  };

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    Hive.registerAdapters();
    _initialized = true;
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }

    try {
      return await Hive.openBox<T>(boxName);
    } on TypeError {
      if (!_recoverableCacheBoxes.contains(boxName)) rethrow;
      await _deleteCorruptedBoxFromDisk(boxName);
      return await Hive.openBox<T>(boxName);
    }
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

  Future<void> clearLocalCache() async {
    final boxes = _recoverableCacheBoxes;

    for (final boxName in boxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        // Delete the box file from disk to avoid opening it.
        // This avoids "already open" errors from Hive.openBox.
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } on PathNotFoundException {
          // Box file may not exist yet — safe to ignore.
        }
      }
    }
  }
}
