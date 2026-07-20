import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/continue_reading_provider.dart';

Future<void> invalidateLibraryItemsLocalCache(dynamic ref) async {
  ref.invalidate(allLibraryItemsProvider);
  ref.invalidate(collectionStatsProvider);
  ref.invalidate(continueReadingAllSuggestionsProvider);
  ref.invalidate(continueReadingSuggestionsProvider);
}
