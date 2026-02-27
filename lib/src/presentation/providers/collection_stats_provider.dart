import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';

final collectionStatsProvider = FutureProvider.autoDispose<CollectionStats>(
  (ref) async {
    final items = await ref.watch(allCollectionItemsProvider.future);
    final collectedItems = items.where((item) => item.quantity > 0).toList();
    final readCount = collectedItems.where((item) => item.isRead).length;

    return CollectionStats(
      totalItems: collectedItems.length,
      totalQuantity: collectedItems.fold<int>(0, (sum, item) => sum + item.quantity),
      totalValue: '--',
      readCount: readCount,
      unreadCount: collectedItems.length - readCount,
      byFormat: const <CollectionStatsByFormat>[],
    );
  },
);
