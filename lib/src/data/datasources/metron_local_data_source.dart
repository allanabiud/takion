import 'package:hive_ce/hive_ce.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/dto/character_details_dto.dart';
import 'package:takion/src/data/dto/character_list_dto.dart';
import 'package:takion/src/data/dto/creator_details_dto.dart';
import 'package:takion/src/data/dto/creator_list_dto.dart';
import 'package:takion/src/data/dto/universe_details_dto.dart';
import 'package:takion/src/data/dto/universe_list_dto.dart';
import 'package:takion/src/data/dto/issue_details_dto.dart';
import 'package:takion/src/data/dto/issue_list_dto.dart';
import 'package:takion/src/data/dto/series_details_dto.dart';
import 'package:takion/src/data/dto/series_list_dto.dart';
import 'package:takion/src/data/dto/imprint_details_dto.dart';
import 'package:takion/src/data/dto/imprint_list_dto.dart';
import 'package:takion/src/data/dto/team_details_dto.dart';
import 'package:takion/src/data/dto/team_list_dto.dart';
import 'package:takion/src/data/dto/publisher_details_dto.dart';
import 'package:takion/src/data/dto/publisher_list_dto.dart';
import 'package:takion/src/data/dto/arc_details_dto.dart';
import 'package:takion/src/data/dto/arc_list_dto.dart';

