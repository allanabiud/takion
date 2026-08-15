import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

class FavoriteDao extends DatabaseAccessor<AppDatabase> {
  FavoriteDao(super.db);

  Future<List<FavoriteSery>> getAllSeries() {
    return select(attachedDatabase.favoriteSeries).get();
  }

  Stream<List<FavoriteSery>> watchAllSeries() {
    return select(attachedDatabase.favoriteSeries).watch();
  }

  Stream<FavoriteSery?> watchSeriesBySeriesId(int metronSeriesId) {
    return (select(attachedDatabase.favoriteSeries)
          ..where((t) => t.metronSeriesId.equals(metronSeriesId)))
        .watchSingleOrNull();
  }

  Future<FavoriteSery?> getSeriesBySeriesId(int metronSeriesId) async {
    return (select(
      attachedDatabase.favoriteSeries,
    )..where((t) => t.metronSeriesId.equals(metronSeriesId))).getSingleOrNull();
  }

  Future<void> toggleSeries(int metronSeriesId) async {
    final existing = await getSeriesBySeriesId(metronSeriesId);
    if (existing != null) {
      await transaction(() async {
        await (delete(
          attachedDatabase.favoriteSeries,
        )..where((t) => t.metronSeriesId.equals(metronSeriesId))).go();
        await attachedDatabase.syncMetaDao.set(
          "delete:favorite_series:$metronSeriesId",
          DateTime.now().toUtc().toIso8601String(),
        );
      });
    } else {
      await transaction(() async {
        await into(attachedDatabase.favoriteSeries).insert(
          FavoriteSeriesCompanion(
            metronSeriesId: Value(metronSeriesId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:favorite_series:$metronSeriesId",
        );
      });
    }
  }

  Future<List<FavoriteIssue>> getAllIssues() {
    return select(attachedDatabase.favoriteIssues).get();
  }

  Stream<List<FavoriteIssue>> watchAllIssues() {
    return select(attachedDatabase.favoriteIssues).watch();
  }

  Stream<FavoriteIssue?> watchIssueByIssueId(int metronIssueId) {
    return (select(
      attachedDatabase.favoriteIssues,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).watchSingleOrNull();
  }

  Future<FavoriteIssue?> getIssueByIssueId(int metronIssueId) async {
    return (select(
      attachedDatabase.favoriteIssues,
    )..where((t) => t.metronIssueId.equals(metronIssueId))).getSingleOrNull();
  }

  Future<void> toggleIssue(int metronIssueId) async {
    final existing = await getIssueByIssueId(metronIssueId);
    if (existing != null) {
      await transaction(() async {
        await (delete(
          attachedDatabase.favoriteIssues,
        )..where((t) => t.metronIssueId.equals(metronIssueId))).go();
        await attachedDatabase.syncMetaDao.set(
          "delete:favorite_issues:$metronIssueId",
          DateTime.now().toUtc().toIso8601String(),
        );
      });
    } else {
      await transaction(() async {
        await into(attachedDatabase.favoriteIssues).insert(
          FavoriteIssuesCompanion(
            metronIssueId: Value(metronIssueId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:favorite_issues:$metronIssueId",
        );
      });
    }
  }

  Future<List<FavoriteCharacter>> getAllCharacters() {
    return select(attachedDatabase.favoriteCharacters).get();
  }

  Stream<List<FavoriteCharacter>> watchAllCharacters() {
    return select(attachedDatabase.favoriteCharacters).watch();
  }

  Future<FavoriteCharacter?> getCharacterByCharacterId(
    int metronCharacterId,
  ) async {
    return (select(attachedDatabase.favoriteCharacters)
          ..where((t) => t.metronCharacterId.equals(metronCharacterId)))
        .getSingleOrNull();
  }

  Future<void> toggleCharacter(int metronCharacterId) async {
    final existing = await getCharacterByCharacterId(metronCharacterId);
    if (existing != null) {
      await transaction(() async {
        await (delete(
          attachedDatabase.favoriteCharacters,
        )..where((t) => t.metronCharacterId.equals(metronCharacterId))).go();
        await attachedDatabase.syncMetaDao.set(
          "delete:favorite_characters:$metronCharacterId",
          DateTime.now().toUtc().toIso8601String(),
        );
      });
    } else {
      await transaction(() async {
        await into(attachedDatabase.favoriteCharacters).insert(
          FavoriteCharactersCompanion(
            metronCharacterId: Value(metronCharacterId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:favorite_characters:$metronCharacterId",
        );
      });
    }
  }

  Future<List<FavoriteCreator>> getAllCreators() {
    return select(attachedDatabase.favoriteCreators).get();
  }

  Stream<List<FavoriteCreator>> watchAllCreators() {
    return select(attachedDatabase.favoriteCreators).watch();
  }

  Future<FavoriteCreator?> getCreatorByCreatorId(int metronCreatorId) async {
    return (select(attachedDatabase.favoriteCreators)
          ..where((t) => t.metronCreatorId.equals(metronCreatorId)))
        .getSingleOrNull();
  }

  Future<void> toggleCreator(int metronCreatorId) async {
    final existing = await getCreatorByCreatorId(metronCreatorId);
    if (existing != null) {
      await transaction(() async {
        await (delete(
          attachedDatabase.favoriteCreators,
        )..where((t) => t.metronCreatorId.equals(metronCreatorId))).go();
        await attachedDatabase.syncMetaDao.set(
          "delete:favorite_creators:$metronCreatorId",
          DateTime.now().toUtc().toIso8601String(),
        );
      });
    } else {
      await transaction(() async {
        await into(attachedDatabase.favoriteCreators).insert(
          FavoriteCreatorsCompanion(
            metronCreatorId: Value(metronCreatorId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:favorite_creators:$metronCreatorId",
        );
      });
    }
  }

  Future<List<FavoriteReadingList>> getAllReadingLists() {
    return select(attachedDatabase.favoriteReadingLists).get();
  }

  Stream<List<FavoriteReadingList>> watchAllReadingLists() {
    return select(attachedDatabase.favoriteReadingLists).watch();
  }

  Future<FavoriteReadingList?> getReadingListByListId(
    String readingListId,
  ) async {
    return (select(
      attachedDatabase.favoriteReadingLists,
    )..where((t) => t.readingListId.equals(readingListId))).getSingleOrNull();
  }

  Future<void> toggleReadingList(String readingListId) async {
    final existing = await getReadingListByListId(readingListId);
    if (existing != null) {
      await transaction(() async {
        await (delete(
          attachedDatabase.favoriteReadingLists,
        )..where((t) => t.readingListId.equals(readingListId))).go();
        await attachedDatabase.syncMetaDao.set(
          "delete:favorite_reading_lists:$readingListId",
          DateTime.now().toUtc().toIso8601String(),
        );
      });
    } else {
      await transaction(() async {
        await into(attachedDatabase.favoriteReadingLists).insert(
          FavoriteReadingListsCompanion(
            readingListId: Value(readingListId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
        await attachedDatabase.syncMetaDao.deleteByKey(
          "delete:favorite_reading_lists:$readingListId",
        );
      });
    }
  }
}
