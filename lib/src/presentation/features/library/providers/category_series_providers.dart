import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

List<CategorySeriesSummary> _groupBySeries(
  List<CollectionItem> items,
  Map<int, int> issueToSeriesId,
  Map<int, int> issueCounts,
) {
  final groups = <int, List<CollectionItem>>{};
  for (final item in items) {
    final seriesId = issueToSeriesId[item.issue?.id] ?? item.issue?.series?.id;
    if (seriesId == null || seriesId <= 0) continue;
    groups.putIfAbsent(seriesId, () => []).add(item);
  }

  return groups.entries.map((entry) {
    final seriesItems = entry.value;
    String? resolvedName;
    int? volume;
    int? yearBegan;
    String? coverImage;

    for (final item in seriesItems) {
      final name = item.issue?.series?.name.trim();
      if (name != null && name.isNotEmpty) {
        resolvedName = name;
        volume ??= item.issue?.series?.volume;
        yearBegan ??= item.issue?.series?.yearBegan;
      }
      final img = item.issue?.image?.trim();
      if (coverImage == null && img != null && img.isNotEmpty) {
        coverImage = img;
      }
      if (resolvedName != null && coverImage != null) break;
    }

    final seriesName = (resolvedName != null && resolvedName.isNotEmpty)
        ? resolvedName
        : 'Series ${entry.key}';

    return CategorySeriesSummary(
      seriesId: entry.key,
      seriesName: seriesName,
      volume: volume,
      yearBegan: yearBegan,
      coverImage: coverImage,
      categoryCount: seriesItems.length,
      items: seriesItems,
      issueCount: issueCounts[entry.key],
    );
  }).toList();
}

Map<int, int> _buildIssueToSeriesId(List<LibraryItem> libraryItems) {
  final map = <int, int>{};
  for (final item in libraryItems) {
    map[item.metronIssueId] = item.metronSeriesId;
  }
  return map;
}

Future<List<CategorySeriesSummary>> _groupWithIssueCounts(
  MetronEntityDao dao,
  List<CollectionItem> items,
  Map<int, int> issueToSeriesId,
) async {
  final seriesIds = items
      .map((item) => issueToSeriesId[item.issue?.id] ?? item.issue?.series?.id)
      .whereType<int>()
      .where((id) => id > 0)
      .toSet()
      .toList();
  if (seriesIds.isEmpty) return _groupBySeries(items, issueToSeriesId, {});
  final issueCounts = await dao.getSeriesIssueCounts(seriesIds);
  return _groupBySeries(items, issueToSeriesId, issueCounts);
}

final collectedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final collected = collectionItems
          .where((item) => item.quantity > 0)
          .toList();
      final result = await _groupWithIssueCounts(dao, collected, issueToSeriesId);
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final readSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(true).future,
      );
      final result = await _groupWithIssueCounts(dao, items, issueToSeriesId);
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final wishlistSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(wishlistCollectionItemsProvider.future);
      final result = await _groupWithIssueCounts(dao, items, issueToSeriesId);
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final unreadSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(false).future,
      );
      final result = await _groupWithIssueCounts(dao, items, issueToSeriesId);
      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final unratedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(unratedCollectionItemsProvider.future);
      final result = await _groupWithIssueCounts(dao, items, issueToSeriesId);
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
