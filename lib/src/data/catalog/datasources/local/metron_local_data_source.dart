import "package:takion/src/data/catalog/datasources/local/metron_detail_cache_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/metron_list_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/metron_releases_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/metron_search_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/dto/reading_list_dto.dart";

export "package:takion/src/data/catalog/datasources/local/metron_detail_cache_local_data_source.dart";
export "package:takion/src/data/catalog/datasources/local/metron_list_local_data_source.dart";
export "package:takion/src/data/catalog/datasources/local/metron_page_cache_keys.dart";
export "package:takion/src/data/catalog/datasources/local/metron_releases_local_data_source.dart";
export "package:takion/src/data/catalog/datasources/local/metron_search_local_data_source.dart";
export "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";

typedef IssueSearchPageCacheMeta = PageCacheMeta;
typedef SeriesSearchPageCacheMeta = PageCacheMeta;
typedef SeriesListPageCacheMeta = PageCacheMeta;
typedef SeriesIssueListPageCacheMeta = PageCacheMeta;
typedef CharacterSearchPageCacheMeta = PageCacheMeta;
typedef CreatorSearchPageCacheMeta = PageCacheMeta;
typedef UniverseSearchPageCacheMeta = PageCacheMeta;
typedef ImprintSearchPageCacheMeta = PageCacheMeta;
typedef CharacterIssueListPageCacheMeta = PageCacheMeta;
typedef TeamSearchPageCacheMeta = PageCacheMeta;
typedef TeamIssueListPageCacheMeta = PageCacheMeta;
typedef ArcSearchPageCacheMeta = PageCacheMeta;
typedef ArcListPageCacheMeta = PageCacheMeta;
typedef CharacterListPageCacheMeta = PageCacheMeta;
typedef CreatorListPageCacheMeta = PageCacheMeta;
typedef ImprintListPageCacheMeta = PageCacheMeta;
typedef PublisherListPageCacheMeta = PageCacheMeta;
typedef TeamListPageCacheMeta = PageCacheMeta;
typedef UniverseListPageCacheMeta = PageCacheMeta;
typedef ReadingListPageCacheMeta = PageCacheMeta;
typedef PublisherSearchPageCacheMeta = PageCacheMeta;

abstract class MetronLocalDataSource
    implements
        MetronReleasesLocalDataSource,
        MetronSearchLocalDataSource,
        MetronListLocalDataSource,
        MetronDetailCacheLocalDataSource {}