class IssueSearchPageCacheMeta {
  const IssueSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesSearchPageCacheMeta {
  const SeriesSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesListPageCacheMeta {
  const SeriesListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class SeriesIssueListPageCacheMeta {
  const SeriesIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CharacterSearchPageCacheMeta {
  const CharacterSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CreatorSearchPageCacheMeta {
  const CreatorSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class UniverseSearchPageCacheMeta {
  const UniverseSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class ImprintSearchPageCacheMeta {
  const ImprintSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class CharacterIssueListPageCacheMeta {
  const CharacterIssueListPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class TeamSearchPageCacheMeta {
  const TeamSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class ArcSearchPageCacheMeta {
  const ArcSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

class PublisherSearchPageCacheMeta {
  const PublisherSearchPageCacheMeta({
    required this.count,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
}

abstract class MetronLocalDataSource {
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  );
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart);
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart);
  Future<void> cacheFocReleases(DateTime weekStart, List<IssueListDto> issues);
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart);
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart);
  Future<void> cacheIssueDetails(IssueDetailsDto issue);
  Future<IssueDetailsDto?> getIssueDetails(int issueId);
  Future<DateTime?> getIssueDetailsCachedAt(int issueId);
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<IssueSearchPageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
  });
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
  });
  Future<void> cacheSeriesDetails(SeriesDetailsDto details);
  Future<SeriesDetailsDto?> getSeriesDetails(int seriesId);
  Future<DateTime?> getSeriesDetailsCachedAt(int seriesId);
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
  });
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });
  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });
  Future<void> cacheCharacterDetails(CharacterDetailsDto details);
  Future<CharacterDetailsDto?> getCharacterDetails(int characterId);
  Future<DateTime?> getCharacterDetailsCachedAt(int characterId);
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  });
  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  });

  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheCreatorDetails(
    CreatorDetailsDto details);

  Future<CreatorDetailsDto?> getCreatorDetails(int creatorId);

  Future<DateTime?> getCreatorDetailsCachedAt(int creatorId);

  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheUniverseDetails(
    UniverseDetailsDto details);

  Future<UniverseDetailsDto?> getUniverseDetails(int universeId);

  Future<DateTime?> getUniverseDetailsCachedAt(int universeId);

  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheImprintDetails(ImprintDetailsDto details);

  Future<ImprintDetailsDto?> getImprintDetails(int imprintId);

  Future<DateTime?> getImprintDetailsCachedAt(int imprintId);

  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheTeamDetails(TeamDetailsDto details);

  Future<TeamDetailsDto?> getTeamDetails(int teamId);

  Future<DateTime?> getTeamDetailsCachedAt(int teamId);

  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cacheArcDetails(ArcDetailsDto details);

  Future<ArcDetailsDto?> getArcDetails(int arcId);

  Future<DateTime?> getArcDetailsCachedAt(int arcId);

  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  });

  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  });

  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  });

  Future<void> cachePublisherDetails(PublisherDetailsDto details);

  Future<PublisherDetailsDto?> getPublisherDetails(int publisherId);

  Future<DateTime?> getPublisherDetailsCachedAt(int publisherId);

  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });

  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  });

  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  });
}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  final HiveService _hiveService;
  static const String _weeklyBox = 'weekly_releases_box';
  static const String _focBox = 'foc_releases_box';
  static const String _issueDetailsBox = 'issue_details_box';
  static const String _issueSearchBox = 'issue_search_box';
  static const String _issueSearchMetaBox = 'issue_search_meta_box';
  static const String _issueListBox = 'issue_list_box';
  static const String _issueListMetaBox = 'issue_list_meta_box';
  static const String _seriesSearchBox = 'series_search_box';
  static const String _seriesSearchMetaBox = 'series_search_meta_box';
  static const String _seriesListBox = 'series_list_box';
  static const String _seriesListMetaBox = 'series_list_meta_box';
  static const String _seriesDetailsBox = 'series_details_box';
  static const String _seriesIssueListBox = 'series_issue_list_box';
  static const String _seriesIssueListMetaBox = 'series_issue_list_meta_box';
  static const String _characterSearchBox = 'character_search_box';
  static const String _characterSearchMetaBox = 'character_search_meta_box';
  static const String _characterDetailsBox = 'character_details_box';
  static const String _characterIssueListBox = 'character_issue_list_box';
  static const String _characterIssueListMetaBox =
      'character_issue_list_meta_box';
  static const String _creatorSearchBox = 'creator_search_box';
  static const String _creatorSearchMetaBox = 'creator_search_meta_box';
  static const String _creatorDetailsBox = 'creator_details_box';
  static const String _universeSearchBox = 'universe_search_box';
  static const String _universeSearchMetaBox = 'universe_search_meta_box';
  static const String _universeDetailsBox = 'universe_details_box';
  static const String _imprintSearchBox = 'imprint_search_box';
  static const String _imprintSearchMetaBox = 'imprint_search_meta_box';
  static const String _imprintDetailsBox = 'imprint_details_box';
  static const String _teamSearchBox = 'team_search_box';
  static const String _teamSearchMetaBox = 'team_search_meta_box';
  static const String _teamDetailsBox = 'team_details_box';
  static const String _publisherSearchBox = 'publisher_search_box';
  static const String _publisherSearchMetaBox = 'publisher_search_meta_box';
  static const String _publisherDetailsBox = 'publisher_details_box';
  static const String _publisherSeriesListBox = 'publisher_series_list_box';
  static const String _publisherSeriesListMetaBox = 'publisher_series_list_meta_box';
  static const String _arcSearchBox = 'arc_search_box';
  static const String _arcSearchMetaBox = 'arc_search_meta_box';
  static const String _arcDetailsBox = 'arc_details_box';
  static const String _arcIssueListBox = 'arc_issue_list_box';
  static const String _arcIssueListMetaBox = 'arc_issue_list_meta_box';
  static const String _cacheMetaBox = 'cache_meta_box';

  final Map<String, Box> _openedBoxes = {};

  MetronLocalDataSourceImpl(this._hiveService);

  Future<Box<T>> _getBox<T>(String boxName) async {
    final cached = _openedBoxes[boxName];
    if (cached != null && cached is Box<T>) {
      return cached;
    }

    final box = await _hiveService.openBox<T>(boxName);
    _openedBoxes[boxName] = box;
    return box;
  }

  String _getWeekKey(DateTime date) {
    // Standardize to Sunday start
    final offset = date.weekday % 7;
    final sunday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  String _getMetaKey(String key) => 'weekly_releases:$key';
  String _getFocMetaKey(String key) => 'foc_releases:$key';
  String _getIssueDetailsMetaKey(int issueId) => 'issue_details:$issueId';
  String _getSeriesDetailsMetaKey(int seriesId) => 'series_details:$seriesId';
  String _getCharacterDetailsMetaKey(int characterId) =>
      'character_details:$characterId';
  String _normalizeSearchQuery(String query) => query.trim().toLowerCase();
  String _getIssueSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getIssueSearchMetaKey(String query, int page, int limit) =>
      'issue_search:${_getIssueSearchKey(query, page, limit)}';
  String _normalizeOrdering(String? ordering) => ordering?.trim() ?? '';
  String _normalizeModifiedGt(DateTime? modifiedGt) =>
      modifiedGt?.toUtc().toIso8601String() ?? '';
  String _normalizeLimit(int? limit) =>
      limit != null && limit > 0 ? '$limit' : '';
  String _getIssueListKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      'issue_list:p$page:o${_normalizeOrdering(ordering)}:m${_normalizeModifiedGt(modifiedGt)}:l${_normalizeLimit(limit)}';
  String _getIssueListMetaKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      'issue_list:${_getIssueListKey(page: page, ordering: ordering, modifiedGt: modifiedGt, limit: limit)}';
  String _getSeriesSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getSeriesSearchMetaKey(String query, int page, int limit) =>
      'series_search:${_getSeriesSearchKey(query, page, limit)}';
  String _getSeriesListKey(int page, int limit) =>
      'series_list:p$page:l${_normalizeLimit(limit)}';
  String _getSeriesListMetaKey(int page, int limit) =>
      'series_list:${_getSeriesListKey(page, limit)}';
  String _getSeriesIssueListKey(int seriesId, int page, int limit) =>
      'series_issue_list:$seriesId:p$page:l${_normalizeLimit(limit)}';
  String _getSeriesIssueListMetaKey(int seriesId, int page, int limit) =>
      'series_issue_list:${_getSeriesIssueListKey(seriesId, page, limit)}';
  String _getCharacterSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getCharacterSearchMetaKey(String query, int page, int limit) =>
      'character_search:${_getCharacterSearchKey(query, page, limit)}';
  String _getCharacterIssueListKey(int characterId, int page, int limit) =>
      'character_issue_list:$characterId:p$page:l${_normalizeLimit(limit)}';
  String _getCharacterIssueListMetaKey(
          int characterId, int page, int limit) =>
      'character_issue_list:${_getCharacterIssueListKey(characterId, page, limit)}';

  String _getCreatorSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getCreatorSearchMetaKey(String query, int page, int limit) =>
      'creator_search:${_getCreatorSearchKey(query, page, limit)}';
  String _getCreatorDetailsMetaKey(int creatorId) =>
      'creator_details:$creatorId';
  String _getUniverseSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getUniverseSearchMetaKey(String query, int page, int limit) =>
      'universe_search:${_getUniverseSearchKey(query, page, limit)}';
  String _getUniverseDetailsMetaKey(int universeId) =>
      'universe_details:$universeId';
  String _getImprintSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getImprintSearchMetaKey(String query, int page, int limit) =>
      'imprint_search:${_getImprintSearchKey(query, page, limit)}';
  String _getImprintDetailsMetaKey(int imprintId) =>
      'imprint_details:$imprintId';
  String _getTeamSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getTeamSearchMetaKey(String query, int page, int limit) =>
      'team_search:${_getTeamSearchKey(query, page, limit)}';
  String _getTeamDetailsMetaKey(int teamId) => 'team_details:$teamId';
  String _getPublisherSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getPublisherSearchMetaKey(String query, int page, int limit) =>
      'publisher_search:${_getPublisherSearchKey(query, page, limit)}';
  String _getPublisherDetailsMetaKey(int publisherId) =>
      'publisher_details:$publisherId';
  String _getPublisherSeriesListKey(int publisherId, int page, int limit) =>
      'publisher_series_list:$publisherId:p$page:l${_normalizeLimit(limit)}';
  String _getPublisherSeriesListMetaKey(
          int publisherId, int page, int limit) =>
      'publisher_series_list:${_getPublisherSeriesListKey(publisherId, page, limit)}';

  String _getArcSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  String _getArcSearchMetaKey(String query, int page, int limit) =>
      'arc_search:${_getArcSearchKey(query, page, limit)}';
  String _getArcDetailsMetaKey(int arcId) => 'arc_details:$arcId';
  String _getArcIssueListKey(int arcId, int page, int limit) =>
      'arc_issue_list:$arcId:p$page:l${_normalizeLimit(limit)}';
  String _getArcIssueListMetaKey(int arcId, int page, int limit) =>
      'arc_issue_list:${_getArcIssueListKey(arcId, page, limit)}';

  @override
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    final box = await _getBox<List>(_weeklyBox);
    await box.put(key, issues);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(_getMetaKey(key), DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    final box = await _getBox<List>(_weeklyBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getMetaKey(key));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheFocReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    final key = _getWeekKey(weekStart);
    final box = await _getBox<List>(_focBox);
    await box.put(key, issues);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getFocMetaKey(key),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) async {
    final box = await _getBox<List>(_focBox);
    final data = box.get(_getWeekKey(weekStart));
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) async {
    final key = _getWeekKey(weekStart);
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getFocMetaKey(key));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheIssueDetails(IssueDetailsDto issue) async {
    final box = await _getBox<IssueDetailsDto>(_issueDetailsBox);
    await box.put(issue.id, issue);

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueDetailsMetaKey(issue.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<IssueDetailsDto?> getIssueDetails(int issueId) async {
    final box = await _getBox<IssueDetailsDto>(_issueDetailsBox);
    return box.get(issueId);
  }

  @override
  Future<DateTime?> getIssueDetailsCachedAt(int issueId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueDetailsMetaKey(issueId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<List>(_issueSearchBox);
    await box.put(searchKey, issues);

    final searchMetaBox = await _getBox<Map>(_issueSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getIssueSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<List>(_issueSearchBox);
    final data = box.get(searchKey);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getIssueSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getIssueSearchKey(query, page, limit);
    final box = await _getBox<Map>(_issueSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheIssueListResults(
    List<IssueListDto> issues, {
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<List>(_issueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_issueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getIssueListMetaKey(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      ),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<List>(_issueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getIssueListMetaKey(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      ),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) async {
    final key = _getIssueListKey(
      page: page,
      ordering: ordering,
      modifiedGt: modifiedGt,
      limit: limit,
    );
    final box = await _getBox<Map>(_issueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return IssueSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<List>(_seriesSearchBox);
    await box.put(searchKey, series.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_seriesSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<List>(_seriesSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(SeriesListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getSeriesSearchKey(query, page, limit);
    final box = await _getBox<Map>(_seriesSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<List>(_seriesListBox);
    await box.put(key, series.map((entry) => entry.toJson()).toList());

    final metaBox = await _getBox<Map>(_seriesListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesListMetaKey(page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<List>(_seriesListBox);
    final rawData = box.get(key);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(SeriesListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(_getSeriesListMetaKey(page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesListKey(page, limit);
    final box = await _getBox<Map>(_seriesListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheSeriesDetails(SeriesDetailsDto details) async {
    final box = await _getBox<Map>(_seriesDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getSeriesDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<SeriesDetailsDto?> getSeriesDetails(int seriesId) async {
    final box = await _getBox<Map>(_seriesDetailsBox);
    final data = box.get(seriesId);
    if (data == null) return null;
    return SeriesDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getSeriesDetailsCachedAt(int seriesId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getSeriesDetailsMetaKey(seriesId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<List>(_seriesIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_seriesIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getSeriesIssueListMetaKey(seriesId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<List>(_seriesIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getSeriesIssueListMetaKey(seriesId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesIssueListKey(seriesId, page, limit);
    final box = await _getBox<Map>(_seriesIssueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<List>(_characterSearchBox);
    await box.put(
        searchKey, characters.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_characterSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCharacterSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<List>(_characterSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(CharacterListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getCharacterSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCharacterSearchKey(query, page, limit);
    final box = await _getBox<Map>(_characterSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CharacterSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheCharacterDetails(CharacterDetailsDto details) async {
    final box = await _getBox<Map>(_characterDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCharacterDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<CharacterDetailsDto?> getCharacterDetails(int characterId) async {
    final box = await _getBox<Map>(_characterDetailsBox);
    final data = box.get(characterId);
    if (data == null) return null;
    return CharacterDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getCharacterDetailsCachedAt(int characterId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getCharacterDetailsMetaKey(characterId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<List>(_characterIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_characterIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getCharacterIssueListMetaKey(characterId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<List>(_characterIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getCharacterIssueListMetaKey(characterId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    final box = await _getBox<Map>(_characterIssueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CharacterIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<List>(_creatorSearchBox);
    await box.put(
        searchKey, creators.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_creatorSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCreatorSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<List>(_creatorSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(CreatorListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getCreatorSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getCreatorSearchKey(query, page, limit);
    final box = await _getBox<Map>(_creatorSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return CreatorSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheCreatorDetails(CreatorDetailsDto details) async {
    final box = await _getBox<Map>(_creatorDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getCreatorDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<CreatorDetailsDto?> getCreatorDetails(int creatorId) async {
    final box = await _getBox<Map>(_creatorDetailsBox);
    final data = box.get(creatorId);
    if (data == null) return null;
    return CreatorDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getCreatorDetailsCachedAt(int creatorId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getCreatorDetailsMetaKey(creatorId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<List>(_universeSearchBox);
    await box.put(
        searchKey, universes.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_universeSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getUniverseSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<List>(_universeSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(UniverseListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getUniverseSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getUniverseSearchKey(query, page, limit);
    final box = await _getBox<Map>(_universeSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return UniverseSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheUniverseDetails(UniverseDetailsDto details) async {
    final box = await _getBox<Map>(_universeDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getUniverseDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<UniverseDetailsDto?> getUniverseDetails(int universeId) async {
    final box = await _getBox<Map>(_universeDetailsBox);
    final data = box.get(universeId);
    if (data == null) return null;
    return UniverseDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getUniverseDetailsCachedAt(int universeId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getUniverseDetailsMetaKey(universeId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<List>(_imprintSearchBox);
    await box.put(
        searchKey, imprints.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_imprintSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getImprintSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<List>(_imprintSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(ImprintListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch =
        metaBox.get(_getImprintSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getImprintSearchKey(query, page, limit);
    final box = await _getBox<Map>(_imprintSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return ImprintSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheImprintDetails(ImprintDetailsDto details) async {
    final box = await _getBox<Map>(_imprintDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getImprintDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<ImprintDetailsDto?> getImprintDetails(int imprintId) async {
    final box = await _getBox<Map>(_imprintDetailsBox);
    final data = box.get(imprintId);
    if (data == null) return null;
    return ImprintDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getImprintDetailsCachedAt(int imprintId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getImprintDetailsMetaKey(imprintId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<List>(_teamSearchBox);
    await box.put(searchKey, teams.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_teamSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getTeamSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<List>(_teamSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(TeamListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getTeamSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getTeamSearchKey(query, page, limit);
    final box = await _getBox<Map>(_teamSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return TeamSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheTeamDetails(TeamDetailsDto details) async {
    final box = await _getBox<Map>(_teamDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getTeamDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<TeamDetailsDto?> getTeamDetails(int teamId) async {
    final box = await _getBox<Map>(_teamDetailsBox);
    final data = box.get(teamId);
    if (data == null) return null;
    return TeamDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getTeamDetailsCachedAt(int teamId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getTeamDetailsMetaKey(teamId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<List>(_publisherSearchBox);
    await box.put(searchKey, publishers.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_publisherSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<List>(_publisherSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(PublisherListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSearchKey(query, page, limit);
    final box = await _getBox<Map>(_publisherSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return PublisherSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cachePublisherDetails(PublisherDetailsDto details) async {
    final box = await _getBox<Map>(_publisherDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<PublisherDetailsDto?> getPublisherDetails(int publisherId) async {
    final box = await _getBox<Map>(_publisherDetailsBox);
    final data = box.get(publisherId);
    if (data == null) return null;
    return PublisherDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getPublisherDetailsCachedAt(int publisherId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherDetailsMetaKey(publisherId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<List>(_publisherSeriesListBox);
    await box.put(searchKey, series.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_publisherSeriesListMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getPublisherSeriesListMetaKey(publisherId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<List>(_publisherSeriesListBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(SeriesListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getPublisherSeriesListMetaKey(publisherId, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getPublisherSeriesListKey(publisherId, page, limit);
    final box = await _getBox<Map>(_publisherSeriesListMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<List>(_arcSearchBox);
    await box.put(searchKey, arcs.map((entry) => entry.toJson()).toList());

    final searchMetaBox = await _getBox<Map>(_arcSearchMetaBox);
    await searchMetaBox.put(searchKey, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getArcSearchMetaKey(query, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<List>(_arcSearchBox);
    final rawData = box.get(searchKey);
    if (rawData != null) {
      return rawData
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .map(ArcListDto.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getArcSearchMetaKey(query, page, limit));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final searchKey = _getArcSearchKey(query, page, limit);
    final box = await _getBox<Map>(_arcSearchMetaBox);
    final data = box.get(searchKey);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return ArcSearchPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }

  @override
  Future<void> cacheArcDetails(ArcDetailsDto details) async {
    final box = await _getBox<Map>(_arcDetailsBox);
    await box.put(details.id, details.toJson());

    final metaBox = await _getBox<int>(_cacheMetaBox);
    await metaBox.put(
      _getArcDetailsMetaKey(details.id),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<ArcDetailsDto?> getArcDetails(int arcId) async {
    final box = await _getBox<Map>(_arcDetailsBox);
    final data = box.get(arcId);
    if (data == null) return null;
    return ArcDetailsDto.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<DateTime?> getArcDetailsCachedAt(int arcId) async {
    final metaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(_getArcDetailsMetaKey(arcId));
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<List>(_arcIssueListBox);
    await box.put(key, issues);

    final metaBox = await _getBox<Map>(_arcIssueListMetaBox);
    await metaBox.put(key, {
      'count': count,
      'next': next,
      'previous': previous,
    });

    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    await cacheMetaBox.put(
      _getArcIssueListMetaKey(arcId, page, limit),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<List>(_arcIssueListBox);
    final data = box.get(key);
    if (data != null) {
      return data.cast<IssueListDto>();
    }
    return null;
  }

  @override
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final cacheMetaBox = await _getBox<int>(_cacheMetaBox);
    final epoch = cacheMetaBox.get(
      _getArcIssueListMetaKey(arcId, page, limit),
    );
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    final box = await _getBox<Map>(_arcIssueListMetaBox);
    final data = box.get(key);
    if (data == null) return null;

    final count = (data['count'] as num?)?.toInt();
    if (count == null) return null;

    return SeriesIssueListPageCacheMeta(
      count: count,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
    );
  }
}

