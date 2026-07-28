import 'package:takion/src/domain/entities.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteSeries>> listFavoriteSeries();
  Future<bool> isSeriesFavorite(int metronSeriesId);
  Future<void> toggleSeriesFavorite(int metronSeriesId);

  Future<List<FavoriteIssue>> listFavoriteIssues();
  Future<bool> isIssueFavorite(int metronIssueId);
  Future<void> toggleIssueFavorite(int metronIssueId);

  Future<List<FavoriteReadingList>> listFavoriteReadingLists();
  Future<bool> isReadingListFavorite(String readingListId);
  Future<void> toggleReadingListFavorite(String readingListId);

  Future<List<FavoriteCharacter>> listFavoriteCharacters();
  Future<bool> isCharacterFavorite(int metronCharacterId);
  Future<void> toggleCharacterFavorite(int metronCharacterId);

  Future<List<FavoriteCreator>> listFavoriteCreators();
  Future<bool> isCreatorFavorite(int metronCreatorId);
  Future<void> toggleCreatorFavorite(int metronCreatorId);
}
