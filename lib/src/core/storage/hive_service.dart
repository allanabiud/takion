import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/hive_registrar.g.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  bool _initialized = false;

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
    return await Hive.openBox<T>(boxName);
  }

  Box<T>? getBoxIfOpen<T>(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return null;
  }

  Future<void> clearLocalCache() async {
    // List only data-related boxes to clear
    final boxes = [
      'search_history_box',
      'weekly_releases_box',
      'search_results_box',
      'issue_details_box',
      'collection_stats_box',
    ];

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
