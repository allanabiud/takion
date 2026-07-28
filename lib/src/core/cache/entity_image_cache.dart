import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;

final entityImageCacheProvider = Provider<EntityImageCache>((ref) {
  final database = ref.watch(driftDatabaseProvider);
  final versionNotifier = ref.read(entityImageVersionProvider.notifier);
  final cache = EntityImageCache(
    database: database,
    versionNotifier: versionNotifier,
  );
  cache.ensureInit();
  return cache;
});

class EntityImageCache {
  EntityImageCache({required this.database, this.versionNotifier});

  static const int _maxEntries = 500;

  final db.AppDatabase database;
  final EntityImageVersionNotifier? versionNotifier;
  final _cache = LinkedHashMap<String, String>(
    hashCode: (k) => k.hashCode,
    equals: (a, b) => a == b,
  );

  Future<String?> get(String entityType, int id) async {
    final key = '$entityType:$id';
    if (_cache.containsKey(key)) {
      _promoteToMru(key);
      return _cache[key];
    }
    final cached = await database.imageCacheDao.get(key);
    if (cached?.imageUrl != null) {
      _setInMemory(key, cached!.imageUrl);
    }
    return cached?.imageUrl;
  }

  Future<void> ensureInit() async {
    final allEntries = await database.imageCacheDao.getAll();
    for (final entry in allEntries) {
      _setInMemory(entry.key, entry.imageUrl);
    }
    versionNotifier?.update((v) => v + 1);
  }

  String? getCached(String entityType, int id) {
    final key = '$entityType:$id';
    if (_cache.containsKey(key)) {
      _promoteToMru(key);
      return _cache[key];
    }
    return null;
  }

  Future<void> set(String entityType, int id, String imageUrl) async {
    final key = '$entityType:$id';
    _setInMemory(key, imageUrl);
    await database.imageCacheDao.put(
      key,
      imageUrl,
      entityType: entityType,
      entityId: id,
    );
  }

  Future<Map<int, String?>> getMany(String entityType, List<int> ids) async {
    final result = <int, String?>{};
    final missingIds = <int>[];

    for (final id in ids) {
      final key = '$entityType:$id';
      if (_cache.containsKey(key)) {
        _promoteToMru(key);
        result[id] = _cache[key];
      } else {
        missingIds.add(id);
      }
    }

    if (missingIds.isNotEmpty) {
      for (final id in missingIds) {
        final key = '$entityType:$id';
        final cached = await database.imageCacheDao.get(key);
        if (cached?.imageUrl != null) {
          _setInMemory(key, cached!.imageUrl);
          result[id] = cached.imageUrl;
        } else {
          result[id] = null;
        }
      }
    }

    return result;
  }

  Future<void> setMany(String entityType, Map<int, String> entries) async {
    final dbEntries = <String, String>{};
    for (final entry in entries.entries) {
      final key = '$entityType:${entry.key}';
      _setInMemory(key, entry.value);
      dbEntries[key] = entry.value;
    }
    await database.imageCacheDao.putMany(
      dbEntries,
      entityType: entityType,
      entityId: 0,
    );
  }

  void _setInMemory(String key, String value) {
    _evictIfNeeded();
    _cache[key] = value;
  }

  void _promoteToMru(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
  }

  void _evictIfNeeded() {
    while (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

class EntityImageVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void update(int Function(int state) cb) {
    state = cb(state);
  }
}

final entityImageVersionProvider =
    NotifierProvider<EntityImageVersionNotifier, int>(
      EntityImageVersionNotifier.new,
    );
