import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/favorite_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/data/repositories/reading_list_repository_impl.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final favoriteSeriesListProvider = FutureProvider<List<FavoriteSeries>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteSeries();
});

final favoriteSeriesFullListProvider = FutureProvider<List<SeriesList>>((ref) async {
  final favorites = await ref.watch(favoriteSeriesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);
  
  final results = <SeriesList>[];
  for (final fav in favorites) {
    try {
      final details = await repository.getSeriesDetails(fav.metronSeriesId);
      results.add(SeriesList(
        id: details.id,
        name: details.name,
        yearBegan: details.yearBegan,
        volume: details.volume,
        issueCount: details.issueCount,
        modified: details.modified,
      ));
    } catch (_) {}
  }
  return results;
});

final isSeriesFavoriteProvider = FutureProvider.family<bool, int>((ref, seriesId) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isSeriesFavorite(seriesId);
});

final favoriteIssuesListProvider = FutureProvider<List<FavoriteIssue>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteIssues();
});

final favoriteIssuesFullListProvider = FutureProvider<List<IssueList>>((ref) async {
  final favorites = await ref.watch(favoriteIssuesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);
  
  final results = <IssueList>[];
  for (final fav in favorites) {
    try {
      final details = await repository.getIssueDetails(fav.metronIssueId);
      
      Series? series;
      if (details.series != null) {
        series = Series(
          id: details.series!.id,
          name: details.series!.name,
          volume: details.series!.volume,
          yearBegan: details.series!.yearBegan,
        );
      }

      String displayName = details.series?.name ?? 'Issue';
      if (details.number.isNotEmpty) {
        displayName += ' #${details.number}';
      }

      results.add(IssueList(
        id: details.id,
        name: displayName,
        number: details.number,
        series: series,
        coverDate: details.coverDate,
        storeDate: details.storeDate,
        image: details.image,
        modified: details.modified,
      ));
    } catch (_) {}
  }
  return results;
});

final isIssueFavoriteProvider = FutureProvider.family<bool, int>((ref, issueId) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isIssueFavorite(issueId);
});

final favoriteReadingListsListProvider = FutureProvider<List<FavoriteReadingList>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteReadingLists();
});

final favoriteReadingListsFullListProvider = FutureProvider<List<ReadingList>>((ref) async {
  final favorites = await ref.watch(favoriteReadingListsListProvider.future);
  final repository = ref.watch(readingListRepositoryProvider);
  
  final results = <ReadingList>[];
  for (final fav in favorites) {
    try {
      final list = await repository.getListById(fav.readingListId);
      if (list != null) {
        results.add(list);
      }
    } catch (_) {}
  }
  return results;
});

final isReadingListFavoriteProvider = FutureProvider.family<bool, String>((ref, listId) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isReadingListFavorite(listId);
});
