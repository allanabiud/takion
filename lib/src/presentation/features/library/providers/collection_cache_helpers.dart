import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';

Future<void> invalidateLibraryItemsLocalCache(Ref ref) {
  ref.invalidate(allLibraryItemsProvider);
  ref.invalidate(collectionStatsProvider);
  return Future<void>.value();
}
