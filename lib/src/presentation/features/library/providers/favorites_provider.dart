import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

final favoriteSeriesListProvider = StreamProvider<List<FavoriteSeries>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchSeries();
});

final favoriteSeriesIdsSetProvider = Provider<Set<int>>((ref) {
  final favoritesAsync = ref.watch(favoriteSeriesListProvider);
  return favoritesAsync.maybeWhen(
    data: (list) => list.map((f) => f.metronSeriesId).toSet(),
    orElse: () => const <int>{},
  );
});

final favoriteSeriesFullListProvider = FutureProvider<List<SeriesList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteSeriesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);
  final localCatalog = ref.watch(localCatalogRepositoryProvider);

  final results = List<SeriesList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final seriesId = favorites[index].metronSeriesId;
      try {
        final localSeries = await localCatalog.getSeries(seriesId);
        if (localSeries != null) {
          results[index] = localSeries;
          continue;
        }
        final details = await repository.getSeriesDetails(seriesId);
        results[index] = SeriesList(
          id: details.id,
          name: details.name,
          volume: details.volume,
          yearBegan: details.yearBegan,
          issueCount: details.issueCount,
          modified: details.modified,
        );
      } catch (e) {
        AppLogger.warning("Failed to load series favorite details", error: e);
      }
    }
  }

  final workerCount = favorites.length < 4 ? favorites.length : 4;
  if (workerCount > 0) {
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }
  return results.whereType<SeriesList>().toList();
});

final isSeriesFavoriteProvider = StreamProvider.family<bool, int>((
  ref,
  seriesId,
) {
  return ref.watch(favoritesRepositoryProvider).watchIsSeriesFavorite(seriesId);
});

final favoriteIssuesListProvider = StreamProvider<List<FavoriteIssue>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchIssues();
});

final favoriteIssueIdsProvider = StreamProvider<Set<int>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchIssueIds();
});

final favoriteIssuesFullListProvider = FutureProvider<List<IssueList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteIssuesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);
  final localCatalog = ref.watch(localCatalogRepositoryProvider);

  final results = List<IssueList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final issueId = favorites[index].metronIssueId;
      try {
        final localIssue = await localCatalog.getIssue(issueId);
        if (localIssue != null) {
          Series? series;
          if (localIssue.seriesId != null) {
            final localSeries = await localCatalog.getSeries(
              localIssue.seriesId!,
            );
            if (localSeries != null) {
              series = Series(
                id: localSeries.id,
                name: localSeries.name,
                volume: localSeries.volume,
                yearBegan: localSeries.yearBegan,
              );
            }
          }
          String displayName = series?.name ?? "Issue";
          if (localIssue.number.isNotEmpty) {
            displayName += " #${localIssue.number}";
          }
          results[index] = IssueList(
            id: localIssue.id,
            name: displayName,
            number: localIssue.number,
            series: series,
            coverDate: localIssue.coverDate,
            storeDate: localIssue.storeDate,
            image: localIssue.imageUrl,
            modified: localIssue.modified,
          );
          continue;
        }

        final details = await repository.getIssueDetails(issueId);
        Series? series;
        if (details.series != null) {
          series = Series(
            id: details.series!.id,
            name: details.series!.name,
            volume: details.series!.volume,
            yearBegan: details.series!.yearBegan,
          );
        }
        String displayName = details.series?.name ?? "Issue";
        if (details.number.isNotEmpty) {
          displayName += " #${details.number}";
        }
        results[index] = IssueList(
          id: details.id,
          name: displayName,
          number: details.number,
          series: series,
          coverDate: details.coverDate,
          storeDate: details.storeDate,
          image: details.image,
          modified: details.modified,
        );
      } catch (e) {
        AppLogger.warning("Failed to load issue favorite details", error: e);
      }
    }
  }

  final workerCount = favorites.length < 4 ? favorites.length : 4;
  if (workerCount > 0) {
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }
  return results.whereType<IssueList>().toList();
});

final isIssueFavoriteProvider = StreamProvider.family<bool, int>((
  ref,
  issueId,
) {
  return ref.watch(favoritesRepositoryProvider).watchIsIssueFavorite(issueId);
});

final favoriteReadingListsListProvider =
    StreamProvider<List<FavoriteReadingList>>((ref) {
      return ref.watch(favoritesRepositoryProvider).watchReadingLists();
    });

final favoriteReadingListsFullListProvider =
    FutureProvider<List<LocalReadingList>>((ref) async {
      final favorites = await ref.watch(
        favoriteReadingListsListProvider.future,
      );
      final repository = ref.watch(localReadingListRepositoryProvider);

      final results = <LocalReadingList>[];
      for (final fav in favorites) {
        try {
          final list = await repository.getListById(fav.readingListId);
          if (list != null) {
            results.add(list);
          }
        } catch (e) {
          AppLogger.warning(
            "Failed to load reading list favorite details",
            error: e,
          );
        }
      }
      return results;
    });

final isReadingListFavoriteProvider = StreamProvider.family<bool, String>((
  ref,
  listId,
) {
  return ref
      .watch(favoritesRepositoryProvider)
      .watchIsReadingListFavorite(listId);
});

final favoriteCharactersListProvider = StreamProvider<List<FavoriteCharacter>>((
  ref,
) {
  return ref.watch(favoritesRepositoryProvider).watchCharacters();
});

final favoriteCharactersFullListProvider = FutureProvider<List<CharacterList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteCharactersListProvider.future);

  final results = List<CharacterList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final charId = favorites[index].metronCharacterId;
      try {
        final repository = ref.read(metronRepositoryProvider);
        final details = await repository.getCharacterDetails(charId);
        results[index] = CharacterList(
          id: details.id,
          name: details.name,
          slug: details.slug,
          modified: details.modified,
        );
      } catch (e) {
        AppLogger.warning(
          "Failed to load character favorite details",
          error: e,
        );
      }
    }
  }

  final workerCount = favorites.length < 4 ? favorites.length : 4;
  if (workerCount > 0) {
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }
  return results.whereType<CharacterList>().toList();
});

final isCharacterFavoriteProvider = StreamProvider.family<bool, int>((
  ref,
  characterId,
) {
  return ref
      .watch(favoritesRepositoryProvider)
      .watchIsCharacterFavorite(characterId);
});

final favoriteCreatorsListProvider = StreamProvider<List<FavoriteCreator>>((
  ref,
) {
  return ref.watch(favoritesRepositoryProvider).watchCreators();
});

final favoriteCreatorsFullListProvider = FutureProvider<List<CreatorList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteCreatorsListProvider.future);

  final results = List<CreatorList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final creatorId = favorites[index].metronCreatorId;
      try {
        final repository = ref.read(metronRepositoryProvider);
        final details = await repository.getCreatorDetails(creatorId);
        results[index] = CreatorList(
          id: details.id,
          name: details.name,
          modified: details.modified,
        );
      } catch (e) {
        AppLogger.warning("Failed to load creator favorite details", error: e);
      }
    }
  }

  final workerCount = favorites.length < 4 ? favorites.length : 4;
  if (workerCount > 0) {
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }
  return results.whereType<CreatorList>().toList();
});

final isCreatorFavoriteProvider = StreamProvider.family<bool, int>((
  ref,
  creatorId,
) {
  return ref
      .watch(favoritesRepositoryProvider)
      .watchIsCreatorFavorite(creatorId);
});
