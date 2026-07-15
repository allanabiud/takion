import 'package:hive_ce/hive_ce.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/dto/dto.dart';

part 'metron_local_data_source_releases.dart';
part 'metron_local_data_source_issues.dart';
part 'metron_local_data_source_series.dart';
part 'metron_local_data_source_characters.dart';
part 'metron_local_data_source_creators.dart';
part 'metron_local_data_source_universes.dart';
part 'metron_local_data_source_imprints.dart';
part 'metron_local_data_source_teams.dart';
part 'metron_local_data_source_publishers.dart';
part 'metron_local_data_source_arcs.dart';

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

// ignore_for_file: unused_element

mixin _DataSourceState {
  HiveService get _hiveService;
  String get _weeklyBox;
  String get _focBox;
  String get _issueDetailsBox;
  String get _issueSearchBox;
  String get _issueSearchMetaBox;
  String get _issueListBox;
  String get _issueListMetaBox;
  String get _seriesSearchBox;
  String get _seriesSearchMetaBox;
  String get _seriesListBox;
  String get _seriesListMetaBox;
  String get _seriesDetailsBox;
  String get _seriesIssueListBox;
  String get _seriesIssueListMetaBox;
  String get _characterSearchBox;
  String get _characterSearchMetaBox;
  String get _characterDetailsBox;
  String get _characterIssueListBox;
  String get _characterIssueListMetaBox;
  String get _creatorSearchBox;
  String get _creatorSearchMetaBox;
  String get _creatorDetailsBox;
  String get _universeSearchBox;
  String get _universeSearchMetaBox;
  String get _universeDetailsBox;
  String get _imprintSearchBox;
  String get _imprintSearchMetaBox;
  String get _imprintDetailsBox;
  String get _teamSearchBox;
  String get _teamSearchMetaBox;
  String get _teamDetailsBox;
  String get _publisherSearchBox;
  String get _publisherSearchMetaBox;
  String get _publisherDetailsBox;
  String get _publisherSeriesListBox;
  String get _publisherSeriesListMetaBox;
  String get _arcSearchBox;
  String get _arcSearchMetaBox;
  String get _arcDetailsBox;
  String get _arcIssueListBox;
  String get _arcIssueListMetaBox;
  String get _cacheMetaBox;
  Map<String, Box> get _openedBoxes;
  Future<Box<T>> _getBox<T>(String boxName);
  String _getWeekKey(DateTime date);
  String _getMetaKey(String key);
  String _getFocMetaKey(String key);
  String _getIssueDetailsMetaKey(int issueId);
  String _getSeriesDetailsMetaKey(int seriesId);
  String _getCharacterDetailsMetaKey(int characterId);
  String _normalizeSearchQuery(String query);
  String _getIssueSearchKey(String query, int page, int limit);
  String _getIssueSearchMetaKey(String query, int page, int limit);
  String _normalizeOrdering(String? ordering);
  String _normalizeModifiedGt(DateTime? modifiedGt);
  String _normalizeLimit(int? limit);
  String _getIssueListKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  String _getIssueListMetaKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  });
  String _getSeriesSearchKey(String query, int page, int limit);
  String _getSeriesSearchMetaKey(String query, int page, int limit);
  String _getSeriesListKey(int page, int limit);
  String _getSeriesListMetaKey(int page, int limit);
  String _getSeriesIssueListKey(int seriesId, int page, int limit);
  String _getSeriesIssueListMetaKey(int seriesId, int page, int limit);
  String _getCharacterSearchKey(String query, int page, int limit);
  String _getCharacterSearchMetaKey(String query, int page, int limit);
  String _getCharacterIssueListKey(int characterId, int page, int limit);
  String _getCharacterIssueListMetaKey(int characterId, int page, int limit);
  String _getCreatorSearchKey(String query, int page, int limit);
  String _getCreatorSearchMetaKey(String query, int page, int limit);
  String _getCreatorDetailsMetaKey(int creatorId);
  String _getUniverseSearchKey(String query, int page, int limit);
  String _getUniverseSearchMetaKey(String query, int page, int limit);
  String _getUniverseDetailsMetaKey(int universeId);
  String _getImprintSearchKey(String query, int page, int limit);
  String _getImprintSearchMetaKey(String query, int page, int limit);
  String _getImprintDetailsMetaKey(int imprintId);
  String _getTeamSearchKey(String query, int page, int limit);
  String _getTeamSearchMetaKey(String query, int page, int limit);
  String _getTeamDetailsMetaKey(int teamId);
  String _getPublisherSearchKey(String query, int page, int limit);
  String _getPublisherSearchMetaKey(String query, int page, int limit);
  String _getPublisherDetailsMetaKey(int publisherId);
  String _getPublisherSeriesListKey(int publisherId, int page, int limit);
  String _getPublisherSeriesListMetaKey(int publisherId, int page, int limit);
  String _getArcSearchKey(String query, int page, int limit);
  String _getArcSearchMetaKey(String query, int page, int limit);
  String _getArcDetailsMetaKey(int arcId);
  String _getArcIssueListKey(int arcId, int page, int limit);
  String _getArcIssueListMetaKey(int arcId, int page, int limit);
}

