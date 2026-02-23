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
    'cache_meta_box',
    'issue_details_box',
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
        // If it's not open, we just open it dynamic which is safe for clear()
        final box = await Hive.openBox(boxName);
        await box.clear();
      }
    }
  }
}