class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  MetronLocalDataSourceImpl(
    AppDatabase db, {
    MetronReleasesLocalDataSource? releasesLocalDataSource,
    MetronSearchLocalDataSource? searchLocalDataSource,
    MetronListLocalDataSource? listLocalDataSource,
    MetronDetailCacheLocalDataSource? detailCacheLocalDataSource,
  })  : _releases = releasesLocalDataSource ?? MetronReleasesLocalDataSourceImpl(db),
        _search = searchLocalDataSource ?? MetronSearchLocalDataSourceImpl(db),
        _list = listLocalDataSource ?? MetronListLocalDataSourceImpl(db),
        _detail = detailCacheLocalDataSource ?? MetronDetailCacheLocalDataSourceImpl(db);

  final MetronReleasesLocalDataSource _releases;
  final MetronSearchLocalDataSource _search;
  final MetronListLocalDataSource _list;
  final MetronDetailCacheLocalDataSource _detail;

  // Releases
  @override
  Future<void> cacheWeeklyReleases(DateTime weekStart, List<IssueListDto> issues) =>
      _releases.cacheWeeklyReleases(weekStart, issues);

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) =>
      _releases.getWeeklyReleases(weekStart);

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) =>
      _releases.getWeeklyReleasesCachedAt(weekStart);

  @override
  Future<void> cacheFocReleases(DateTime weekStart, List<IssueListDto> issues) =>
      _releases.cacheFocReleases(weekStart, issues);

  @override
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) =>
      _releases.getFocReleases(weekStart);

  @override
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) =>
      _releases.getFocReleasesCachedAt(weekStart);

  // Search
  @override
  Future<void> cacheIssueSearchResults(
    String query,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheIssueSearchResults(
        query,
        issues,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getIssueSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getIssueSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getIssueSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheSeriesSearchResults(
    String query,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheSeriesSearchResults(
        query,
        series,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getSeriesSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getSeriesSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getSeriesSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheCharacterSearchResults(
    String query,
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheCharacterSearchResults(
        query,
        characters,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCharacterSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCharacterSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCharacterSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheCreatorSearchResults(
    String query,
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheCreatorSearchResults(
        query,
        creators,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCreatorSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCreatorSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getCreatorSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheUniverseSearchResults(
    String query,
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheUniverseSearchResults(
        query,
        universes,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getUniverseSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getUniverseSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getUniverseSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheImprintSearchResults(
    String query,
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheImprintSearchResults(
        query,
        imprints,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getImprintSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getImprintSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getImprintSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheTeamSearchResults(
    String query,
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheTeamSearchResults(
        query,
        teams,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getTeamSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getTeamSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getTeamSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cacheArcSearchResults(
    String query,
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cacheArcSearchResults(
        query,
        arcs,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getArcSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getArcSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getArcSearchResultsMeta(query, page: page, limit: limit);

  @override
  Future<void> cachePublisherSearchResults(
    String query,
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _search.cachePublisherSearchResults(
        query,
        publishers,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getPublisherSearchResults(query, page: page, limit: limit);

  @override
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getPublisherSearchResultsCachedAt(query, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) =>
      _search.getPublisherSearchResultsMeta(query, page: page, limit: limit);

  // Lists
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
  }) =>
      _list.cacheIssueListResults(
        issues,
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<IssueListDto>?> getIssueListResults({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      _list.getIssueListResults(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      );

  @override
  Future<DateTime?> getIssueListResultsCachedAt({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      _list.getIssueListResultsCachedAt(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      );

  @override
  Future<PageCacheMeta?> getIssueListResultsMeta({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      _list.getIssueListResultsMeta(
        page: page,
        ordering: ordering,
        modifiedGt: modifiedGt,
        limit: limit,
      );

  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheSeriesListResults(
        series,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getSeriesListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getSeriesListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getSeriesListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheSeriesIssueListResults(
    int seriesId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      _list.cacheSeriesIssueListResults(
        seriesId,
        issues,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
        ordering: ordering,
        storeDateGte: storeDateGte,
        storeDateLte: storeDateLte,
      );

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      _list.getSeriesIssueListResults(
        seriesId,
        page: page,
        limit: limit,
        ordering: ordering,
        storeDateGte: storeDateGte,
        storeDateLte: storeDateLte,
      );

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      _list.getSeriesIssueListResultsCachedAt(
        seriesId,
        page: page,
        limit: limit,
        ordering: ordering,
        storeDateGte: storeDateGte,
        storeDateLte: storeDateLte,
      );

  @override
  Future<PageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      _list.getSeriesIssueListResultsMeta(
        seriesId,
        page: page,
        limit: limit,
        ordering: ordering,
        storeDateGte: storeDateGte,
        storeDateLte: storeDateLte,
      );

  @override
  Future<void> cacheCharacterListResults(
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheCharacterListResults(
        characters,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<CharacterListDto>?> getCharacterListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCharacterListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getCharacterListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCharacterListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getCharacterListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCharacterListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheCharacterIssueListResults(
    int characterId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheCharacterIssueListResults(
        characterId,
        issues,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) =>
      _list.getCharacterIssueListResults(characterId, page: page, limit: limit);

  @override
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) =>
      _list.getCharacterIssueListResultsCachedAt(
        characterId,
        page: page,
        limit: limit,
      );

  @override
  Future<PageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) =>
      _list.getCharacterIssueListResultsMeta(
        characterId,
        page: page,
        limit: limit,
      );

  @override
  Future<void> cacheCreatorListResults(
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheCreatorListResults(
        creators,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<CreatorListDto>?> getCreatorListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCreatorListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getCreatorListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCreatorListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getCreatorListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getCreatorListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheImprintListResults(
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheImprintListResults(
        imprints,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<ImprintListDto>?> getImprintListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getImprintListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getImprintListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getImprintListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getImprintListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getImprintListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cachePublisherListResults(
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cachePublisherListResults(
        publishers,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<PublisherListDto>?> getPublisherListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getPublisherListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getPublisherListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getPublisherListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getPublisherListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getPublisherListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cachePublisherSeriesListResults(
    int publisherId,
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cachePublisherSeriesListResults(
        publisherId,
        series,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) =>
      _list.getPublisherSeriesListResults(
        publisherId,
        page: page,
        limit: limit,
      );

  @override
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) =>
      _list.getPublisherSeriesListResultsCachedAt(
        publisherId,
        page: page,
        limit: limit,
      );

  @override
  Future<PageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) =>
      _list.getPublisherSeriesListResultsMeta(
        publisherId,
        page: page,
        limit: limit,
      );

  @override
  Future<void> cacheTeamListResults(
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheTeamListResults(
        teams,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<TeamListDto>?> getTeamListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getTeamListResults(page: page, limit: limit, modifiedGt: modifiedGt);

  @override
  Future<DateTime?> getTeamListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getTeamListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getTeamListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getTeamListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheTeamIssueListResults(
        teamId,
        issues,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  }) =>
      _list.getTeamIssueListResults(teamId, page: page, limit: limit);

  @override
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  }) =>
      _list.getTeamIssueListResultsCachedAt(teamId, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  }) =>
      _list.getTeamIssueListResultsMeta(teamId, page: page, limit: limit);

  @override
  Future<void> cacheUniverseListResults(
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheUniverseListResults(
        universes,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<UniverseListDto>?> getUniverseListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getUniverseListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<DateTime?> getUniverseListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getUniverseListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getUniverseListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getUniverseListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheArcListResults(
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheArcListResults(
        arcs,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<ArcListDto>?> getArcListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getArcListResults(page: page, limit: limit, modifiedGt: modifiedGt);

  @override
  Future<DateTime?> getArcListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getArcListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<PageCacheMeta?> getArcListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) =>
      _list.getArcListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
      );

  @override
  Future<void> cacheArcIssueListResults(
    int arcId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheArcIssueListResults(
        arcId,
        issues,
        page: page,
        limit: limit,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) =>
      _list.getArcIssueListResults(arcId, page: page, limit: limit);

  @override
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) =>
      _list.getArcIssueListResultsCachedAt(arcId, page: page, limit: limit);

  @override
  Future<PageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) =>
      _list.getArcIssueListResultsMeta(arcId, page: page, limit: limit);

  @override
  Future<void> cacheReadingListResults(
    List<ReadingListDto> readingLists, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
    required int count,
    String? next,
    String? previous,
  }) =>
      _list.cacheReadingListResults(
        readingLists,
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        name: name,
        listType: listType,
        attributionSource: attributionSource,
        publisher: publisher,
        count: count,
        next: next,
        previous: previous,
      );

  @override
  Future<List<ReadingListDto>?> getReadingListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) =>
      _list.getReadingListResults(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        name: name,
        listType: listType,
        attributionSource: attributionSource,
        publisher: publisher,
      );

  @override
  Future<DateTime?> getReadingListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) =>
      _list.getReadingListResultsCachedAt(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        name: name,
        listType: listType,
        attributionSource: attributionSource,
        publisher: publisher,
      );

  @override
  Future<PageCacheMeta?> getReadingListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) =>
      _list.getReadingListResultsMeta(
        page: page,
        limit: limit,
        modifiedGt: modifiedGt,
        name: name,
        listType: listType,
        attributionSource: attributionSource,
        publisher: publisher,
      );

  // Detail Cache
  @override
  Future<void> cacheIssueDetailsResponse(int issueId, Map<String, dynamic> json) =>
      _detail.cacheIssueDetailsResponse(issueId, json);

  @override
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(int issueId) =>
      _detail.getCachedIssueDetailsResponse(issueId);

  @override
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId) =>
      _detail.getCachedIssueDetailsCachedAt(issueId);

  @override
  Future<void> cacheSeriesDetailsResponse(int seriesId, Map<String, dynamic> json) =>
      _detail.cacheSeriesDetailsResponse(seriesId, json);

  @override
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(int seriesId) =>
      _detail.getCachedSeriesDetailsResponse(seriesId);

  @override
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId) =>
      _detail.getCachedSeriesDetailsCachedAt(seriesId);

  @override
  Future<void> cacheCharacterDetailsResponse(int characterId, Map<String, dynamic> json) =>
      _detail.cacheCharacterDetailsResponse(characterId, json);

  @override
  Future<Map<String, dynamic>?> getCachedCharacterDetailsResponse(int characterId) =>
      _detail.getCachedCharacterDetailsResponse(characterId);

  @override
  Future<DateTime?> getCachedCharacterDetailsCachedAt(int characterId) =>
      _detail.getCachedCharacterDetailsCachedAt(characterId);

  @override
  Future<void> cacheCreatorDetailsResponse(int creatorId, Map<String, dynamic> json) =>
      _detail.cacheCreatorDetailsResponse(creatorId, json);

  @override
  Future<Map<String, dynamic>?> getCachedCreatorDetailsResponse(int creatorId) =>
      _detail.getCachedCreatorDetailsResponse(creatorId);

  @override
  Future<DateTime?> getCachedCreatorDetailsCachedAt(int creatorId) =>
      _detail.getCachedCreatorDetailsCachedAt(creatorId);

  @override
  Future<void> cacheTeamDetailsResponse(int teamId, Map<String, dynamic> json) =>
      _detail.cacheTeamDetailsResponse(teamId, json);

  @override
  Future<Map<String, dynamic>?> getCachedTeamDetailsResponse(int teamId) =>
      _detail.getCachedTeamDetailsResponse(teamId);

  @override
  Future<DateTime?> getCachedTeamDetailsCachedAt(int teamId) =>
      _detail.getCachedTeamDetailsCachedAt(teamId);

  @override
  Future<void> cacheUniverseDetailsResponse(int universeId, Map<String, dynamic> json) =>
      _detail.cacheUniverseDetailsResponse(universeId, json);

  @override
  Future<Map<String, dynamic>?> getCachedUniverseDetailsResponse(int universeId) =>
      _detail.getCachedUniverseDetailsResponse(universeId);

  @override
  Future<DateTime?> getCachedUniverseDetailsCachedAt(int universeId) =>
      _detail.getCachedUniverseDetailsCachedAt(universeId);

  @override
  Future<void> cacheImprintDetailsResponse(int imprintId, Map<String, dynamic> json) =>
      _detail.cacheImprintDetailsResponse(imprintId, json);

  @override
  Future<Map<String, dynamic>?> getCachedImprintDetailsResponse(int imprintId) =>
      _detail.getCachedImprintDetailsResponse(imprintId);

  @override
  Future<DateTime?> getCachedImprintDetailsCachedAt(int imprintId) =>
      _detail.getCachedImprintDetailsCachedAt(imprintId);

  @override
  Future<void> cachePublisherDetailsResponse(int publisherId, Map<String, dynamic> json) =>
      _detail.cachePublisherDetailsResponse(publisherId, json);

  @override
  Future<Map<String, dynamic>?> getCachedPublisherDetailsResponse(int publisherId) =>
      _detail.getCachedPublisherDetailsResponse(publisherId);

  @override
  Future<DateTime?> getCachedPublisherDetailsCachedAt(int publisherId) =>
      _detail.getCachedPublisherDetailsCachedAt(publisherId);

  @override
  Future<void> cacheArcDetailsResponse(int arcId, Map<String, dynamic> json) =>
      _detail.cacheArcDetailsResponse(arcId, json);

  @override
  Future<Map<String, dynamic>?> getCachedArcDetailsResponse(int arcId) =>
      _detail.getCachedArcDetailsResponse(arcId);

  @override
  Future<DateTime?> getCachedArcDetailsCachedAt(int arcId) =>
      _detail.getCachedArcDetailsCachedAt(arcId);
}