class MetronLocalDataSourceImpl with
    _DataSourceState,
    _ReleasesDataSourceMixin,
    _IssuesDataSourceMixin,
    _SeriesDataSourceMixin,
    _CharactersDataSourceMixin,
    _CreatorsDataSourceMixin,
    _UniversesDataSourceMixin,
    _ImprintsDataSourceMixin,
    _TeamsDataSourceMixin,
    _PublishersDataSourceMixin,
    _ArcsDataSourceMixin
    implements MetronLocalDataSource {
  @override
  final HiveService _hiveService;
  @override final String _weeklyBox = 'weekly_releases_box';
  @override final String _focBox = 'foc_releases_box';
  @override final String _issueDetailsBox = 'issue_details_box';
  @override final String _issueSearchBox = 'issue_search_box';
  @override final String _issueSearchMetaBox = 'issue_search_meta_box';
  @override final String _issueListBox = 'issue_list_box';
  @override final String _issueListMetaBox = 'issue_list_meta_box';
  @override final String _seriesSearchBox = 'series_search_box';
  @override final String _seriesSearchMetaBox = 'series_search_meta_box';
  @override final String _seriesListBox = 'series_list_box';
  @override final String _seriesListMetaBox = 'series_list_meta_box';
  @override final String _seriesDetailsBox = 'series_details_box';
  @override final String _seriesIssueListBox = 'series_issue_list_box';
  @override final String _seriesIssueListMetaBox = 'series_issue_list_meta_box';
  @override final String _characterSearchBox = 'character_search_box';
  @override final String _characterSearchMetaBox = 'character_search_meta_box';
  @override final String _characterDetailsBox = 'character_details_box';
  @override final String _characterIssueListBox = 'character_issue_list_box';
  @override final String _characterIssueListMetaBox = 'character_issue_list_meta_box';
  @override final String _creatorSearchBox = 'creator_search_box';
  @override final String _creatorSearchMetaBox = 'creator_search_meta_box';
  @override final String _creatorDetailsBox = 'creator_details_box';
  @override final String _universeSearchBox = 'universe_search_box';
  @override final String _universeSearchMetaBox = 'universe_search_meta_box';
  @override final String _universeDetailsBox = 'universe_details_box';
  @override final String _imprintSearchBox = 'imprint_search_box';
  @override final String _imprintSearchMetaBox = 'imprint_search_meta_box';
  @override final String _imprintDetailsBox = 'imprint_details_box';
  @override final String _teamSearchBox = 'team_search_box';
  @override final String _teamSearchMetaBox = 'team_search_meta_box';
  @override final String _teamDetailsBox = 'team_details_box';
  @override final String _publisherSearchBox = 'publisher_search_box';
  @override final String _publisherSearchMetaBox = 'publisher_search_meta_box';
  @override final String _publisherDetailsBox = 'publisher_details_box';
  @override final String _publisherSeriesListBox = 'publisher_series_list_box';
  @override final String _publisherSeriesListMetaBox = 'publisher_series_list_meta_box';
  @override final String _arcSearchBox = 'arc_search_box';
  @override final String _arcSearchMetaBox = 'arc_search_meta_box';
  @override final String _arcDetailsBox = 'arc_details_box';
  @override final String _arcIssueListBox = 'arc_issue_list_box';
  @override final String _arcIssueListMetaBox = 'arc_issue_list_meta_box';
  @override final String _cacheMetaBox = 'cache_meta_box';
  @override final Map<String, Box> _openedBoxes = {};

  MetronLocalDataSourceImpl(this._hiveService);

  @override
  Future<Box<T>> _getBox<T>(String boxName) async {
    final cached = _openedBoxes[boxName];
    if (cached != null && cached is Box<T>) {
      return cached;
    }

    final box = await _hiveService.openBox<T>(boxName);
    _openedBoxes[boxName] = box;
    return box;
  }

  @override
  String _getWeekKey(DateTime date) {
    final offset = date.weekday % 7;
    final sunday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  @override
  String _getMetaKey(String key) => 'weekly_releases:$key';
  @override
  String _getFocMetaKey(String key) => 'foc_releases:$key';
  @override
  String _getIssueDetailsMetaKey(int issueId) => 'issue_details:$issueId';
  @override
  String _getSeriesDetailsMetaKey(int seriesId) => 'series_details:$seriesId';
  @override
  String _getCharacterDetailsMetaKey(int characterId) =>
      'character_details:$characterId';
  @override
  String _normalizeSearchQuery(String query) => query.trim().toLowerCase();
  @override
  String _getIssueSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getIssueSearchMetaKey(String query, int page, int limit) =>
      'issue_search:${_getIssueSearchKey(query, page, limit)}';
  @override
  String _normalizeOrdering(String? ordering) => ordering?.trim() ?? '';
  @override
  String _normalizeModifiedGt(DateTime? modifiedGt) =>
      modifiedGt?.toUtc().toIso8601String() ?? '';
  @override
  String _normalizeLimit(int? limit) =>
      limit != null && limit > 0 ? '$limit' : '';
  @override
  String _getIssueListKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      'issue_list:p$page:o${_normalizeOrdering(ordering)}:m${_normalizeModifiedGt(modifiedGt)}:l${_normalizeLimit(limit)}';
  @override
  String _getIssueListMetaKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      'issue_list:${_getIssueListKey(page: page, ordering: ordering, modifiedGt: modifiedGt, limit: limit)}';
  @override
  String _getSeriesSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getSeriesSearchMetaKey(String query, int page, int limit) =>
      'series_search:${_getSeriesSearchKey(query, page, limit)}';
  @override
  String _getSeriesListKey(int page, int limit) =>
      'series_list:p$page:l${_normalizeLimit(limit)}';
  @override
  String _getSeriesListMetaKey(int page, int limit) =>
      'series_list:${_getSeriesListKey(page, limit)}';
  @override
  String _getSeriesIssueListKey(int seriesId, int page, int limit) =>
      'series_issue_list:$seriesId:p$page:l${_normalizeLimit(limit)}';
  @override
  String _getSeriesIssueListMetaKey(int seriesId, int page, int limit) =>
      'series_issue_list:${_getSeriesIssueListKey(seriesId, page, limit)}';
  @override
  String _getCharacterSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getCharacterSearchMetaKey(String query, int page, int limit) =>
      'character_search:${_getCharacterSearchKey(query, page, limit)}';
  @override
  String _getCharacterIssueListKey(int characterId, int page, int limit) =>
      'character_issue_list:$characterId:p$page:l${_normalizeLimit(limit)}';
  @override
  String _getCharacterIssueListMetaKey(
          int characterId, int page, int limit) =>
      'character_issue_list:${_getCharacterIssueListKey(characterId, page, limit)}';

  @override
  String _getCreatorSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getCreatorSearchMetaKey(String query, int page, int limit) =>
      'creator_search:${_getCreatorSearchKey(query, page, limit)}';
  @override
  String _getCreatorDetailsMetaKey(int creatorId) =>
      'creator_details:$creatorId';
  @override
  String _getUniverseSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getUniverseSearchMetaKey(String query, int page, int limit) =>
      'universe_search:${_getUniverseSearchKey(query, page, limit)}';
  @override
  String _getUniverseDetailsMetaKey(int universeId) =>
      'universe_details:$universeId';
  @override
  String _getImprintSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getImprintSearchMetaKey(String query, int page, int limit) =>
      'imprint_search:${_getImprintSearchKey(query, page, limit)}';
  @override
  String _getImprintDetailsMetaKey(int imprintId) =>
      'imprint_details:$imprintId';
  @override
  String _getTeamSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getTeamSearchMetaKey(String query, int page, int limit) =>
      'team_search:${_getTeamSearchKey(query, page, limit)}';
  @override
  String _getTeamDetailsMetaKey(int teamId) => 'team_details:$teamId';
  @override
  String _getPublisherSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getPublisherSearchMetaKey(String query, int page, int limit) =>
      'publisher_search:${_getPublisherSearchKey(query, page, limit)}';
  @override
  String _getPublisherDetailsMetaKey(int publisherId) =>
      'publisher_details:$publisherId';
  @override
  String _getPublisherSeriesListKey(int publisherId, int page, int limit) =>
      'publisher_series_list:$publisherId:p$page:l${_normalizeLimit(limit)}';
  @override
  String _getPublisherSeriesListMetaKey(
          int publisherId, int page, int limit) =>
      'publisher_series_list:${_getPublisherSeriesListKey(publisherId, page, limit)}';

  @override
  String _getArcSearchKey(String query, int page, int limit) =>
      '${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}';
  @override
  String _getArcSearchMetaKey(String query, int page, int limit) =>
      'arc_search:${_getArcSearchKey(query, page, limit)}';
  @override
  String _getArcDetailsMetaKey(int arcId) => 'arc_details:$arcId';
  @override
  String _getArcIssueListKey(int arcId, int page, int limit) =>
      'arc_issue_list:$arcId:p$page:l${_normalizeLimit(limit)}';
  @override
  String _getArcIssueListMetaKey(int arcId, int page, int limit) =>
      'arc_issue_list:${_getArcIssueListKey(arcId, page, limit)}';
}
