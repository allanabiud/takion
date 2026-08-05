import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

FavoriteSeries _seriesToDomain(db.FavoriteSery d) {
  return FavoriteSeries(
    metronSeriesId: d.metronSeriesId,
    createdAt: DateTime.parse(d.createdAt),
  );
}

FavoriteIssue _issueToDomain(db.FavoriteIssue d) {
  return FavoriteIssue(
    metronIssueId: d.metronIssueId,
    createdAt: DateTime.parse(d.createdAt),
  );
}

FavoriteReadingList _readingListToDomain(db.FavoriteReadingList d) {
  return FavoriteReadingList(
    readingListId: d.readingListId,
    createdAt: DateTime.parse(d.createdAt),
  );
}

FavoriteCharacter _characterToDomain(db.FavoriteCharacter d) {
  return FavoriteCharacter(
    metronCharacterId: d.metronCharacterId,
    createdAt: DateTime.parse(d.createdAt),
  );
}

FavoriteCreator _creatorToDomain(db.FavoriteCreator d) {
  return FavoriteCreator(
    metronCreatorId: d.metronCreatorId,
    createdAt: DateTime.parse(d.createdAt),
  );
}

final favoriteSeriesListProvider = StreamProvider<List<FavoriteSeries>>((ref) {
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllSeries().map((rows) => rows.map(_seriesToDomain).toList());
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
  final db = ref.watch(driftDatabaseProvider);

  final results = List<SeriesList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final seriesId = favorites[index].metronSeriesId;
      try {
        final localSeries = await db.metronEntityDao.getSeries(seriesId);
        if (localSeries != null) {
          results[index] = SeriesList(
            id: localSeries.id,
            name: localSeries.name,
            volume: localSeries.volume,
            yearBegan: localSeries.yearBegan,
            issueCount: localSeries.issueCount,
            modified: localSeries.modified != null
                ? DateTime.tryParse(localSeries.modified!)
                : null,
          );
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
        AppLogger.warning('Failed to load series favorite details', error: e);
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
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchSeriesBySeriesId(seriesId).map((row) => row != null);
});

final favoriteIssuesListProvider = StreamProvider<List<FavoriteIssue>>((ref) {
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllIssues().map((rows) => rows.map(_issueToDomain).toList());
});

final favoriteIssueIdsProvider = StreamProvider<Set<int>>((ref) {
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllIssues().map(
    (rows) => rows.map((r) => r.metronIssueId).toSet(),
  );
});

final favoriteIssuesFullListProvider = FutureProvider<List<IssueList>>((
  ref,
) async {
  final favorites = await ref.watch(favoriteIssuesListProvider.future);
  final repository = ref.watch(metronRepositoryProvider);
  final db = ref.watch(driftDatabaseProvider);

  final results = List<IssueList?>.filled(favorites.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= favorites.length) return;
      cursor = index + 1;
      final issueId = favorites[index].metronIssueId;
      try {
        final localIssue = await db.metronEntityDao.getIssue(issueId);
        if (localIssue != null) {
          Series? series;
          if (localIssue.seriesId != null) {
            final localSeries = await db.metronEntityDao.getSeries(
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
          String displayName = series?.name ?? 'Issue';
          if (localIssue.number.isNotEmpty) {
            displayName += ' #${localIssue.number}';
          }
          results[index] = IssueList(
            id: localIssue.id,
            name: displayName,
            number: localIssue.number,
            series: series,
            coverDate: localIssue.coverDate != null
                ? DateTime.tryParse(localIssue.coverDate!)
                : null,
            storeDate: localIssue.storeDate != null
                ? DateTime.tryParse(localIssue.storeDate!)
                : null,
            image: localIssue.imageUrl,
            modified: localIssue.modified != null
                ? DateTime.tryParse(localIssue.modified!)
                : null,
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
        String displayName = details.series?.name ?? 'Issue';
        if (details.number.isNotEmpty) {
          displayName += ' #${details.number}';
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
        AppLogger.warning('Failed to load issue favorite details', error: e);
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
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchIssueByIssueId(issueId).map((row) => row != null);
});

final favoriteReadingListsListProvider =
    StreamProvider<List<FavoriteReadingList>>((ref) {
      final dao = ref.watch(driftDatabaseProvider).favoriteDao;
      return dao.watchAllReadingLists().map(
        (rows) => rows.map(_readingListToDomain).toList(),
      );
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
            'Failed to load reading list favorite details',
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
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllReadingLists().map(
    (list) => list.any((f) => f.readingListId == listId),
  );
});

final favoriteCharactersListProvider = StreamProvider<List<FavoriteCharacter>>((
  ref,
) {
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllCharacters().map(
    (rows) => rows.map(_characterToDomain).toList(),
  );
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
          'Failed to load character favorite details',
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
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllCharacters().map(
    (list) => list.any((f) => f.metronCharacterId == characterId),
  );
});

final favoriteCreatorsListProvider = StreamProvider<List<FavoriteCreator>>((
  ref,
) {
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllCreators().map(
    (rows) => rows.map(_creatorToDomain).toList(),
  );
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
        AppLogger.warning('Failed to load creator favorite details', error: e);
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
  final dao = ref.watch(driftDatabaseProvider).favoriteDao;
  return dao.watchAllCreators().map(
    (list) => list.any((f) => f.metronCreatorId == creatorId),
  );
});
