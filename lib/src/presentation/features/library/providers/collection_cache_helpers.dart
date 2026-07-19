import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/presentation/features/home/providers/home_content_cache.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/continue_reading_provider.dart';

Future<void> invalidateLibraryItemsLocalCache(dynamic ref) async {
  ref.invalidate(allLibraryItemsProvider);
  ref.invalidate(collectionStatsProvider);
  ref.invalidate(continueReadingAllSuggestionsProvider);
  ref.invalidate(continueReadingSuggestionsProvider);

  final cache = ref.read(homeContentCacheProvider);
  try {
    await cache.writeJsonList(homeContinueReadingCacheKey, const []);
    await cache.deleteCachedAt(homeContinueReadingMetaKey);
  } catch (e) {
    AppLogger.warning('Failed to clear continue reading cache', error: e);
  }
}
