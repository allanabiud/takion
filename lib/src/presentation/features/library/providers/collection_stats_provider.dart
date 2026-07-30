import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final collectionStatsProvider = StreamProvider.autoDispose<CollectionStats>((
  ref,
) {
  final controller = StreamController<CollectionStats>();

  void computeStats(List<LibraryItem> libraryItems) {
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

    double totalValue = 0;
    for (final item in collectedItems) {
      final unitPrice = item.pricePaid ?? 0;
      totalValue += unitPrice * item.quantityOwned;
    }
    final currencyFormat = NumberFormat('#,##0.00');

    if (!controller.isClosed) {
      controller.add(CollectionStats(
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
      ));
    }
  }

  ref.listen<AsyncValue<List<LibraryItem>>>(
    allLibraryItemsProvider,
    (_, next) {
      if (!next.hasValue) return;
      computeStats(next.value!);
    },
  );

  ref.read(allLibraryItemsProvider).whenOrNull(data: (libraryItems) {
    computeStats(libraryItems);
  });

  ref.onDispose(controller.close);

  return controller.stream;
});
