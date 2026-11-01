/// Local Drift database: user state (library, pulls, activity), normalized
/// Metron catalog metadata, junction tables, and API/image cache.
library;

import "dart:convert";
import "dart:io";

import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:path_provider/path_provider.dart";
import "package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart"
    show applyWorkaroundToOpenSqlite3OnOldAndroidVersions;

import "daos/library_item_dao.dart";
import "daos/read_log_dao.dart";
import "daos/pull_list_dao.dart";
import "daos/subscription_dao.dart";
import "daos/activity_dao.dart";
import "daos/reading_list_dao.dart";
import "daos/favorite_dao.dart";
import "daos/settings_dao.dart";
import "daos/series_name_dao.dart";
import "daos/sync_meta_dao.dart";
import "daos/metron_entity_dao.dart";
import "daos/junction_dao.dart";
import "daos/offline_queue_dao.dart";
import "daos/wishlist_dao.dart";
import "daos/outbox_dao.dart";
import "daos/sync_cursor_dao.dart";
import "daos/sync_job_dao.dart";
import "daos/sync_lease_dao.dart";
import "daos/remote_cache_dao.dart";
import "daos/sync_conflict_dao.dart";

part "database.g.dart";

@TableIndex(name: "idx_lib_issue", columns: {#metronIssueId})
@TableIndex(name: "idx_lib_series", columns: {#metronSeriesId})
@TableIndex(name: "idx_lib_read", columns: {#isRead})
@TableIndex(name: "idx_lib_status", columns: {#ownershipStatus})
@TableIndex(name: "idx_lib_status_read", columns: {#ownershipStatus, #isRead})
@TableIndex(
  name: "idx_lib_metron_collection_id",
  columns: {#metronCollectionId},
)
@TableIndex(name: "idx_lib_sync_status", columns: {#syncStatus})
class LibraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronIssueId => integer()();
  IntColumn get metronSeriesId => integer()();
  TextColumn get ownershipStatus => text()();
  BoolColumn get isRead => boolean()();
  IntColumn get metronCollectionId => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant("synced"))();
  IntColumn get rating => integer().nullable()();
  TextColumn get purchaseDate => text().nullable()();
  RealColumn get pricePaid => real().nullable()();
  IntColumn get quantityOwned => integer().withDefault(const Constant(1))();
  TextColumn get format => text()();
  TextColumn get firstReadAt => text().nullable()();
  TextColumn get conditionGrade => text().nullable()();
  TextColumn get acquiredOn => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get remoteModified => text().nullable()();
  TextColumn get lastSeenScanId => text().nullable()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_readlog_item", columns: {#collectionItemId})
class LibraryReadLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get collectionItemId => text()();
  TextColumn get readAt => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_pull_issue", columns: {#metronIssueId})
@TableIndex(name: "idx_pull_series", columns: {#metronSeriesId})
@TableIndex(name: "idx_pull_release", columns: {#releaseDate})
@TableIndex(
  name: "idx_pull_release_status",
  columns: {#releaseDate, #entryStatus},
)
@TableIndex(name: "idx_pull_sync_status", columns: {#syncStatus})
class PullListEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronIssueId => integer()();
  IntColumn get metronSeriesId => integer()();
  IntColumn get metronPullListId => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant("synced"))();
  TextColumn get entryStatus => text()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get source => text()();
  TextColumn get generatedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_sub_series", columns: {#metronSeriesId})
@TableIndex(name: "idx_sub_sync_status", columns: {#syncStatus})
class SeriesSubscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronSeriesId => integer()();
  IntColumn get metronPullListId => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant("synced"))();
  BoolColumn get isActive => boolean()();
  BoolColumn get autoAddPull => boolean().withDefault(const Constant(false))();
  TextColumn get subscribedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get remoteModified => text().nullable()();
  TextColumn get lastSeenScanId => text().nullable()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_wishlist_issue", columns: {#issueId})
@TableIndex(name: "idx_wishlist_series", columns: {#seriesId})
@TableIndex(name: "idx_wishlist_sync_status", columns: {#syncStatus})
class WishlistItems extends Table {
  IntColumn get id => integer()();
  IntColumn get issueId => integer()();
  IntColumn get seriesId => integer()();
  TextColumn get seriesName => text()();
  TextColumn get issueNumber => text()();
  IntColumn get seriesVolume => integer().nullable()();
  IntColumn get seriesYearBegan => integer().nullable()();
  DateTimeColumn get coverDate => dateTime().nullable()();
  DateTimeColumn get storeDate => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  RealColumn get desiredGrade => real().nullable()();
  RealColumn get maxPrice => real().nullable()();
  TextColumn get maxPriceCurrency =>
      text().withDefault(const Constant("USD"))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get addedOn => dateTime().nullable()();
  DateTimeColumn get modified => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant("synced"))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get localId => text().nullable()();
  TextColumn get remoteModified => text().nullable()();
  TextColumn get lastSeenScanId => text().nullable()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_activity_series", columns: {#seriesId})
@TableIndex(name: "idx_activity_issue", columns: {#issueId})
@TableIndex(name: "idx_activity_event_time", columns: {#eventType, #timestamp})
@TableIndex(name: "idx_activity_timestamp", columns: {#timestamp})
@TableIndex(
  name: "idx_activity_series_timestamp",
  columns: {#seriesId, #timestamp},
)
class ActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get seriesId => integer().nullable()();
  IntColumn get issueId => integer().nullable()();
  TextColumn get eventType => text()();
  TextColumn get seriesName => text().nullable()();
  TextColumn get issueNumber => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get metadata => text().nullable()();
  TextColumn get batchId => text().nullable()();
  TextColumn get timestamp => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReadingLists extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get isOrdered => boolean()();
  TextColumn get contentType => text()();
  TextColumn get itemsJson => text()();
  IntColumn get metronSourceId => integer().nullable()();
  IntColumn get metronArcId => integer().nullable()();
  TextColumn get metronAttributionSource => text().nullable()();
  TextColumn get metronAttributionUrl => text().nullable()();
  TextColumn get metronImageUrl => text().nullable()();
  TextColumn get metronListType => text().nullable()();
  TextColumn get lastSyncedAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_rli_list", columns: {#listId})
class ReadingListItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text()();
  TextColumn get targetId => text()();
  BoolColumn get isSeries => boolean()();
  TextColumn get role => text()();
  BoolColumn get isRead => boolean()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoriteSeries extends Table {
  IntColumn get metronSeriesId => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {metronSeriesId};
}

class FavoriteIssues extends Table {
  IntColumn get metronIssueId => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {metronIssueId};
}

class FavoriteCharacters extends Table {
  IntColumn get metronCharacterId => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {metronCharacterId};
}

class FavoriteCreators extends Table {
  IntColumn get metronCreatorId => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {metronCreatorId};
}

class FavoriteReadingLists extends Table {
  TextColumn get readingListId => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {readingListId};
}

@TableIndex(name: "idx_metron_issues_series", columns: {#seriesId})
class MetronIssues extends Table {
  IntColumn get id => integer()();
  TextColumn get number => text()();
  TextColumn get issueName => text().nullable()();
  IntColumn get seriesId => integer().nullable()();
  TextColumn get coverDate => text().nullable()();
  TextColumn get storeDate => text().nullable()();
  TextColumn get focDate => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get price => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get upc => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get coverHash => text().nullable()();
  IntColumn get publisherId => integer().nullable()();
  IntColumn get imprintId => integer().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  TextColumn get variantsJson => text().nullable()();
  TextColumn get reprintsJson => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_metron_series_name", columns: {#name})
class MetronSeries extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get sortName => text().nullable()();
  IntColumn get volume => integer().nullable()();
  IntColumn get seriesTypeId => integer().nullable()();
  TextColumn get seriesTypeName => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get publisherId => integer().nullable()();
  IntColumn get imprintId => integer().nullable()();
  IntColumn get yearBegan => integer().nullable()();
  IntColumn get yearEnd => integer().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get issueCount => integer().nullable()();
  TextColumn get computedCoverUrl => text().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronCreators extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get birth => text().nullable()();
  TextColumn get death => text().nullable()();
  TextColumn get aliasJson => text().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronCharacters extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get slug => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get aliasJson => text().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronArcs extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronTeams extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronUniverses extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get designation => text().nullable()();
  IntColumn get publisherId => integer().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronPublishers extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get country => text().nullable()();
  IntColumn get founded => integer().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronImprints extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get publisherId => integer().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get founded => integer().nullable()();
  IntColumn get cvId => integer().nullable()();
  IntColumn get gcdId => integer().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronReadingLists extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get slug => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get listType => text().nullable()();
  BoolColumn get isPrivate => boolean().nullable()();
  TextColumn get attributionSource => text().nullable()();
  TextColumn get attributionUrl => text().nullable()();
  RealColumn get averageRating => real().nullable()();
  IntColumn get ratingCount => integer().nullable()();
  TextColumn get itemsUrl => text().nullable()();
  TextColumn get resourceUrl => text().nullable()();
  TextColumn get modified => text().nullable()();
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pagination metadata and freshness for one cached query page. Entity
/// payloads live in the normalized `metron_*` catalog tables; each row here
/// pairs with the ordered entity ids in [PagedQueryItems] for the same key.
class PagedQueryCaches extends Table {
  TextColumn get cacheKeyPrefix => text()();
  TextColumn get pageKey => text()();
  IntColumn get count => integer().nullable()();
  TextColumn get next => text().nullable()();
  TextColumn get previous => text().nullable()();
  TextColumn get cachedAt => text()();

  @override
  Set<Column> get primaryKey => {cacheKeyPrefix, pageKey};
}

/// Ordered entity ids for one cached query page (one row per position).
class PagedQueryItems extends Table {
  TextColumn get cacheKeyPrefix => text()();
  TextColumn get pageKey => text()();
  IntColumn get position => integer()();
  IntColumn get entityId => integer()();

  @override
  Set<Column> get primaryKey => {cacheKeyPrefix, pageKey, position};
}

@TableIndex(name: "idx_issue_creators_creator", columns: {#creatorId})
class IssueCreators extends Table {
  IntColumn get issueId => integer()();
  IntColumn get creatorId => integer()();
  TextColumn get role => text().nullable()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, creatorId};
}

@TableIndex(name: "idx_issue_characters_character", columns: {#characterId})
class IssueCharacters extends Table {
  IntColumn get issueId => integer()();
  IntColumn get characterId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, characterId};
}

@TableIndex(name: "idx_issue_arcs_arc", columns: {#arcId})
class IssueArcs extends Table {
  IntColumn get issueId => integer()();
  IntColumn get arcId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, arcId};
}

@TableIndex(name: "idx_issue_teams_team", columns: {#teamId})
class IssueTeams extends Table {
  IntColumn get issueId => integer()();
  IntColumn get teamId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, teamId};
}

@TableIndex(name: "idx_issue_universes_universe", columns: {#universeId})
class IssueUniverses extends Table {
  IntColumn get issueId => integer()();
  IntColumn get universeId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, universeId};
}

class IssueImprints extends Table {
  IntColumn get issueId => integer()();
  IntColumn get imprintId => integer()();

  @override
  Set<Column> get primaryKey => {issueId, imprintId};
}

class SeriesArcs extends Table {
  IntColumn get seriesId => integer()();
  IntColumn get arcId => integer()();

  @override
  Set<Column> get primaryKey => {seriesId, arcId};
}

class SeriesTeams extends Table {
  IntColumn get seriesId => integer()();
  IntColumn get teamId => integer()();

  @override
  Set<Column> get primaryKey => {seriesId, teamId};
}

class SeriesUniverses extends Table {
  IntColumn get seriesId => integer()();
  IntColumn get universeId => integer()();

  @override
  Set<Column> get primaryKey => {seriesId, universeId};
}

class AssociatedSeries extends Table {
  IntColumn get seriesId => integer()();
  IntColumn get associatedSeriesId => integer()();

  @override
  Set<Column> get primaryKey => {seriesId, associatedSeriesId};
}

class CharacterCreators extends Table {
  IntColumn get characterId => integer()();
  IntColumn get creatorId => integer()();

  @override
  Set<Column> get primaryKey => {characterId, creatorId};
}

class CharacterTeams extends Table {
  IntColumn get characterId => integer()();
  IntColumn get teamId => integer()();

  @override
  Set<Column> get primaryKey => {characterId, teamId};
}

class CharacterUniverses extends Table {
  IntColumn get characterId => integer()();
  IntColumn get universeId => integer()();

  @override
  Set<Column> get primaryKey => {characterId, universeId};
}

class CreatorTeams extends Table {
  IntColumn get creatorId => integer()();
  IntColumn get teamId => integer()();

  @override
  Set<Column> get primaryKey => {creatorId, teamId};
}

class TeamUniverses extends Table {
  IntColumn get teamId => integer()();
  IntColumn get universeId => integer()();

  @override
  Set<Column> get primaryKey => {teamId, universeId};
}

@TableIndex(name: "idx_mrli_list", columns: {#listId})
class MetronReadingListItems extends Table {
  IntColumn get listId => integer()();
  IntColumn get targetId => integer()();
  IntColumn get order => integer().nullable()();
  TextColumn get issueType => text().nullable()();

  @override
  Set<Column> get primaryKey => {listId, targetId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class SeriesNameIndex extends Table {
  TextColumn get normalizedName => text()();
  TextColumn get originalName => text()();

  @override
  Set<Column> get primaryKey => {normalizedName};
}

@TableIndex(name: "idx_offline_queue_status", columns: {#status})
@TableIndex(name: "idx_offline_queue_created", columns: {#createdAt})
class OfflineWriteQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation =>
      text()(); // 'create', 'update', 'delete', 'scrobble', 'acquire'
  TextColumn get entityType =>
      text()(); // 'collection', 'pull_list', 'wish_list'
  TextColumn get entityId => text().nullable()(); // local or Metron ID
  TextColumn get payload => text()(); // JSON body
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant("pending"))();
  TextColumn get lastError => text().nullable()();
  IntColumn get lastAttemptAt => integer().nullable()();
}

class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Durable intent log for Metron-owned local changes. This is additive to the
/// legacy [OfflineWriteQueue] while command and sync execution migrate in
/// later phases; never delete legacy rows from a schema migration.
@TableIndex(name: "idx_outbox_ready", columns: {#accountId, #state, #notBefore})
@TableIndex(
  name: "idx_outbox_entity",
  columns: {#accountId, #coalesceKey, #state},
)
class OutboxOperations extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityLocalId => text()();
  IntColumn get entityRemoteId => integer().nullable()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  TextColumn get coalesceKey => text()();
  TextColumn get dependsOnId => text().nullable()();
  TextColumn get state => text().withDefault(const Constant("pending"))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get notBefore => dateTime().nullable()();
  TextColumn get baseRemoteModified => text().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Checkpoint for one remote resource. [cursorJson] stores the opaque next
/// URL and resource-specific scan/watermark state without turning SyncMeta
/// into another untyped synchronization API.
class SyncCursors extends Table {
  TextColumn get accountId => text()();
  TextColumn get resource => text()();
  TextColumn get cursorJson => text()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {accountId, resource};
}

@TableIndex(
  name: "idx_sync_jobs_due",
  columns: {#accountId, #state, #notBefore},
)
class SyncJobs extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get resource => text().nullable()();
  TextColumn get reason => text()();
  TextColumn get state => text().withDefault(const Constant("pending"))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get notBefore => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncLeases extends Table {
  TextColumn get name => text()();
  TextColumn get ownerId => text()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get heartbeatAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

@TableIndex(name: "idx_remote_cache_expiry", columns: {#accountId, #staleAt})
class RemoteCacheEntries extends Table {
  TextColumn get accountId => text()();
  TextColumn get cacheKey => text()();
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get staleAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {accountId, cacheKey};
}

@TableIndex(name: "idx_sync_conflicts_open", columns: {#accountId, #state})
class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityLocalId => text()();
  IntColumn get entityRemoteId => integer().nullable()();
  TextColumn get localPayloadJson => text()();
  TextColumn get remotePayloadJson => text().nullable()();
  TextColumn get state => text().withDefault(const Constant("open"))();
  TextColumn get resolution => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LibraryItems,
    LibraryReadLogs,
    PullListEntries,
    SeriesSubscriptions,
    ActivityEvents,
    ReadingLists,
    ReadingListItems,
    FavoriteSeries,
    FavoriteIssues,
    FavoriteCharacters,
    FavoriteCreators,
    FavoriteReadingLists,
    MetronIssues,
    MetronSeries,
    MetronCreators,
    MetronCharacters,
    MetronArcs,
    MetronTeams,
    MetronUniverses,
    MetronPublishers,
    MetronImprints,
    MetronReadingLists,
    IssueCreators,
    IssueCharacters,
    IssueArcs,
    IssueTeams,
    IssueUniverses,
    IssueImprints,
    SeriesArcs,
    SeriesTeams,
    SeriesUniverses,
    AssociatedSeries,
    CharacterCreators,
    CharacterTeams,
    CharacterUniverses,
    CreatorTeams,
    TeamUniverses,
    MetronReadingListItems,
    AppSettings,
    SeriesNameIndex,
    SyncMeta,
    OfflineWriteQueue,
    WishlistItems,
    PagedQueryCaches,
    PagedQueryItems,
    OutboxOperations,
    SyncCursors,
    SyncJobs,
    SyncLeases,
    RemoteCacheEntries,
    SyncConflicts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  late final LibraryItemDao libraryItemDao = LibraryItemDao(this);
  late final ReadLogDao readLogDao = ReadLogDao(this);
  late final PullListDao pullListDao = PullListDao(this);
  late final SubscriptionDao subscriptionDao = SubscriptionDao(this);
  late final ActivityDao activityDao = ActivityDao(this);
  late final ReadingListDao readingListDao = ReadingListDao(this);
  late final FavoriteDao favoriteDao = FavoriteDao(this);
  late final SettingsDao settingsDao = SettingsDao(this);
  late final SeriesNameDao seriesNameDao = SeriesNameDao(this);
  late final SyncMetaDao syncMetaDao = SyncMetaDao(this);
  late final MetronEntityDao metronEntityDao = MetronEntityDao(this);
  late final JunctionDao junctionDao = JunctionDao(this);
  late final OfflineQueueDao offlineQueueDao = OfflineQueueDao(this);
  late final WishlistDao wishlistDao = WishlistDao(this);
  late final OutboxDao outboxDao = OutboxDao(this);
  late final SyncCursorDao syncCursorDao = SyncCursorDao(this);
  late final SyncJobDao syncJobDao = SyncJobDao(this);
  late final SyncLeaseDao syncLeaseDao = SyncLeaseDao(this);
  late final RemoteCacheDao remoteCacheDao = RemoteCacheDao(this);
  late final SyncConflictDao syncConflictDao = SyncConflictDao(this);

  @override
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement("PRAGMA journal_mode=WAL");
        await customStatement("PRAGMA synchronous=NORMAL");
        await customStatement("PRAGMA cache_size=-16000");
        await customStatement("PRAGMA mmap_size=268435456");
        await customStatement("PRAGMA busy_timeout=5000");
        await customStatement("PRAGMA temp_store=MEMORY");
        await customStatement("PRAGMA optimize");
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createAll();
        }
        if (from < 3) {
          await m.addColumn(metronIssues, metronIssues.variantsJson);
          await m.addColumn(metronIssues, metronIssues.reprintsJson);
        }
        if (from < 4) {
          await m.createIndex(idxLibRead);
          await m.createIndex(idxLibStatus);
          await m.createIndex(idxMetronIssuesSeries);
          await m.createIndex(idxIssueCreatorsCreator);
          await m.createIndex(idxIssueCharactersCharacter);
          await m.createIndex(idxIssueArcsArc);
          await m.createIndex(idxIssueTeamsTeam);
          await m.createIndex(idxIssueUniversesUniverse);
        }
        if (from < 5) {
          await m.createIndex(idxLibStatusRead);
          await m.createIndex(idxPullReleaseStatus);
          await m.createIndex(idxActivitySeries);
          await m.createIndex(idxActivityIssue);
          await m.createIndex(idxActivityEventTime);
          await m.createIndex(idxRliList);
          await m.createIndex(idxMetronSeriesName);
          await m.createIndex(idxMrliList);
        }
        if (from < 6) {
          await m.createIndex(idxActivitySeriesTimestamp);
        }
        if (from < 7) {
          await m.addColumn(metronSeries, metronSeries.seriesTypeName);
        }
        if (from < 8) {
          await m.addColumn(readingListItems, readingListItems.createdAt);
          await m.addColumn(readingListItems, readingListItems.updatedAt);
          await _backfillReadingListItemTimestamps();
          await syncMetaDao.deleteByKey("last_uploaded_timestamp");
        }
        if (from < 9) {
          await m.addColumn(readingLists, readingLists.metronArcId);
        }
        if (from < 11) {
          await m.addColumn(activityEvents, activityEvents.batchId);
        }
        if (from < 12) {
          await m.createTable(offlineWriteQueue);
          await m.createIndex(idxOfflineQueueStatus);
          await m.createIndex(idxOfflineQueueCreated);
        }
        if (from < 13) {
          await m.addColumn(libraryItems, libraryItems.metronCollectionId);
          await m.addColumn(libraryItems, libraryItems.syncStatus);
          await m.createIndex(idxLibMetronCollectionId);
          await m.createIndex(idxLibSyncStatus);
        }
        if (from < 14) {
          await m.addColumn(pullListEntries, pullListEntries.metronPullListId);
          await m.addColumn(pullListEntries, pullListEntries.syncStatus);
          await m.createIndex(idxPullSyncStatus);
          await m.addColumn(
            seriesSubscriptions,
            seriesSubscriptions.metronPullListId,
          );
          await m.addColumn(
            seriesSubscriptions,
            seriesSubscriptions.syncStatus,
          );
          await m.createIndex(idxSubSyncStatus);
        }
        if (from < 15) {
          await m.createTable(wishlistItems);
          await m.createIndex(idxWishlistIssue);
          await m.createIndex(idxWishlistSeries);
          await m.createIndex(idxWishlistSyncStatus);
        }
        if (from < 16) {
          await m.addColumn(offlineWriteQueue, offlineWriteQueue.lastAttemptAt);
        }
        if (from < 17) {
          await _migrateWishlistFromLibraryItems();
        }
        if (from < 18) {
          await customStatement("DROP TABLE IF EXISTS api_cache");
          await customStatement("DROP TABLE IF EXISTS image_cache");
          await customStatement(
            "DROP TABLE IF EXISTS superhero_character_cache",
          );
        }
        if (from < 19) {
          await m.addColumn(metronIssues, metronIssues.issueName);
          await m.addColumn(metronCharacters, metronCharacters.slug);
          await m.createTable(pagedQueryCaches);
          await m.createTable(pagedQueryItems);
          // Paged page payloads moved out of the settings key-value store
          // into normalized tables; drop the abandoned JSON keys.
          await customStatement(
            "DELETE FROM app_settings WHERE key LIKE 'paged\\_cache%' ESCAPE '\\'",
          );
        }
        if (from < 20) {
          await m.addColumn(libraryItems, libraryItems.remoteModified);
          await m.addColumn(libraryItems, libraryItems.lastSeenScanId);
          await m.addColumn(libraryItems, libraryItems.deletedAt);
          await m.addColumn(
            seriesSubscriptions,
            seriesSubscriptions.remoteModified,
          );
          await m.addColumn(
            seriesSubscriptions,
            seriesSubscriptions.lastSeenScanId,
          );
          await m.addColumn(seriesSubscriptions, seriesSubscriptions.deletedAt);
          await m.addColumn(wishlistItems, wishlistItems.localId);
          await m.addColumn(wishlistItems, wishlistItems.remoteModified);
          await m.addColumn(wishlistItems, wishlistItems.lastSeenScanId);
          await m.addColumn(wishlistItems, wishlistItems.deletedAt);
          await m.createTable(outboxOperations);
          await m.createTable(syncCursors);
          await m.createTable(syncJobs);
          await m.createTable(syncLeases);
          await m.createTable(remoteCacheEntries);
          await m.createTable(syncConflicts);
          await m.createIndex(idxOutboxReady);
          await m.createIndex(idxOutboxEntity);
          await m.createIndex(idxSyncJobsDue);
          await m.createIndex(idxRemoteCacheExpiry);
          await m.createIndex(idxSyncConflictsOpen);
          await _backfillV20LocalIdentifiers();
          await _backfillV20OutboxAndCursors();
        }
      },
    );
  }

  Future<void> _backfillReadingListItemTimestamps() async {
    final lists = await (select(readingLists)).get();
    final listUpdatedAt = {for (final l in lists) l.id: l.updatedAt};
    final fallback = DateTime.now().toUtc().toIso8601String();
    final items = await (select(readingListItems)).get();
    for (final item in items) {
      final ts = listUpdatedAt[item.listId] ?? fallback;
      await (update(
        readingListItems,
      )..where((t) => t.id.equals(item.id))).write(
        ReadingListItemsCompanion(createdAt: Value(ts), updatedAt: Value(ts)),
      );
    }
  }

  Future<void> _migrateWishlistFromLibraryItems() async {
    final wishlistRows = await customSelect(
      "SELECT li.*, ms.name AS series_name, ms.volume, ms.year_began, "
      "mi.issue_number "
      "FROM library_items li "
      "LEFT JOIN metron_series ms ON ms.id = li.metron_series_id "
      "LEFT JOIN metron_issues mi ON mi.id = li.metron_issue_id "
      "WHERE li.ownership_status = 'wishlist'",
      readsFrom: {libraryItems},
    ).get();

    for (final row in wishlistRows) {
      final issueId = row.read<int>("metron_issue_id");
      final seriesId = row.read<int>("metron_series_id");
      final seriesName = row.read<String?>("series_name") ?? "Series $seriesId";
      final issueNumber = row.read<String?>("issue_number") ?? "";
      final volume = row.read<int?>("volume");
      final yearBegan = row.read<int?>("year_began");
      final pricePaid = row.read<double?>("price_paid");
      final conditionGrade = row.read<String?>("condition_grade");
      final notes = row.read<String?>("notes");
      final createdAt = row.read<String>("created_at");
      final updatedAt = row.read<String>("updated_at");
      final syncStatus = row.read<String>("sync_status");

      await into(wishlistItems).insertOnConflictUpdate(
        WishlistItemsCompanion(
          id: Value(issueId),
          issueId: Value(issueId),
          seriesId: Value(seriesId),
          seriesName: Value(seriesName),
          issueNumber: Value(issueNumber),
          seriesVolume: Value(volume),
          seriesYearBegan: Value(yearBegan),
          imageUrl: const Value.absent(),
          priority: const Value(3),
          desiredGrade: Value(
            conditionGrade != null ? double.tryParse(conditionGrade) : null,
          ),
          maxPrice: Value(pricePaid),
          notes: Value(notes),
          syncStatus: Value(syncStatus),
          createdAt: Value(createdAt),
          updatedAt: Value(updatedAt),
        ),
      );
    }

    await (delete(
      libraryItems,
    )..where((t) => t.ownershipStatus.equals("wishlist"))).go();
  }

  Future<void> _backfillV20LocalIdentifiers() async {
    await customStatement(
      "UPDATE wishlist_items SET local_id = 'wish-' || issue_id "
      "WHERE local_id IS NULL",
    );
  }

  Future<void> _backfillV20OutboxAndCursors() async {
    // 1. Backfill legacy offline_write_queue into outbox_operations
    try {
      final legacyRows = await customSelect(
        "SELECT id, operation, entity_type, entity_id, payload, created_at, "
        "retry_count, status, last_error, last_attempt_at "
        "FROM offline_write_queue WHERE status IN ('pending', 'failed')",
      ).get();

      for (final row in legacyRows) {
        final id = row.read<int>("id");
        final operation = row.read<String>("operation");
        final rawEntityType = row.read<String>("entity_type");
        final entityId = row.read<String?>("entity_id") ?? "$id";
        final payload = row.read<String>("payload");
        final createdAtMs = row.read<int>("created_at");
        final retryCount = row.read<int>("retry_count");
        final status = row.read<String>("status");
        final lastError = row.read<String?>("last_error");
        final lastAttemptMs = row.read<int?>("last_attempt_at");

        final entityType = rawEntityType == "wish_list"
            ? "wishlist"
            : rawEntityType;
        final outboxId = "legacy_owq_$id";
        final coalesceKey = "$entityType:$entityId";
        final createdAt = DateTime.fromMillisecondsSinceEpoch(
          createdAtMs,
          isUtc: true,
        );
        final updatedAt = DateTime.fromMillisecondsSinceEpoch(
          lastAttemptMs ?? createdAtMs,
          isUtc: true,
        );
        final state = status == "failed" ? "failed" : "pending";
        final remoteId = int.tryParse(entityId);

        await into(outboxOperations).insertOnConflictUpdate(
          OutboxOperationsCompanion(
            id: Value(outboxId),
            accountId: const Value("default"),
            entityType: Value(entityType),
            entityLocalId: Value(entityId),
            entityRemoteId: Value(remoteId),
            operation: Value(operation),
            payloadJson: Value(payload),
            coalesceKey: Value(coalesceKey),
            state: Value(state),
            attemptCount: Value(retryCount),
            lastErrorMessage: Value(lastError),
            createdAt: Value(createdAt),
            updatedAt: Value(updatedAt),
          ),
        );
      }
    } catch (_) {
      // Table might not exist or error during select in non-standard fixtures
    }

    // 2. Map legacy sync timestamps conservatively to complete cursors
    try {
      final metaRows = await customSelect(
        "SELECT key, value FROM sync_meta WHERE key IN "
        "('metron_last_collection_sync', 'metron_last_pull_list_sync', 'metron_last_wishlist_sync')",
      ).get();

      for (final row in metaRows) {
        final key = row.read<String>("key");
        final val = row.read<String>("value");
        final dt = DateTime.tryParse(val);
        if (dt != null) {
          final resource = switch (key) {
            "metron_last_collection_sync" => "collection",
            "metron_last_pull_list_sync" => "pull_series",
            "metron_last_wishlist_sync" => "wishlist",
            _ => null,
          };
          if (resource != null) {
            final cursorJson = jsonEncode({
              "watermark": dt.toUtc().toIso8601String(),
              "migratedFromSyncMeta": true,
            });
            await into(syncCursors).insertOnConflictUpdate(
              SyncCursorsCompanion(
                accountId: const Value("default"),
                resource: Value(resource),
                cursorJson: Value(cursorJson),
                isComplete: const Value(true),
                updatedAt: Value(dt.toUtc()),
              ),
            );
          }
        }
      }
    } catch (_) {}
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File("${dbFolder.path}/takion.sqlite");

    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
      cachePreparedStatements: true,
      readPool: 2,
    );
  });
}
