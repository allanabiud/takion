import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';

final collectionStatsProvider = FutureProvider<CollectionStats>((ref) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final collectedItems = libraryItems
      .where(
        (item) =>
            item.ownershipStatus == LibraryOwnershipStatus.owned &&
            item.quantityOwned > 0,
      )
      .toList();
  final wishlistCount = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist)
      .length;
  final readCount = collectedItems.where((item) => item.isRead).length;
  final unratedCount = collectedItems
      .where((item) => item.isRead && item.rating == null)
      .length;

  return CollectionStats(
    totalItems: collectedItems.length,
    totalQuantity: collectedItems.fold<int>(
      0,
      (sum, item) => sum + item.quantityOwned,
    ),
    totalValue: '--',
    readCount: readCount,
    unreadCount: collectedItems.length - readCount,
    unratedCount: unratedCount,
    wishlistCount: wishlistCount,
    byFormat: const <CollectionStatsByFormat>[],
  );
});
