import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/dto/reading_list_dto.dart";

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
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
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
  });
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  });
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
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

  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  });
  Future<TeamIssueListPageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
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

  Future<void> cacheIssueDetailsResponse(
    int issueId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(int issueId);
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId);

  Future<void> cacheSeriesDetailsResponse(
    int seriesId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(int seriesId);
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId);

  Future<void> cacheCharacterDetailsResponse(
    int characterId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedCharacterDetailsResponse(int characterId);
  Future<DateTime?> getCachedCharacterDetailsCachedAt(int characterId);

  Future<void> cacheCreatorDetailsResponse(
    int creatorId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedCreatorDetailsResponse(int creatorId);
  Future<DateTime?> getCachedCreatorDetailsCachedAt(int creatorId);

  Future<void> cacheTeamDetailsResponse(
    int teamId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedTeamDetailsResponse(int teamId);
  Future<DateTime?> getCachedTeamDetailsCachedAt(int teamId);

  Future<void> cacheUniverseDetailsResponse(
    int universeId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedUniverseDetailsResponse(int universeId);
  Future<DateTime?> getCachedUniverseDetailsCachedAt(int universeId);

  Future<void> cacheImprintDetailsResponse(
    int imprintId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedImprintDetailsResponse(int imprintId);
  Future<DateTime?> getCachedImprintDetailsCachedAt(int imprintId);

  Future<void> cachePublisherDetailsResponse(
    int publisherId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedPublisherDetailsResponse(int publisherId);
  Future<DateTime?> getCachedPublisherDetailsCachedAt(int publisherId);

  Future<void> cacheArcDetailsResponse(
    int arcId,
    Map<String, dynamic> json,
  );
  Future<Map<String, dynamic>?> getCachedArcDetailsResponse(int arcId);
  Future<DateTime?> getCachedArcDetailsCachedAt(int arcId);

  Future<void> cacheArcListResults(
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ArcListDto>?> getArcListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getArcListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<ArcListPageCacheMeta?> getArcListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheCharacterListResults(
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CharacterListDto>?> getCharacterListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getCharacterListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<CharacterListPageCacheMeta?> getCharacterListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheCreatorListResults(
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<CreatorListDto>?> getCreatorListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getCreatorListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<CreatorListPageCacheMeta?> getCreatorListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheImprintListResults(
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<ImprintListDto>?> getImprintListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getImprintListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<ImprintListPageCacheMeta?> getImprintListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cachePublisherListResults(
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<PublisherListDto>?> getPublisherListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getPublisherListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<PublisherListPageCacheMeta?> getPublisherListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheTeamListResults(
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<TeamListDto>?> getTeamListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getTeamListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<TeamListPageCacheMeta?> getTeamListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

  Future<void> cacheUniverseListResults(
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  });
  Future<List<UniverseListDto>?> getUniverseListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<DateTime?> getUniverseListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });
  Future<UniverseListPageCacheMeta?> getUniverseListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  });

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
  });
  Future<List<ReadingListDto>?> getReadingListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
  Future<DateTime?> getReadingListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
  Future<ReadingListPageCacheMeta?> getReadingListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  });
}
class MetronLocalDataSourceImpl implements MetronLocalDataSource {
  MetronLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  late final PagedLocalCache<IssueListDto> _weeklyReleases =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "weekly_releases",
        entityType: "weekly_releases",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
        withMeta: false,
      );

  late final PagedLocalCache<IssueListDto> _focReleases =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "foc_releases",
        entityType: "foc_releases",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
        withMeta: false,
      );

  late final PagedLocalCache<IssueListDto> _issueSearch =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "issue_search",
        entityType: "issue_search",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<IssueListDto> _issueList =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "issue_list",
        entityType: "issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<SeriesListDto> _seriesSearch =
      PagedLocalCache<SeriesListDto>(
        db: _db,
        cacheKeyPrefix: "series_search",
        entityType: "series_search",
        fromJson: SeriesListDto.fromJson,
        toJson: (s) => s.toJson(),
      );

  late final PagedLocalCache<SeriesListDto> _seriesList =
      PagedLocalCache<SeriesListDto>(
        db: _db,
        cacheKeyPrefix: "series_list",
        entityType: "series_list",
        fromJson: SeriesListDto.fromJson,
        toJson: (s) => s.toJson(),
      );

  late final PagedLocalCache<IssueListDto> _seriesIssueList =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "series_issue_list",
        entityType: "series_issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<CharacterListDto> _characterSearch =
      PagedLocalCache<CharacterListDto>(
        db: _db,
        cacheKeyPrefix: "character_search",
        entityType: "character_search",
        fromJson: CharacterListDto.fromJson,
        toJson: (c) => c.toJson(),
      );

  late final PagedLocalCache<IssueListDto> _characterIssueList =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "character_issue_list",
        entityType: "character_issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<IssueListDto> _teamIssueList =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "team_issue_list",
        entityType: "team_issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<CreatorListDto> _creatorSearch =
      PagedLocalCache<CreatorListDto>(
        db: _db,
        cacheKeyPrefix: "creator_search",
        entityType: "creator_search",
        fromJson: CreatorListDto.fromJson,
        toJson: (c) => c.toJson(),
      );

  late final PagedLocalCache<UniverseListDto> _universeSearch =
      PagedLocalCache<UniverseListDto>(
        db: _db,
        cacheKeyPrefix: "universe_search",
        entityType: "universe_search",
        fromJson: UniverseListDto.fromJson,
        toJson: (u) => u.toJson(),
      );

  late final PagedLocalCache<ImprintListDto> _imprintSearch =
      PagedLocalCache<ImprintListDto>(
        db: _db,
        cacheKeyPrefix: "imprint_search",
        entityType: "imprint_search",
        fromJson: ImprintListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<TeamListDto> _teamSearch =
      PagedLocalCache<TeamListDto>(
        db: _db,
        cacheKeyPrefix: "team_search",
        entityType: "team_search",
        fromJson: TeamListDto.fromJson,
        toJson: (t) => t.toJson(),
      );

  late final PagedLocalCache<ArcListDto> _arcSearch = PagedLocalCache<
    ArcListDto
  >(
    db: _db,
    cacheKeyPrefix: "arc_search",
    entityType: "arc_search",
    fromJson: ArcListDto.fromJson,
    toJson: (a) => a.toJson(),
  );

  late final PagedLocalCache<IssueListDto> _arcIssueList =
      PagedLocalCache<IssueListDto>(
        db: _db,
        cacheKeyPrefix: "arc_issue_list",
        entityType: "arc_issue_list",
        fromJson: IssueListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<PublisherListDto> _publisherSearch =
      PagedLocalCache<PublisherListDto>(
        db: _db,
        cacheKeyPrefix: "publisher_search",
        entityType: "publisher_search",
        fromJson: PublisherListDto.fromJson,
        toJson: (p) => p.toJson(),
      );

  late final PagedLocalCache<SeriesListDto> _publisherSeriesList =
      PagedLocalCache<SeriesListDto>(
        db: _db,
        cacheKeyPrefix: "publisher_series_list",
        entityType: "publisher_series_list",
        fromJson: SeriesListDto.fromJson,
        toJson: (s) => s.toJson(),
      );

  late final PagedLocalCache<ArcListDto> _arcList = PagedLocalCache<ArcListDto>(
    db: _db,
    cacheKeyPrefix: "arc_list",
    entityType: "arc_list",
    fromJson: ArcListDto.fromJson,
    toJson: (a) => a.toJson(),
  );

  late final PagedLocalCache<CharacterListDto> _characterList =
      PagedLocalCache<CharacterListDto>(
        db: _db,
        cacheKeyPrefix: "character_list",
        entityType: "character_list",
        fromJson: CharacterListDto.fromJson,
        toJson: (c) => c.toJson(),
      );

  late final PagedLocalCache<CreatorListDto> _creatorList =
      PagedLocalCache<CreatorListDto>(
        db: _db,
        cacheKeyPrefix: "creator_list",
        entityType: "creator_list",
        fromJson: CreatorListDto.fromJson,
        toJson: (c) => c.toJson(),
      );

  late final PagedLocalCache<ImprintListDto> _imprintList =
      PagedLocalCache<ImprintListDto>(
        db: _db,
        cacheKeyPrefix: "imprint_list",
        entityType: "imprint_list",
        fromJson: ImprintListDto.fromJson,
        toJson: (i) => i.toJson(),
      );

  late final PagedLocalCache<PublisherListDto> _publisherList =
      PagedLocalCache<PublisherListDto>(
        db: _db,
        cacheKeyPrefix: "publisher_list",
        entityType: "publisher_list",
        fromJson: PublisherListDto.fromJson,
        toJson: (p) => p.toJson(),
      );

  late final PagedLocalCache<TeamListDto> _teamList = PagedLocalCache<
    TeamListDto
  >(
    db: _db,
    cacheKeyPrefix: "team_list",
    entityType: "team_list",
    fromJson: TeamListDto.fromJson,
    toJson: (t) => t.toJson(),
  );

  late final PagedLocalCache<UniverseListDto> _universeList =
      PagedLocalCache<UniverseListDto>(
        db: _db,
        cacheKeyPrefix: "universe_list",
        entityType: "universe_list",
        fromJson: UniverseListDto.fromJson,
        toJson: (u) => u.toJson(),
      );

  late final PagedLocalCache<ReadingListDto> _readingList =
      PagedLocalCache<ReadingListDto>(
        db: _db,
        cacheKeyPrefix: "reading_list",
        entityType: "reading_list",
        fromJson: ReadingListDto.fromJson,
        toJson: (r) => r.toJson(),
      );

  late final DetailsLocalCache _issueDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "issue_details",
    entityType: "issue_details",
  );

  late final DetailsLocalCache _seriesDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "series_details",
    entityType: "series_details",
  );

  late final DetailsLocalCache _characterDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "character_details",
    entityType: "character_details",
  );

  late final DetailsLocalCache _creatorDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "creator_details",
    entityType: "creator_details",
  );

  late final DetailsLocalCache _teamDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "team_details",
    entityType: "team_details",
  );

  late final DetailsLocalCache _universeDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "universe_details",
    entityType: "universe_details",
  );

  late final DetailsLocalCache _imprintDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "imprint_details",
    entityType: "imprint_details",
  );

  late final DetailsLocalCache _publisherDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "publisher_details",
    entityType: "publisher_details",
  );

  late final DetailsLocalCache _arcDetails = DetailsLocalCache(
    db: _db,
    cacheKeyPrefix: "arc_details",
    entityType: "arc_details",
  );

  // Key normalization helpers
  String _getWeekKey(DateTime date) {
    final offset = date.weekday % 7;
    final sunday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  String _normalizeSearchQuery(String query) => query.trim().toLowerCase();
  String _normalizeLimit(int? limit) =>
      limit != null && limit > 0 ? "$limit" : "";
  String _normalizeOrdering(String? ordering) => ordering?.trim() ?? "";
  String _normalizeModifiedGt(DateTime? modifiedGt) =>
      modifiedGt?.toUtc().toIso8601String() ?? "";
  String _normalizeStoreDate(DateTime? d) => d == null
      ? ""
      : DateFormatter.isoDate(d);

  String _getIssueSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getIssueListKey({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      "issue_list:p$page:o${_normalizeOrdering(ordering)}:m${_normalizeModifiedGt(modifiedGt)}:l${_normalizeLimit(limit)}";

  String _getSeriesIssueListKey(
    int seriesId,
    int page,
    int limit, {
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      "series_issue_list:$seriesId:p$page:l${_normalizeLimit(limit)}:o${_normalizeOrdering(ordering)}:a${_normalizeStoreDate(storeDateGte)}:b${_normalizeStoreDate(storeDateLte)}";

  String _getSeriesSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getSeriesListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "series_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getCharacterSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getCharacterIssueListKey(int characterId, int page, int limit) =>
      "character_issue_list:$characterId:p$page:l${_normalizeLimit(limit)}";

  String _getCreatorSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getUniverseSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getImprintSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getTeamSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getTeamIssueListKey(int teamId, int page, int limit) =>
      "team_issue_list:$teamId:p$page:l${_normalizeLimit(limit)}";

  String _getPublisherSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getPublisherSeriesListKey(int publisherId, int page, int limit) =>
      "publisher_series_list:$publisherId:p$page:l${_normalizeLimit(limit)}";

  String _getArcSearchKey(String query, int page, int limit) =>
      "${_normalizeSearchQuery(query)}::p$page:l${_normalizeLimit(limit)}";

  String _getArcIssueListKey(int arcId, int page, int limit) =>
      "arc_issue_list:$arcId:p$page:l${_normalizeLimit(limit)}";

  String _getArcListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "arc_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getCharacterListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "character_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getCreatorListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "creator_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getImprintListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "imprint_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getPublisherListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "publisher_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getTeamListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "team_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getUniverseListKey(int page, int limit, {DateTime? modifiedGt}) =>
      "universe_list:p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}";

  String _getReadingListKey(
    int page,
    int limit, {
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) =>
      'reading_list:${name != null ? '${_normalizeSearchQuery(name)}::' : ''}'
      "p$page:l${_normalizeLimit(limit)}:m${_normalizeModifiedGt(modifiedGt)}"
      ':lt${(listType ?? '').trim().toLowerCase()}'
      ':as${(attributionSource ?? '').trim().toLowerCase()}'
      ':pu${(publisher ?? '').trim().toLowerCase()}';


  @override
  Future<void> cacheWeeklyReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    await _weeklyReleases.cache(_getWeekKey(weekStart), issues);
  }

  @override
  Future<List<IssueListDto>?> getWeeklyReleases(DateTime weekStart) async {
    return _weeklyReleases.get(_getWeekKey(weekStart));
  }

  @override
  Future<DateTime?> getWeeklyReleasesCachedAt(DateTime weekStart) async {
    return _weeklyReleases.cachedAt(_getWeekKey(weekStart));
  }

  @override
  Future<void> cacheFocReleases(
    DateTime weekStart,
    List<IssueListDto> issues,
  ) async {
    await _focReleases.cache(_getWeekKey(weekStart), issues);
  }

  @override
  Future<List<IssueListDto>?> getFocReleases(DateTime weekStart) async {
    return _focReleases.get(_getWeekKey(weekStart));
  }

  @override
  Future<DateTime?> getFocReleasesCachedAt(DateTime weekStart) async {
    return _focReleases.cachedAt(_getWeekKey(weekStart));
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
    final key = _getIssueSearchKey(query, page, limit);
    await _issueSearch.cache(key, issues, count: count, next: next, previous: previous);
  }

  @override
  Future<List<IssueListDto>?> getIssueSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    return _issueSearch.get(key);
  }

  @override
  Future<DateTime?> getIssueSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    return _issueSearch.cachedAt(key);
  }

  @override
  Future<IssueSearchPageCacheMeta?> getIssueSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getIssueSearchKey(query, page, limit);
    return _issueSearch.meta(key);
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
    await _issueList.cache(key, issues, count: count, next: next, previous: previous);
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
    return _issueList.get(key);
  }

  @override
  Future<DateTime?> getIssueListResultsCachedAt({
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
    return _issueList.cachedAt(key);
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
    return _issueList.meta(key);
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
    final key = _getSeriesSearchKey(query, page, limit);
    await _seriesSearch.cache(key, series, count: count, next: next, previous: previous);
  }

  @override
  Future<List<SeriesListDto>?> getSeriesSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    return _seriesSearch.get(key);
  }

  @override
  Future<DateTime?> getSeriesSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    return _seriesSearch.cachedAt(key);
  }

  @override
  Future<SeriesSearchPageCacheMeta?> getSeriesSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getSeriesSearchKey(query, page, limit);
    return _seriesSearch.meta(key);
  }

  @override
  Future<void> cacheSeriesListResults(
    List<SeriesListDto> series, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    await _seriesList.cache(key, series, count: count, next: next, previous: previous);
  }

  @override
  Future<List<SeriesListDto>?> getSeriesListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    return _seriesList.get(key);
  }

  @override
  Future<DateTime?> getSeriesListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    return _seriesList.cachedAt(key);
  }

  @override
  Future<SeriesListPageCacheMeta?> getSeriesListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getSeriesListKey(page, limit, modifiedGt: modifiedGt);
    return _seriesList.meta(key);
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
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = _getSeriesIssueListKey(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    await _seriesIssueList.cache(key, issues, count: count, next: next, previous: previous);
  }

  @override
  Future<List<IssueListDto>?> getSeriesIssueListResults(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = _getSeriesIssueListKey(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.get(key);
  }

  @override
  Future<DateTime?> getSeriesIssueListResultsCachedAt(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = _getSeriesIssueListKey(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.cachedAt(key);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getSeriesIssueListResultsMeta(
    int seriesId, {
    required int page,
    required int limit,
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) async {
    final key = _getSeriesIssueListKey(
      seriesId,
      page,
      limit,
      ordering: ordering,
      storeDateGte: storeDateGte,
      storeDateLte: storeDateLte,
    );
    return _seriesIssueList.meta(key);
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
    final key = _getCharacterSearchKey(query, page, limit);
    await _characterSearch.cache(key, characters, count: count, next: next, previous: previous);
  }

  @override
  Future<List<CharacterListDto>?> getCharacterSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    return _characterSearch.get(key);
  }

  @override
  Future<DateTime?> getCharacterSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    return _characterSearch.cachedAt(key);
  }

  @override
  Future<CharacterSearchPageCacheMeta?> getCharacterSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterSearchKey(query, page, limit);
    return _characterSearch.meta(key);
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
    await _characterIssueList.cache(key, issues, count: count, next: next, previous: previous);
  }

  @override
  Future<List<IssueListDto>?> getCharacterIssueListResults(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    return _characterIssueList.get(key);
  }

  @override
  Future<DateTime?> getCharacterIssueListResultsCachedAt(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    return _characterIssueList.cachedAt(key);
  }

  @override
  Future<CharacterIssueListPageCacheMeta?> getCharacterIssueListResultsMeta(
    int characterId, {
    required int page,
    required int limit,
  }) async {
    final key = _getCharacterIssueListKey(characterId, page, limit);
    return _characterIssueList.meta(key);
  }

  @override
  Future<void> cacheTeamIssueListResults(
    int teamId,
    List<IssueListDto> issues, {
    required int page,
    required int limit,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    await _teamIssueList.cache(key, issues, count: count, next: next, previous: previous);
  }

  @override
  Future<List<IssueListDto>?> getTeamIssueListResults(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    return _teamIssueList.get(key);
  }

  @override
  Future<DateTime?> getTeamIssueListResultsCachedAt(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    return _teamIssueList.cachedAt(key);
  }

  @override
  Future<TeamIssueListPageCacheMeta?> getTeamIssueListResultsMeta(
    int teamId, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamIssueListKey(teamId, page, limit);
    return _teamIssueList.meta(key);
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
    final key = _getCreatorSearchKey(query, page, limit);
    await _creatorSearch.cache(key, creators, count: count, next: next, previous: previous);
  }

  @override
  Future<List<CreatorListDto>?> getCreatorSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    return _creatorSearch.get(key);
  }

  @override
  Future<DateTime?> getCreatorSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    return _creatorSearch.cachedAt(key);
  }

  @override
  Future<CreatorSearchPageCacheMeta?> getCreatorSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getCreatorSearchKey(query, page, limit);
    return _creatorSearch.meta(key);
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
    final key = _getUniverseSearchKey(query, page, limit);
    await _universeSearch.cache(key, universes, count: count, next: next, previous: previous);
  }

  @override
  Future<List<UniverseListDto>?> getUniverseSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    return _universeSearch.get(key);
  }

  @override
  Future<DateTime?> getUniverseSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    return _universeSearch.cachedAt(key);
  }

  @override
  Future<UniverseSearchPageCacheMeta?> getUniverseSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getUniverseSearchKey(query, page, limit);
    return _universeSearch.meta(key);
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
    final key = _getImprintSearchKey(query, page, limit);
    await _imprintSearch.cache(key, imprints, count: count, next: next, previous: previous);
  }

  @override
  Future<List<ImprintListDto>?> getImprintSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    return _imprintSearch.get(key);
  }

  @override
  Future<DateTime?> getImprintSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    return _imprintSearch.cachedAt(key);
  }

  @override
  Future<ImprintSearchPageCacheMeta?> getImprintSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getImprintSearchKey(query, page, limit);
    return _imprintSearch.meta(key);
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
    final key = _getTeamSearchKey(query, page, limit);
    await _teamSearch.cache(key, teams, count: count, next: next, previous: previous);
  }

  @override
  Future<List<TeamListDto>?> getTeamSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    return _teamSearch.get(key);
  }

  @override
  Future<DateTime?> getTeamSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    return _teamSearch.cachedAt(key);
  }

  @override
  Future<TeamSearchPageCacheMeta?> getTeamSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getTeamSearchKey(query, page, limit);
    return _teamSearch.meta(key);
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
    final key = _getArcSearchKey(query, page, limit);
    await _arcSearch.cache(key, arcs, count: count, next: next, previous: previous);
  }

  @override
  Future<List<ArcListDto>?> getArcSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    return _arcSearch.get(key);
  }

  @override
  Future<DateTime?> getArcSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    return _arcSearch.cachedAt(key);
  }

  @override
  Future<ArcSearchPageCacheMeta?> getArcSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcSearchKey(query, page, limit);
    return _arcSearch.meta(key);
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
    await _arcIssueList.cache(key, issues, count: count, next: next, previous: previous);
  }

  @override
  Future<List<IssueListDto>?> getArcIssueListResults(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    return _arcIssueList.get(key);
  }

  @override
  Future<DateTime?> getArcIssueListResultsCachedAt(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    return _arcIssueList.cachedAt(key);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getArcIssueListResultsMeta(
    int arcId, {
    required int page,
    required int limit,
  }) async {
    final key = _getArcIssueListKey(arcId, page, limit);
    return _arcIssueList.meta(key);
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
    final key = _getPublisherSearchKey(query, page, limit);
    await _publisherSearch.cache(key, publishers, count: count, next: next, previous: previous);
  }

  @override
  Future<List<PublisherListDto>?> getPublisherSearchResults(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    return _publisherSearch.get(key);
  }

  @override
  Future<DateTime?> getPublisherSearchResultsCachedAt(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    return _publisherSearch.cachedAt(key);
  }

  @override
  Future<PublisherSearchPageCacheMeta?> getPublisherSearchResultsMeta(
    String query, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSearchKey(query, page, limit);
    return _publisherSearch.meta(key);
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
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    await _publisherSeriesList.cache(key, series, count: count, next: next, previous: previous);
  }

  @override
  Future<List<SeriesListDto>?> getPublisherSeriesListResults(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    return _publisherSeriesList.get(key);
  }

  @override
  Future<DateTime?> getPublisherSeriesListResultsCachedAt(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    return _publisherSeriesList.cachedAt(key);
  }

  @override
  Future<SeriesIssueListPageCacheMeta?> getPublisherSeriesListResultsMeta(
    int publisherId, {
    required int page,
    required int limit,
  }) async {
    final key = _getPublisherSeriesListKey(publisherId, page, limit);
    return _publisherSeriesList.meta(key);
  }

  @override
  Future<void> cacheIssueDetailsResponse(
    int issueId,
    Map<String, dynamic> json,
  ) async {
    await _issueDetails.cache("$issueId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(
    int issueId,
  ) async {
    return _issueDetails.get("$issueId");
  }

  @override
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId) async {
    return _issueDetails.cachedAt("$issueId");
  }

  @override
  Future<void> cacheSeriesDetailsResponse(
    int seriesId,
    Map<String, dynamic> json,
  ) async {
    await _seriesDetails.cache("$seriesId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(
    int seriesId,
  ) async {
    return _seriesDetails.get("$seriesId");
  }

  @override
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId) async {
    return _seriesDetails.cachedAt("$seriesId");
  }

  @override
  Future<void> cacheCharacterDetailsResponse(
    int characterId,
    Map<String, dynamic> json,
  ) async {
    await _characterDetails.cache("$characterId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedCharacterDetailsResponse(
    int characterId,
  ) async {
    return _characterDetails.get("$characterId");
  }

  @override
  Future<DateTime?> getCachedCharacterDetailsCachedAt(int characterId) async {
    return _characterDetails.cachedAt("$characterId");
  }

  @override
  Future<void> cacheCreatorDetailsResponse(
    int creatorId,
    Map<String, dynamic> json,
  ) async {
    await _creatorDetails.cache("$creatorId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedCreatorDetailsResponse(
    int creatorId,
  ) async {
    return _creatorDetails.get("$creatorId");
  }

  @override
  Future<DateTime?> getCachedCreatorDetailsCachedAt(int creatorId) async {
    return _creatorDetails.cachedAt("$creatorId");
  }

  @override
  Future<void> cacheTeamDetailsResponse(
    int teamId,
    Map<String, dynamic> json,
  ) async {
    await _teamDetails.cache("$teamId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedTeamDetailsResponse(int teamId) async {
    return _teamDetails.get("$teamId");
  }

  @override
  Future<DateTime?> getCachedTeamDetailsCachedAt(int teamId) async {
    return _teamDetails.cachedAt("$teamId");
  }

  @override
  Future<void> cacheUniverseDetailsResponse(
    int universeId,
    Map<String, dynamic> json,
  ) async {
    await _universeDetails.cache("$universeId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUniverseDetailsResponse(
    int universeId,
  ) async {
    return _universeDetails.get("$universeId");
  }

  @override
  Future<DateTime?> getCachedUniverseDetailsCachedAt(int universeId) async {
    return _universeDetails.cachedAt("$universeId");
  }

  @override
  Future<void> cacheImprintDetailsResponse(
    int imprintId,
    Map<String, dynamic> json,
  ) async {
    await _imprintDetails.cache("$imprintId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedImprintDetailsResponse(
    int imprintId,
  ) async {
    return _imprintDetails.get("$imprintId");
  }

  @override
  Future<DateTime?> getCachedImprintDetailsCachedAt(int imprintId) async {
    return _imprintDetails.cachedAt("$imprintId");
  }

  @override
  Future<void> cachePublisherDetailsResponse(
    int publisherId,
    Map<String, dynamic> json,
  ) async {
    await _publisherDetails.cache("$publisherId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedPublisherDetailsResponse(
    int publisherId,
  ) async {
    return _publisherDetails.get("$publisherId");
  }

  @override
  Future<DateTime?> getCachedPublisherDetailsCachedAt(int publisherId) async {
    return _publisherDetails.cachedAt("$publisherId");
  }

  @override
  Future<void> cacheArcDetailsResponse(
    int arcId,
    Map<String, dynamic> json,
  ) async {
    await _arcDetails.cache("$arcId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedArcDetailsResponse(int arcId) async {
    return _arcDetails.get("$arcId");
  }

  @override
  Future<DateTime?> getCachedArcDetailsCachedAt(int arcId) async {
    return _arcDetails.cachedAt("$arcId");
  }

  @override
  Future<void> cacheArcListResults(
    List<ArcListDto> arcs, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getArcListKey(page, limit, modifiedGt: modifiedGt);
    await _arcList.cache(key, arcs, count: count, next: next, previous: previous);
  }

  @override
  Future<List<ArcListDto>?> getArcListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getArcListKey(page, limit, modifiedGt: modifiedGt);
    return _arcList.get(key);
  }

  @override
  Future<DateTime?> getArcListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getArcListKey(page, limit, modifiedGt: modifiedGt);
    return _arcList.cachedAt(key);
  }

  @override
  Future<ArcListPageCacheMeta?> getArcListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getArcListKey(page, limit, modifiedGt: modifiedGt);
    return _arcList.meta(key);
  }

  @override
  Future<void> cacheCharacterListResults(
    List<CharacterListDto> characters, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCharacterListKey(page, limit, modifiedGt: modifiedGt);
    await _characterList.cache(key, characters, count: count, next: next, previous: previous);
  }

  @override
  Future<List<CharacterListDto>?> getCharacterListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCharacterListKey(page, limit, modifiedGt: modifiedGt);
    return _characterList.get(key);
  }

  @override
  Future<DateTime?> getCharacterListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCharacterListKey(page, limit, modifiedGt: modifiedGt);
    return _characterList.cachedAt(key);
  }

  @override
  Future<CharacterListPageCacheMeta?> getCharacterListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCharacterListKey(page, limit, modifiedGt: modifiedGt);
    return _characterList.meta(key);
  }

  @override
  Future<void> cacheCreatorListResults(
    List<CreatorListDto> creators, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getCreatorListKey(page, limit, modifiedGt: modifiedGt);
    await _creatorList.cache(key, creators, count: count, next: next, previous: previous);
  }

  @override
  Future<List<CreatorListDto>?> getCreatorListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCreatorListKey(page, limit, modifiedGt: modifiedGt);
    return _creatorList.get(key);
  }

  @override
  Future<DateTime?> getCreatorListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCreatorListKey(page, limit, modifiedGt: modifiedGt);
    return _creatorList.cachedAt(key);
  }

  @override
  Future<CreatorListPageCacheMeta?> getCreatorListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getCreatorListKey(page, limit, modifiedGt: modifiedGt);
    return _creatorList.meta(key);
  }

  @override
  Future<void> cacheImprintListResults(
    List<ImprintListDto> imprints, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getImprintListKey(page, limit, modifiedGt: modifiedGt);
    await _imprintList.cache(key, imprints, count: count, next: next, previous: previous);
  }

  @override
  Future<List<ImprintListDto>?> getImprintListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getImprintListKey(page, limit, modifiedGt: modifiedGt);
    return _imprintList.get(key);
  }

  @override
  Future<DateTime?> getImprintListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getImprintListKey(page, limit, modifiedGt: modifiedGt);
    return _imprintList.cachedAt(key);
  }

  @override
  Future<ImprintListPageCacheMeta?> getImprintListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getImprintListKey(page, limit, modifiedGt: modifiedGt);
    return _imprintList.meta(key);
  }

  @override
  Future<void> cachePublisherListResults(
    List<PublisherListDto> publishers, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getPublisherListKey(page, limit, modifiedGt: modifiedGt);
    await _publisherList.cache(key, publishers, count: count, next: next, previous: previous);
  }

  @override
  Future<List<PublisherListDto>?> getPublisherListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getPublisherListKey(page, limit, modifiedGt: modifiedGt);
    return _publisherList.get(key);
  }

  @override
  Future<DateTime?> getPublisherListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getPublisherListKey(page, limit, modifiedGt: modifiedGt);
    return _publisherList.cachedAt(key);
  }

  @override
  Future<PublisherListPageCacheMeta?> getPublisherListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getPublisherListKey(page, limit, modifiedGt: modifiedGt);
    return _publisherList.meta(key);
  }

  @override
  Future<void> cacheTeamListResults(
    List<TeamListDto> teams, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getTeamListKey(page, limit, modifiedGt: modifiedGt);
    await _teamList.cache(key, teams, count: count, next: next, previous: previous);
  }

  @override
  Future<List<TeamListDto>?> getTeamListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getTeamListKey(page, limit, modifiedGt: modifiedGt);
    return _teamList.get(key);
  }

  @override
  Future<DateTime?> getTeamListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getTeamListKey(page, limit, modifiedGt: modifiedGt);
    return _teamList.cachedAt(key);
  }

  @override
  Future<TeamListPageCacheMeta?> getTeamListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getTeamListKey(page, limit, modifiedGt: modifiedGt);
    return _teamList.meta(key);
  }

  @override
  Future<void> cacheUniverseListResults(
    List<UniverseListDto> universes, {
    required int page,
    required int limit,
    DateTime? modifiedGt,
    required int count,
    String? next,
    String? previous,
  }) async {
    final key = _getUniverseListKey(page, limit, modifiedGt: modifiedGt);
    await _universeList.cache(key, universes, count: count, next: next, previous: previous);
  }

  @override
  Future<List<UniverseListDto>?> getUniverseListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getUniverseListKey(page, limit, modifiedGt: modifiedGt);
    return _universeList.get(key);
  }

  @override
  Future<DateTime?> getUniverseListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getUniverseListKey(page, limit, modifiedGt: modifiedGt);
    return _universeList.cachedAt(key);
  }

  @override
  Future<UniverseListPageCacheMeta?> getUniverseListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
  }) async {
    final key = _getUniverseListKey(page, limit, modifiedGt: modifiedGt);
    return _universeList.meta(key);
  }

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
  }) async {
    final key = _getReadingListKey(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    await _readingList.cache(key, readingLists, count: count, next: next, previous: previous);
  }

  @override
  Future<List<ReadingListDto>?> getReadingListResults({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = _getReadingListKey(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.get(key);
  }

  @override
  Future<DateTime?> getReadingListResultsCachedAt({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = _getReadingListKey(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.cachedAt(key);
  }

  @override
  Future<ReadingListPageCacheMeta?> getReadingListResultsMeta({
    required int page,
    required int limit,
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) async {
    final key = _getReadingListKey(
      page,
      limit,
      modifiedGt: modifiedGt,
      name: name,
      listType: listType,
      attributionSource: attributionSource,
      publisher: publisher,
    );
    return _readingList.meta(key);
  }
}