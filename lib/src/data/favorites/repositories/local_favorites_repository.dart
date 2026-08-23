import "package:takion/src/data/common/drift/database.dart" as db;
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/repositories.dart";

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this._database);

  final db.AppDatabase _database;

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

  @override
  Stream<List<FavoriteSeries>> watchSeries() {
    return _database.favoriteDao.watchAllSeries().map(
      (rows) => rows.map(_seriesToDomain).toList(),
    );
  }

  @override
  Stream<bool> watchIsSeriesFavorite(int metronSeriesId) {
    return _database.favoriteDao
        .watchSeriesBySeriesId(metronSeriesId)
        .map((row) => row != null);
  }

  @override
  Future<List<FavoriteSeries>> listFavoriteSeries() async {
    final rows = await _database.favoriteDao.getAllSeries();
    return rows.map(_seriesToDomain).toList();
  }

  @override
  Future<bool> isSeriesFavorite(int metronSeriesId) async {
    final d = await _database.favoriteDao.getSeriesBySeriesId(metronSeriesId);
    return d != null;
  }

  @override
  Future<void> toggleSeriesFavorite(int metronSeriesId) async {
    await _database.favoriteDao.toggleSeries(metronSeriesId);
  }

  @override
  Stream<List<FavoriteIssue>> watchIssues() {
    return _database.favoriteDao.watchAllIssues().map(
      (rows) => rows.map(_issueToDomain).toList(),
    );
  }

  @override
  Stream<Set<int>> watchIssueIds() {
    return _database.favoriteDao.watchAllIssues().map(
      (rows) => rows.map((r) => r.metronIssueId).toSet(),
    );
  }

  @override
  Stream<bool> watchIsIssueFavorite(int metronIssueId) {
    return _database.favoriteDao
        .watchIssueByIssueId(metronIssueId)
        .map((row) => row != null);
  }

  @override
  Future<List<FavoriteIssue>> listFavoriteIssues() async {
    final rows = await _database.favoriteDao.getAllIssues();
    return rows.map(_issueToDomain).toList();
  }

  @override
  Future<bool> isIssueFavorite(int metronIssueId) async {
    final d = await _database.favoriteDao.getIssueByIssueId(metronIssueId);
    return d != null;
  }

  @override
  Future<void> toggleIssueFavorite(int metronIssueId) async {
    await _database.favoriteDao.toggleIssue(metronIssueId);
  }

  @override
  Stream<List<FavoriteReadingList>> watchReadingLists() {
    return _database.favoriteDao.watchAllReadingLists().map(
      (rows) => rows.map(_readingListToDomain).toList(),
    );
  }

  @override
  Stream<bool> watchIsReadingListFavorite(String readingListId) {
    return _database.favoriteDao.watchAllReadingLists().map(
      (list) => list.any((f) => f.readingListId == readingListId),
    );
  }

  @override
  Future<List<FavoriteReadingList>> listFavoriteReadingLists() async {
    final rows = await _database.favoriteDao.getAllReadingLists();
    return rows.map(_readingListToDomain).toList();
  }

  @override
  Future<bool> isReadingListFavorite(String readingListId) async {
    final d = await _database.favoriteDao.getReadingListByListId(readingListId);
    return d != null;
  }

  @override
  Future<void> toggleReadingListFavorite(String readingListId) async {
    await _database.favoriteDao.toggleReadingList(readingListId);
  }

  @override
  Stream<List<FavoriteCharacter>> watchCharacters() {
    return _database.favoriteDao.watchAllCharacters().map(
      (rows) => rows.map(_characterToDomain).toList(),
    );
  }

  @override
  Stream<bool> watchIsCharacterFavorite(int metronCharacterId) {
    return _database.favoriteDao.watchAllCharacters().map(
      (list) => list.any((f) => f.metronCharacterId == metronCharacterId),
    );
  }

  @override
  Future<List<FavoriteCharacter>> listFavoriteCharacters() async {
    final rows = await _database.favoriteDao.getAllCharacters();
    return rows.map(_characterToDomain).toList();
  }

  @override
  Future<bool> isCharacterFavorite(int metronCharacterId) async {
    final d = await _database.favoriteDao.getCharacterByCharacterId(
      metronCharacterId,
    );
    return d != null;
  }

  @override
  Future<void> toggleCharacterFavorite(int metronCharacterId) async {
    await _database.favoriteDao.toggleCharacter(metronCharacterId);
  }

  @override
  Stream<List<FavoriteCreator>> watchCreators() {
    return _database.favoriteDao.watchAllCreators().map(
      (rows) => rows.map(_creatorToDomain).toList(),
    );
  }

  @override
  Stream<bool> watchIsCreatorFavorite(int metronCreatorId) {
    return _database.favoriteDao.watchAllCreators().map(
      (list) => list.any((f) => f.metronCreatorId == metronCreatorId),
    );
  }

  @override
  Future<List<FavoriteCreator>> listFavoriteCreators() async {
    final rows = await _database.favoriteDao.getAllCreators();
    return rows.map(_creatorToDomain).toList();
  }

  @override
  Future<bool> isCreatorFavorite(int metronCreatorId) async {
    final d = await _database.favoriteDao.getCreatorByCreatorId(
      metronCreatorId,
    );
    return d != null;
  }

  @override
  Future<void> toggleCreatorFavorite(int metronCreatorId) async {
    await _database.favoriteDao.toggleCreator(metronCreatorId);
  }
}
