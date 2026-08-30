import "package:takion/src/data/catalog/datasources/local/paged_local_cache.dart";
import "package:takion/src/data/common/drift/database.dart";

abstract class MetronDetailCacheLocalDataSource {
  Future<void> cacheIssueDetailsResponse(int issueId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(int issueId);
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId);

  Future<void> cacheSeriesDetailsResponse(int seriesId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(int seriesId);
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId);

  Future<void> cacheCharacterDetailsResponse(int characterId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedCharacterDetailsResponse(int characterId);
  Future<DateTime?> getCachedCharacterDetailsCachedAt(int characterId);

  Future<void> cacheCreatorDetailsResponse(int creatorId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedCreatorDetailsResponse(int creatorId);
  Future<DateTime?> getCachedCreatorDetailsCachedAt(int creatorId);

  Future<void> cacheTeamDetailsResponse(int teamId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedTeamDetailsResponse(int teamId);
  Future<DateTime?> getCachedTeamDetailsCachedAt(int teamId);

  Future<void> cacheUniverseDetailsResponse(int universeId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedUniverseDetailsResponse(int universeId);
  Future<DateTime?> getCachedUniverseDetailsCachedAt(int universeId);

  Future<void> cacheImprintDetailsResponse(int imprintId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedImprintDetailsResponse(int imprintId);
  Future<DateTime?> getCachedImprintDetailsCachedAt(int imprintId);

  Future<void> cachePublisherDetailsResponse(int publisherId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedPublisherDetailsResponse(int publisherId);
  Future<DateTime?> getCachedPublisherDetailsCachedAt(int publisherId);

  Future<void> cacheArcDetailsResponse(int arcId, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCachedArcDetailsResponse(int arcId);
  Future<DateTime?> getCachedArcDetailsCachedAt(int arcId);
}

class MetronDetailCacheLocalDataSourceImpl implements MetronDetailCacheLocalDataSource {
  MetronDetailCacheLocalDataSourceImpl(AppDatabase db)
      : _issueDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "issue_details",
          entityType: "issue_details",
        ),
        _seriesDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "series_details",
          entityType: "series_details",
        ),
        _characterDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "character_details",
          entityType: "character_details",
        ),
        _creatorDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "creator_details",
          entityType: "creator_details",
        ),
        _teamDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "team_details",
          entityType: "team_details",
        ),
        _universeDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "universe_details",
          entityType: "universe_details",
        ),
        _imprintDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "imprint_details",
          entityType: "imprint_details",
        ),
        _publisherDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "publisher_details",
          entityType: "publisher_details",
        ),
        _arcDetails = DetailsLocalCache(
          db: db,
          cacheKeyPrefix: "arc_details",
          entityType: "arc_details",
        );

  final DetailsLocalCache _issueDetails;
  final DetailsLocalCache _seriesDetails;
  final DetailsLocalCache _characterDetails;
  final DetailsLocalCache _creatorDetails;
  final DetailsLocalCache _teamDetails;
  final DetailsLocalCache _universeDetails;
  final DetailsLocalCache _imprintDetails;
  final DetailsLocalCache _publisherDetails;
  final DetailsLocalCache _arcDetails;

  @override
  Future<void> cacheIssueDetailsResponse(int issueId, Map<String, dynamic> json) async {
    await _issueDetails.cache("$issueId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedIssueDetailsResponse(int issueId) async {
    return _issueDetails.get("$issueId");
  }

  @override
  Future<DateTime?> getCachedIssueDetailsCachedAt(int issueId) async {
    return _issueDetails.cachedAt("$issueId");
  }

  @override
  Future<void> cacheSeriesDetailsResponse(int seriesId, Map<String, dynamic> json) async {
    await _seriesDetails.cache("$seriesId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSeriesDetailsResponse(int seriesId) async {
    return _seriesDetails.get("$seriesId");
  }

  @override
  Future<DateTime?> getCachedSeriesDetailsCachedAt(int seriesId) async {
    return _seriesDetails.cachedAt("$seriesId");
  }

  @override
  Future<void> cacheCharacterDetailsResponse(int characterId, Map<String, dynamic> json) async {
    await _characterDetails.cache("$characterId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedCharacterDetailsResponse(int characterId) async {
    return _characterDetails.get("$characterId");
  }

  @override
  Future<DateTime?> getCachedCharacterDetailsCachedAt(int characterId) async {
    return _characterDetails.cachedAt("$characterId");
  }

  @override
  Future<void> cacheCreatorDetailsResponse(int creatorId, Map<String, dynamic> json) async {
    await _creatorDetails.cache("$creatorId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedCreatorDetailsResponse(int creatorId) async {
    return _creatorDetails.get("$creatorId");
  }

  @override
  Future<DateTime?> getCachedCreatorDetailsCachedAt(int creatorId) async {
    return _creatorDetails.cachedAt("$creatorId");
  }

  @override
  Future<void> cacheTeamDetailsResponse(int teamId, Map<String, dynamic> json) async {
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
  Future<void> cacheUniverseDetailsResponse(int universeId, Map<String, dynamic> json) async {
    await _universeDetails.cache("$universeId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUniverseDetailsResponse(int universeId) async {
    return _universeDetails.get("$universeId");
  }

  @override
  Future<DateTime?> getCachedUniverseDetailsCachedAt(int universeId) async {
    return _universeDetails.cachedAt("$universeId");
  }

  @override
  Future<void> cacheImprintDetailsResponse(int imprintId, Map<String, dynamic> json) async {
    await _imprintDetails.cache("$imprintId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedImprintDetailsResponse(int imprintId) async {
    return _imprintDetails.get("$imprintId");
  }

  @override
  Future<DateTime?> getCachedImprintDetailsCachedAt(int imprintId) async {
    return _imprintDetails.cachedAt("$imprintId");
  }

  @override
  Future<void> cachePublisherDetailsResponse(int publisherId, Map<String, dynamic> json) async {
    await _publisherDetails.cache("$publisherId", json);
  }

  @override
  Future<Map<String, dynamic>?> getCachedPublisherDetailsResponse(int publisherId) async {
    return _publisherDetails.get("$publisherId");
  }

  @override
  Future<DateTime?> getCachedPublisherDetailsCachedAt(int publisherId) async {
    return _publisherDetails.cachedAt("$publisherId");
  }

  @override
  Future<void> cacheArcDetailsResponse(int arcId, Map<String, dynamic> json) async {
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
}
