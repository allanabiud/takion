import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final collectionStatsProvider = FutureProvider<CollectionStats>((ref) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final collectedItems = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
      .toList();
  final wishlistCount = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist)
      .length;
  final readCount = libraryItems.where((item) => item.isRead).length;
  final unreadCount = collectedItems.where((item) => !item.isRead).length;
  final unratedCount = libraryItems
      .where(
        (item) => item.isRead && (item.rating == null || item.rating! <= 0),
      )
      .length;

  final hiveService = ref.read(hiveServiceProvider);
  double totalValue = 0;
  for (final item in collectedItems) {
    final unitPrice = item.pricePaid ??
        await hiveService.getIssuePrice(item.metronIssueId) ??
        0;
    totalValue += unitPrice * item.quantityOwned;
  }
  final currencyFormat = NumberFormat('#,##0.00');

  return CollectionStats(
    totalItems: collectedItems.length,
    totalQuantity: collectedItems.fold<int>(
      0,
      (sum, item) => sum + item.quantityOwned,
    ),
    totalValue: '\$${currencyFormat.format(totalValue)}',
    readCount: readCount,
    unreadCount: unreadCount,
    unratedCount: unratedCount,
    wishlistCount: wishlistCount,
    byFormat: const <CollectionStatsByFormat>[],
  );
});
