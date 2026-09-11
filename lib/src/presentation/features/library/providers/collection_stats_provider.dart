import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/library/providers/stats_debounce.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

final collectionStatsProvider = StreamProvider.autoDispose<CollectionStats>((
  ref,
) {
  final controller = StreamController<CollectionStats>();
  final issuePrices = <int, double>{};
  final issueDates = <int, String>{};
  final debounced = DebouncedWorker();
  CollectionStats? lastRemoteStats;
  int wishlistCountFromDao = 0;

  void computeStats(List<LibraryItem> libraryItems) {
    final collectedItems = libraryItems
        .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
        .toList();
    final readCount = libraryItems.where((item) => item.isRead).length;
    final unreadCount = collectedItems.where((item) => !item.isRead).length;
    final unratedCount = libraryItems
        .where(
          (item) => item.isRead && (item.rating == null || item.rating! <= 0),
        )
        .length;

    double localTotalValue = 0;
    final formatMap = <String, int>{};
    int localRatedCount = 0;
    double localRatingSum = 0;
    int? localOldestYear;
    int? localNewestYear;

    for (final item in collectedItems) {
      double unitPrice;
      if (item.pricePaid != null) {
        unitPrice = item.pricePaid!;
      } else {
        unitPrice = issuePrices[item.metronIssueId] ?? 0;
      }
      localTotalValue += unitPrice * item.quantityOwned;

      final fmt = item.format.name.toUpperCase();
      formatMap[fmt] = (formatMap[fmt] ?? 0) + item.quantityOwned;

      if (item.rating != null && item.rating! > 0) {
        localRatedCount++;
        localRatingSum += item.rating!;
      }

      final dateStr = issueDates[item.metronIssueId];
      if (dateStr != null && dateStr.length >= 4) {
        final year = int.tryParse(dateStr.substring(0, 4));
        if (year != null && year > 1900 && year < 2100) {
          if (localOldestYear == null || year < localOldestYear) {
            localOldestYear = year;
          }
          if (localNewestYear == null || year > localNewestYear) {
            localNewestYear = year;
          }
        }
      }
    }

    final localByFormat = formatMap.entries
        .map((e) => CollectionStatsByFormat(bookFormat: e.key, count: e.value))
        .toList();

    final currencyFormat = NumberFormat("#,##0.00");
    final remote = lastRemoteStats;

    final totalValueStr = (remote != null &&
            remote.totalValue.isNotEmpty &&
            remote.totalValue != "0.00" &&
            remote.totalValue != r"$0.00")
        ? (remote.totalValue.startsWith(r"$")
            ? remote.totalValue
            : r"$" + remote.totalValue)
        : r"$" + currencyFormat.format(localTotalValue);

    final mergedByFormat = (remote != null && remote.byFormat.isNotEmpty)
        ? remote.byFormat
        : localByFormat;

    final mergedRatingCount =
        (remote != null && remote.ratingCount > 0)
            ? remote.ratingCount
            : localRatedCount;

    final mergedAvgRating = (remote != null && remote.averageRating != null)
        ? remote.averageRating
        : (localRatedCount > 0 ? (localRatingSum / localRatedCount) : null);

    final mergedOldestYear = remote?.coverYearOldest ?? localOldestYear;
    final mergedNewestYear = remote?.coverYearNewest ?? localNewestYear;

    if (!controller.isClosed) {
      controller.add(
        CollectionStats(
          totalItems: (remote != null && remote.totalItems > 0)
              ? remote.totalItems
              : collectedItems.length,
          totalQuantity: (remote != null && remote.totalQuantity > 0)
              ? remote.totalQuantity
              : collectedItems.fold<int>(
                  0,
                  (sum, item) => sum + item.quantityOwned,
                ),
          totalValue: totalValueStr,
          readCount: (remote != null && remote.readCount > 0)
              ? remote.readCount
              : readCount,
          unreadCount: (remote != null && remote.unreadCount > 0)
              ? remote.unreadCount
              : unreadCount,
          ratingCount: mergedRatingCount,
          averageRating: mergedAvgRating,
          coverYearOldest: mergedOldestYear,
          coverYearNewest: mergedNewestYear,
          unratedCount: unratedCount,
          wishlistCount: wishlistCountFromDao,
          byFormat: mergedByFormat,
        ),
      );
    }
  }

  Future<void> fetchRemoteStats() async {
    final isConnected = ref.read(metronConnectionProvider).value ?? false;
    if (!isConnected) return;

    try {
      final repo = ref.read(metronCollectionRepositoryProvider);
      final remote = await repo.getCollectionStats();
      lastRemoteStats = remote;
      ref.read(allLibraryItemsProvider).whenOrNull(
            data: computeStats,
          );
    } catch (_) {
      // Fallback gracefully to local calculation
    }
  }

  void refreshIssueData(List<LocalIssue> issues) {
    final newPrices = <int, double>{};
    final newDates = <int, String>{};
    for (final issue in issues) {
      if (issue.price != null) {
        final parsed = double.tryParse(issue.price!);
        if (parsed != null) {
          newPrices[issue.id] = parsed;
        }
      }
      final date = issue.coverDate ?? issue.storeDate;
      if (date != null) {
        newDates[issue.id] = date.toIso8601String();
      }
    }
    issuePrices
      ..clear()
      ..addAll(newPrices);
    issueDates
      ..clear()
      ..addAll(newDates);
  }

  ref.listen<AsyncValue<List<LibraryItem>>>(allLibraryItemsProvider, (_, next) {
    if (!next.hasValue) return;
    debounced.schedule(() => computeStats(next.value!));
  });

  ref.listen<AsyncValue<List<LocalIssue>>>(metronIssuesStreamProvider, (
    _,
    next,
  ) {
    if (!next.hasValue) return;
    refreshIssueData(next.value!);
    ref.read(allLibraryItemsProvider).whenOrNull(
          data: computeStats,
        );
  });

  ref.listen<AsyncValue<bool>>(metronConnectionProvider, (_, next) {
    if (next.value == true) fetchRemoteStats();
  });

  ref.listen<AsyncValue<List>>(allWishlistItemsStreamProvider, (_, next) {
    if (!next.hasValue) return;
    wishlistCountFromDao = next.value!.length;
    ref.read(allLibraryItemsProvider).whenOrNull(
          data: computeStats,
        );
  });

  fetchRemoteStats();

  ref.onDispose(() {
    debounced.cancel();
    controller.close();
  });

  return controller.stream;
});
