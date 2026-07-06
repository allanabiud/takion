import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/core/storage/hive_service.dart';


final entityImageCacheProvider = Provider<EntityImageCache>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final cache = EntityImageCache(hiveService: hiveService);
  cache.ensureInit();
  return cache;
});

class EntityImageVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int Function(int state) cb) {
    state = cb(state);
  }
}

final entityImageVersionProvider = NotifierProvider<EntityImageVersionNotifier, int>(EntityImageVersionNotifier.new);

class EntityImageCache {
  EntityImageCache({required HiveService hiveService}) : _hiveService = hiveService;

  static const boxName = 'entity_image_cache_box';
  final HiveService _hiveService;
  Box<String>? _box;

  Future<Box<String>> getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await _hiveService.openBox<String>(boxName);
    return _box!;
  }

  Future<String?> get(String entityType, int id) async {
    final box = await getBox();
    return box.get('$entityType:$id');
  }

  void ensureInit() {
    if (_box != null) return;
    getBox();
  }

  String? getCached(String entityType, int id) {
    if (_box != null && _box!.isOpen) {
      return _box!.get('$entityType:$id');
    }
    getBox();
    return null;
  }

  Future<void> set(String entityType, int id, String imageUrl) async {
    if (imageUrl.trim().isEmpty) return;
    final box = await getBox();
    await box.put('$entityType:$id', imageUrl.trim());
  }

  Future<void> setMany(String entityType, Map<int, String> entries) async {
    final valid = <String, String>{};
    for (final entry in entries.entries) {
      if (entry.value.trim().isNotEmpty) {
        valid['$entityType:${entry.key}'] = entry.value.trim();
      }
    }
    if (valid.isEmpty) return;
    final box = await getBox();
    await box.putAll(valid);
  }
}
