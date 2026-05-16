import 'package:takion/src/domain/entities/favorite_item.dart';

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
}
