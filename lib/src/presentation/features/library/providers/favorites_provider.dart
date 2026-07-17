import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

final favoriteSeriesListProvider = FutureProvider<List<FavoriteSeries>>((
  ref,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteSeries();
});

final favoriteSeriesFullListProvider = FutureProvider<List<SeriesList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteSeriesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);

  final results = <SeriesList>[];
  for (final fav in favorites) {
    try {
      final details = await repository.getSeriesDetails(fav.metronSeriesId);
      results.add(
        SeriesList(
          id: details.id,
          name: details.name,
          volume: details.volume,
          yearBegan: details.yearBegan,
          issueCount: details.issueCount,
          modified: details.modified,
        ),
      );
    } catch (e) {
      AppLogger.warning('Failed to load series favorite details', error: e);
    }
  }
  return results;
});

final isSeriesFavoriteProvider = FutureProvider.family<bool, int>((
  ref,
  seriesId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isSeriesFavorite(seriesId);
});

final favoriteIssuesListProvider = FutureProvider<List<FavoriteIssue>>((
  ref,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteIssues();
});

final favoriteIssuesFullListProvider = FutureProvider<List<IssueList>>((
  ref,
) async {
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

      results.add(
        IssueList(
          id: details.id,
          name: displayName,
          number: details.number,
          series: series,
          coverDate: details.coverDate,
          storeDate: details.storeDate,
          image: details.image,
          modified: details.modified,
        ),
      );
    } catch (e) {
      AppLogger.warning('Failed to load issue favorite details', error: e);
    }
  }
  return results;
});

final isIssueFavoriteProvider = FutureProvider.family<bool, int>((
  ref,
  issueId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isIssueFavorite(issueId);
});

final favoriteReadingListsListProvider =
    FutureProvider<List<FavoriteReadingList>>((ref) async {
      final repository = ref.watch(favoritesRepositoryProvider);
      return repository.listFavoriteReadingLists();
    });

final favoriteReadingListsFullListProvider = FutureProvider<List<ReadingList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteReadingListsListProvider.future);
  final repository = ref.watch(readingListRepositoryProvider);

  final results = <ReadingList>[];
  for (final fav in favorites) {
    try {
      final list = await repository.getListById(fav.readingListId);
      if (list != null) {
        results.add(list);
      }
    } catch (e) {
      AppLogger.warning('Failed to load reading list favorite details', error: e);
    }
  }
  return results;
});

final isReadingListFavoriteProvider = FutureProvider.family<bool, String>((
  ref,
  listId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isReadingListFavorite(listId);
});

final favoriteCharactersListProvider = FutureProvider<List<FavoriteCharacter>>((
  ref,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteCharacters();
});

final favoriteCharactersFullListProvider = FutureProvider<List<CharacterList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteCharactersListProvider.future);

  final results = <CharacterList>[];
  for (final fav in favorites) {
    try {
      final repository = ref.watch(metronRepositoryProvider);
      final details = await repository.getCharacterDetails(fav.metronCharacterId);
      results.add(
        CharacterList(
          id: details.id,
          name: details.name,
          slug: details.slug,
          modified: details.modified,
        ),
      );
    } catch (e) {
      AppLogger.warning('Failed to load character favorite details', error: e);
    }
  }
  return results;
});

final isCharacterFavoriteProvider = FutureProvider.family<bool, int>((
  ref,
  characterId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isCharacterFavorite(characterId);
});

final favoriteCreatorsListProvider = FutureProvider<List<FavoriteCreator>>((
  ref,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.listFavoriteCreators();
});

final favoriteCreatorsFullListProvider = FutureProvider<List<CreatorList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteCreatorsListProvider.future);

  final results = <CreatorList>[];
  for (final fav in favorites) {
    try {
      final repository = ref.watch(metronRepositoryProvider);
      final details = await repository.getCreatorDetails(fav.metronCreatorId);
      results.add(
        CreatorList(
          id: details.id,
          name: details.name,
          modified: details.modified,
        ),
      );
    } catch (e) {
      AppLogger.warning('Failed to load creator favorite details', error: e);
    }
  }
  return results;
});

final isCreatorFavoriteProvider = FutureProvider.family<bool, int>((
  ref,
  creatorId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isCreatorFavorite(creatorId);
});
