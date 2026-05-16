import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/favorite_item.dart';
import 'package:takion/src/domain/repositories/favorites_repository.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this._hiveService);

  static const _seriesBox = 'local_favorite_series_box';
  static const _issuesBox = 'local_favorite_issues_box';
  static const _readingListsBox = 'local_favorite_reading_lists_box';

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
    } else {
      final favorite = FavoriteSeries(
        metronSeriesId: metronSeriesId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _seriesToMap(favorite));
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
    } else {
      final favorite = FavoriteIssue(
        metronIssueId: metronIssueId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _issueToMap(favorite));
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
    } else {
      final favorite = FavoriteReadingList(
        readingListId: readingListId,
        createdAt: DateTime.now().toUtc(),
      );
      await box.put(key, _readingListToMap(favorite));
    }
  }
}
