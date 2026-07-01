import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

const libraryCacheBoxName = 'library_items_cache_box';
const libraryAllItemsKey = 'all_items';
const libraryAllItemsMetaKey = 'library_items:all';

Future<void> invalidateLibraryItemsLocalCacheWithHive(
  HiveService hiveService,
) async {
  final cacheBox = await hiveService.openBox<dynamic>(libraryCacheBoxName);
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  await cacheBox.delete(libraryAllItemsKey);
  await metaBox.delete(libraryAllItemsMetaKey);
}

Future<void> invalidateLibraryItemsLocalCache(Ref ref) {
  return invalidateLibraryItemsLocalCacheWithHive(
    ref.read(hiveServiceProvider),
  );
}
