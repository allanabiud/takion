import "dart:async";

import "package:takion/src/domain/entities.dart";

abstract class FavoritesRepository {
  Stream<List<FavoriteSeries>> watchSeries();
  Stream<bool> watchIsSeriesFavorite(int metronSeriesId);
  Future<List<FavoriteSeries>> listFavoriteSeries();
  Future<bool> isSeriesFavorite(int metronSeriesId);
  Future<void> toggleSeriesFavorite(int metronSeriesId);

  Stream<List<FavoriteIssue>> watchIssues();
  Stream<Set<int>> watchIssueIds();
  Stream<bool> watchIsIssueFavorite(int metronIssueId);
  Future<List<FavoriteIssue>> listFavoriteIssues();
  Future<bool> isIssueFavorite(int metronIssueId);
  Future<void> toggleIssueFavorite(int metronIssueId);

  Stream<List<FavoriteReadingList>> watchReadingLists();
  Stream<bool> watchIsReadingListFavorite(String readingListId);
  Future<List<FavoriteReadingList>> listFavoriteReadingLists();
  Future<bool> isReadingListFavorite(String readingListId);
  Future<void> toggleReadingListFavorite(String readingListId);

  Stream<List<FavoriteCharacter>> watchCharacters();
  Stream<bool> watchIsCharacterFavorite(int metronCharacterId);
  Future<List<FavoriteCharacter>> listFavoriteCharacters();
  Future<bool> isCharacterFavorite(int metronCharacterId);
  Future<void> toggleCharacterFavorite(int metronCharacterId);

  Stream<List<FavoriteCreator>> watchCreators();
  Stream<bool> watchIsCreatorFavorite(int metronCreatorId);
  Future<List<FavoriteCreator>> listFavoriteCreators();
  Future<bool> isCreatorFavorite(int metronCreatorId);
  Future<void> toggleCreatorFavorite(int metronCreatorId);
}
