import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/data/common/drift/database.dart' hide LibraryItem;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final collectionStatsProvider = StreamProvider.autoDispose<CollectionStats>((
  ref,
) {
  final controller = StreamController<CollectionStats>();
  final issuePrices = <int, double>{};
  Timer? debounce;

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
      double unitPrice;
      if (item.pricePaid != null) {
        unitPrice = item.pricePaid!;
      } else {
        unitPrice = issuePrices[item.metronIssueId] ?? 0;
      }
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

  void refreshIssuePrices(List<MetronIssue> issues) {
    final newPrices = <int, double>{};
    for (final issue in issues) {
      if (issue.price != null) {
        final parsed = double.tryParse(issue.price!);
        if (parsed != null) {
          newPrices[issue.id] = parsed;
        }
      }
    }
    issuePrices
      ..clear()
      ..addAll(newPrices);
  }

  ref.listen<AsyncValue<List<LibraryItem>>>(
    allLibraryItemsProvider,
    (_, next) {
      if (!next.hasValue) return;
      // Debounce rapid-fire emissions during bulk operations.
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), () {
        computeStats(next.value!);
      });
    },
  );

  ref.listen<AsyncValue<List<MetronIssue>>>(
    metronIssuesStreamProvider,
    (_, next) {
      if (!next.hasValue) return;
      refreshIssuePrices(next.value!);
      ref.read(allLibraryItemsProvider).whenOrNull(data: (libraryItems) {
        computeStats(libraryItems);
      });
    },
  );

  ref.read(allLibraryItemsProvider).whenOrNull(data: (libraryItems) {
    computeStats(libraryItems);
  });

  ref.read(metronIssuesStreamProvider).whenOrNull(data: (issues) {
    refreshIssuePrices(issues);
    ref.read(allLibraryItemsProvider).whenOrNull(data: (libraryItems) {
      computeStats(libraryItems);
    });
  });

  ref.onDispose(() {
    debounce?.cancel();
    controller.close();
  });

  return controller.stream;
});
