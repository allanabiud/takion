import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/repositories/repositories.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this._hiveService);

  static const seriesBoxName = 'local_favorite_series_box';
  static const issuesBoxName = 'local_favorite_issues_box';
  static const readingListsBoxName = 'local_favorite_reading_lists_box';
  static const charactersBoxName = 'local_favorite_characters_box';
  static const creatorsBoxName = 'local_favorite_creators_box';
  static const _seriesBox = seriesBoxName;
  static const _issuesBox = issuesBoxName;
  static const _readingListsBox = readingListsBoxName;
  static const _charactersBox = charactersBoxName;
  static const _creatorsBox = creatorsBoxName;

  final HiveService _hiveService;

  Map<String, dynamic> _seriesToMap(FavoriteSeries series) {
    return {
      'metron_series_id': series.metronSeriesId,
      'created_at': series.createdAt.toIso8601String(),
    };
  }

  FavoriteSeries _seriesFromMap(Map<String, dynamic> map) {
    return FavoriteSeries(
      metronSeriesId: map['metron_series_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> _issueToMap(FavoriteIssue issue) {
    return {
      'metron_issue_id': issue.metronIssueId,
      'created_at': issue.createdAt.toIso8601String(),
    };
  }

  FavoriteIssue _issueFromMap(Map<String, dynamic> map) {
    return FavoriteIssue(
      metronIssueId: map['metron_issue_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> _readingListToMap(FavoriteReadingList list) {
    return {
      'reading_list_id': list.readingListId,
      'created_at': list.createdAt.toIso8601String(),
    };
  }

  FavoriteReadingList _readingListFromMap(Map<String, dynamic> map) {
    return FavoriteReadingList(
      readingListId: map['reading_list_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Future<List<FavoriteSeries>> listFavoriteSeries() async {
    final box = await _hiveService.openBox<Map>(_seriesBox);
    final items = box.values
        .map((raw) => _seriesFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<bool> isSeriesFavorite(int metronSeriesId) async {
    final box = await _hiveService.openBox<Map>(_seriesBox);
    return box.containsKey(metronSeriesId.toString());
  }

  @override
  Future<void> toggleSeriesFavorite(int metronSeriesId) async {
    final box = await _hiveService.openBox<Map>(_seriesBox);
    final key = metronSeriesId.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      await _hiveService.recordDeleteTimestamp(seriesBoxName, key);
    } else {
      final favorite = FavoriteSeries(
        metronSeriesId: metronSeriesId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _seriesToMap(favorite));
      await _hiveService.recordTimestamp(seriesBoxName, key);
    }
  }

  @override
  Future<List<FavoriteIssue>> listFavoriteIssues() async {
    final box = await _hiveService.openBox<Map>(_issuesBox);
    final items = box.values
        .map((raw) => _issueFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<bool> isIssueFavorite(int metronIssueId) async {
    final box = await _hiveService.openBox<Map>(_issuesBox);
    return box.containsKey(metronIssueId.toString());
  }

  @override
  Future<void> toggleIssueFavorite(int metronIssueId) async {
    final box = await _hiveService.openBox<Map>(_issuesBox);
    final key = metronIssueId.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      await _hiveService.recordDeleteTimestamp(issuesBoxName, key);
    } else {
      final favorite = FavoriteIssue(
        metronIssueId: metronIssueId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _issueToMap(favorite));
      await _hiveService.recordTimestamp(issuesBoxName, key);
    }
  }

  @override
  Future<List<FavoriteReadingList>> listFavoriteReadingLists() async {
    final box = await _hiveService.openBox<Map>(_readingListsBox);
    final items = box.values
        .map((raw) => _readingListFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<bool> isReadingListFavorite(String readingListId) async {
    final box = await _hiveService.openBox<Map>(_readingListsBox);
    return box.containsKey(readingListId);
  }

  @override
  Future<void> toggleReadingListFavorite(String readingListId) async {
    final box = await _hiveService.openBox<Map>(_readingListsBox);
    final key = readingListId;
    if (box.containsKey(key)) {
      await box.delete(key);
      await _hiveService.recordDeleteTimestamp(readingListsBoxName, key);
    } else {
      final favorite = FavoriteReadingList(
        readingListId: readingListId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _readingListToMap(favorite));
      await _hiveService.recordTimestamp(readingListsBoxName, key);
    }
  }

  Map<String, dynamic> _characterToMap(FavoriteCharacter character) {
    return {
      'metron_character_id': character.metronCharacterId,
      'created_at': character.createdAt.toIso8601String(),
    };
  }

  FavoriteCharacter _characterFromMap(Map<String, dynamic> map) {
    return FavoriteCharacter(
      metronCharacterId: map['metron_character_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Future<List<FavoriteCharacter>> listFavoriteCharacters() async {
    final box = await _hiveService.openBox<Map>(_charactersBox);
    final items = box.values
        .map((raw) => _characterFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<bool> isCharacterFavorite(int metronCharacterId) async {
    final box = await _hiveService.openBox<Map>(_charactersBox);
    return box.containsKey(metronCharacterId.toString());
  }

  @override
  Future<void> toggleCharacterFavorite(int metronCharacterId) async {
    final box = await _hiveService.openBox<Map>(_charactersBox);
    final key = metronCharacterId.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      await _hiveService.recordDeleteTimestamp(charactersBoxName, key);
    } else {
      final favorite = FavoriteCharacter(
        metronCharacterId: metronCharacterId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _characterToMap(favorite));
      await _hiveService.recordTimestamp(charactersBoxName, key);
    }
  }

  Map<String, dynamic> _creatorToMap(FavoriteCreator creator) {
    return {
      'metron_creator_id': creator.metronCreatorId,
      'created_at': creator.createdAt.toIso8601String(),
    };
  }

  FavoriteCreator _creatorFromMap(Map<String, dynamic> map) {
    return FavoriteCreator(
      metronCreatorId: map['metron_creator_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Future<List<FavoriteCreator>> listFavoriteCreators() async {
    final box = await _hiveService.openBox<Map>(_creatorsBox);
    final items = box.values
        .map((raw) => _creatorFromMap(raw.cast<String, dynamic>()))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<bool> isCreatorFavorite(int metronCreatorId) async {
    final box = await _hiveService.openBox<Map>(_creatorsBox);
    return box.containsKey(metronCreatorId.toString());
  }

  @override
  Future<void> toggleCreatorFavorite(int metronCreatorId) async {
    final box = await _hiveService.openBox<Map>(_creatorsBox);
    final key = metronCreatorId.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      await _hiveService.recordDeleteTimestamp(creatorsBoxName, key);
    } else {
      final favorite = FavoriteCreator(
        metronCreatorId: metronCreatorId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _creatorToMap(favorite));
      await _hiveService.recordTimestamp(creatorsBoxName, key);
    }
  }
}
