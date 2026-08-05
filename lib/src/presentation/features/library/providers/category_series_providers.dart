import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final collectedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      await ref.watch(allLibraryItemsProvider.future);
      final dao = ref.read(driftDatabaseProvider).libraryItemDao;
      final rows = await dao.getSeriesSummariesByCategory(
        ownershipStatus: 'owned',
      );
      final result = rows
          .map(
            (r) => CategorySeriesSummary(
              seriesId: r.seriesId,
              seriesName: r.seriesName,
              volume: r.volume,
              yearBegan: r.yearBegan,
              categoryCount: r.categoryCount,
              items: const [],
              issueCount: r.issueCount,
            ),
          )
          .toList();
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final readSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      await ref.watch(allLibraryItemsProvider.future);
      final dao = ref.read(driftDatabaseProvider).libraryItemDao;
      final rows = await dao.getSeriesSummariesByCategory(isRead: true);
      final result = rows
          .map(
            (r) => CategorySeriesSummary(
              seriesId: r.seriesId,
              seriesName: r.seriesName,
              volume: r.volume,
              yearBegan: r.yearBegan,
              categoryCount: r.categoryCount,
              items: const [],
              issueCount: r.issueCount,
            ),
          )
          .toList();
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final wishlistSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      await ref.watch(allLibraryItemsProvider.future);
      final dao = ref.read(driftDatabaseProvider).libraryItemDao;
      final rows = await dao.getSeriesSummariesByCategory(
        ownershipStatus: 'wishlist',
      );
      final result = rows
          .map(
            (r) => CategorySeriesSummary(
              seriesId: r.seriesId,
              seriesName: r.seriesName,
              volume: r.volume,
              yearBegan: r.yearBegan,
              categoryCount: r.categoryCount,
              items: const [],
              issueCount: r.issueCount,
            ),
          )
          .toList();
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final unreadSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      await ref.watch(allLibraryItemsProvider.future);
      final dao = ref.read(driftDatabaseProvider).libraryItemDao;
      final rows = await dao.getSeriesSummariesByCategory(isRead: false);
      final result = rows
          .map(
            (r) => CategorySeriesSummary(
              seriesId: r.seriesId,
              seriesName: r.seriesName,
              volume: r.volume,
              yearBegan: r.yearBegan,
              categoryCount: r.categoryCount,
              items: const [],
              issueCount: r.issueCount,
            ),
          )
          .toList();
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final unratedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      await ref.watch(allLibraryItemsProvider.future);
      final dao = ref.read(driftDatabaseProvider).libraryItemDao;
      final rows = await dao.getSeriesSummariesByCategory(isUnrated: true);
      final result = rows
          .map(
            (r) => CategorySeriesSummary(
              seriesId: r.seriesId,
              seriesName: r.seriesName,
              volume: r.volume,
              yearBegan: r.yearBegan,
              categoryCount: r.categoryCount,
              items: const [],
              issueCount: r.issueCount,
            ),
          )
          .toList();
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final seriesByCategoryProvider = FutureProvider.autoDispose
    .family<List<CategorySeriesSummary>, String>((ref, category) {
      switch (category) {
        case 'collected':
          return ref.watch(collectedSeriesProvider.future);
        case 'read':
          return ref.watch(readSeriesProvider.future);
        case 'wishlist':
          return ref.watch(wishlistSeriesProvider.future);
        case 'unread':
          return ref.watch(unreadSeriesProvider.future);
        case 'unrated':
          return ref.watch(unratedSeriesProvider.future);
        default:
          return Future.value(<CategorySeriesSummary>[]);
      }
    });

SortPreferenceContext _sortContextForCategory(String category) {
  switch (category) {
    case 'collected':
      return SortPreferenceContext.libraryMyComics;
    case 'read':
      return SortPreferenceContext.libraryRead;
    case 'wishlist':
      return SortPreferenceContext.libraryWishlist;
    case 'unread':
      return SortPreferenceContext.libraryUnread;
    case 'unrated':
      return SortPreferenceContext.libraryUnrated;
    default:
      return SortPreferenceContext.libraryMyComics;
  }
}

typedef CategorySeriesView = ({List<SeriesList> series, Map<int, int> categoryCounts});

CategorySeriesView _buildSeriesView(
  List<CategorySeriesSummary> summaries,
  ContentSortOption sortOption,
) {
  final mapped = summaries.map((s) {
    return (
      series: SeriesList(
        id: s.seriesId,
        name: s.seriesName,
        volume: s.volume,
        yearBegan: s.yearBegan,
        issueCount: s.issueCount,
      ),
      categoryCount: s.categoryCount,
    );
  }).toList();
  final sortedResults = sortSeries(
    mapped.map((e) => e.series).toList(),
    sortOption,
  );
  final categoryCounts = <int, int>{
    for (final e in mapped) e.series.id: e.categoryCount,
  };
  return (series: sortedResults, categoryCounts: categoryCounts);
}

final sortedCategorySeriesViewProvider = FutureProvider.autoDispose
    .family<CategorySeriesView, String>((ref, category) async {
      final summaries =
          await ref.watch(seriesByCategoryProvider(category).future);
      final sortOption = ref.watch(
        sortPreferenceForContextProvider(_sortContextForCategory(category)),
      );
      return _buildSeriesView(summaries, sortOption);
    });

final categorySeriesViewProvider = FutureProvider.autoDispose.family<
    CategorySeriesView,
    ({String category, String query})>((ref, arg) async {
  final view =
      await ref.watch(sortedCategorySeriesViewProvider(arg.category).future);
  final query = arg.query.toLowerCase().trim();
  if (query.isEmpty) return view;
  final filtered = view.series
      .where((s) => s.name.toLowerCase().contains(query))
      .toList();
  return (series: filtered, categoryCounts: view.categoryCounts);
});
