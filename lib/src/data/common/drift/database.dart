import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'
    show applyWorkaroundToOpenSqlite3OnOldAndroidVersions;

import 'daos/library_item_dao.dart';
import 'daos/read_log_dao.dart';
import 'daos/pull_list_dao.dart';
import 'daos/subscription_dao.dart';
import 'daos/activity_dao.dart';
import 'daos/reading_list_dao.dart';
import 'daos/favorite_dao.dart';
import 'daos/api_cache_dao.dart';
import 'daos/image_cache_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/series_name_dao.dart';
import 'daos/sync_meta_dao.dart';
import 'daos/metron_entity_dao.dart';
import 'daos/junction_dao.dart';

part 'database.g.dart';

// ── User State Tables (existing) ──────────────────────────────────────────

@TableIndex(name: 'idx_lib_issue', columns: {#metronIssueId})
@TableIndex(name: 'idx_lib_series', columns: {#metronSeriesId})
class LibraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronIssueId => integer()();
  IntColumn get metronSeriesId => integer()();
  TextColumn get ownershipStatus => text()();
  BoolColumn get isRead => boolean()();
  IntColumn get rating => integer().nullable()();
  TextColumn get purchaseDate => text().nullable()();
  RealColumn get pricePaid => real().nullable()();
  IntColumn get quantityOwned => integer().withDefault(const Constant(1))();
  TextColumn get format => text()();
  TextColumn get firstReadAt => text().nullable()();
  TextColumn get conditionGrade => text().nullable()();
  TextColumn get acquiredOn => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_readlog_item', columns: {#collectionItemId})
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

@TableIndex(name: 'idx_pull_issue', columns: {#metronIssueId})
@TableIndex(name: 'idx_pull_series', columns: {#metronSeriesId})
@TableIndex(name: 'idx_pull_release', columns: {#releaseDate})
class PullListEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronIssueId => integer()();
  IntColumn get metronSeriesId => integer()();
  TextColumn get entryStatus => text()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get source => text()();
  TextColumn get generatedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_sub_series', columns: {#metronSeriesId})
class SeriesSubscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get metronSeriesId => integer()();
  BoolColumn get isActive => boolean()();
  BoolColumn get autoAddPull => boolean().withDefault(const Constant(false))();
  TextColumn get subscribedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

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

class ReadingListItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text()();
  TextColumn get targetId => text()();
  BoolColumn get isSeries => boolean()();
  TextColumn get role => text()();
  BoolColumn get isRead => boolean()();
  IntColumn get sortOrder => integer()();

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

// ── Metron Entity Tables (new normalized metadata) ────────────────────────

class MetronIssues extends Table {
  IntColumn get id => integer()();
  TextColumn get number => text()();
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
  BoolColumn get isFullyHydrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetronSeries extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get sortName => text().nullable()();
  IntColumn get volume => integer().nullable()();
  IntColumn get seriesTypeId => integer().nullable()();
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

// ── Junction Tables (logical references, no FK constraints) ─────────────

class IssueCreators extends Table {
  IntColumn get issueId => integer()();
  IntColumn get creatorId => integer()();
  TextColumn get role => text().nullable()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, creatorId};
}

class IssueCharacters extends Table {
  IntColumn get issueId => integer()();
  IntColumn get characterId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, characterId};
}

class IssueArcs extends Table {
  IntColumn get issueId => integer()();
  IntColumn get arcId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, arcId};
}

class IssueTeams extends Table {
  IntColumn get issueId => integer()();
  IntColumn get teamId => integer()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {issueId, teamId};
}

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

class MetronReadingListItems extends Table {
  IntColumn get listId => integer()();
  IntColumn get targetId => integer()();
  IntColumn get order => integer().nullable()();
  TextColumn get issueType => text().nullable()();

  @override
  Set<Column> get primaryKey => {listId, targetId};
}

// ── API Cache & Support Tables (existing) ─────────────────────────────────

class ApiCache extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get entityType => text()();
  TextColumn get payload => text()();
  TextColumn get etag => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

class ImageCache extends Table {
  TextColumn get key => text()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
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

class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
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
    ApiCache,
    ImageCache,
    AppSettings,
    SeriesNameIndex,
    SyncMeta,
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
  late final ApiCacheDao apiCacheDao = ApiCacheDao(this);
  late final ImageCacheDao imageCacheDao = ImageCacheDao(this);
  late final SettingsDao settingsDao = SettingsDao(this);
  late final SeriesNameDao seriesNameDao = SeriesNameDao(this);
  late final SyncMetaDao syncMetaDao = SyncMetaDao(this);
  late final MetronEntityDao metronEntityDao = MetronEntityDao(this);
  late final JunctionDao junctionDao = JunctionDao(this);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA journal_mode=WAL');
        await customStatement('PRAGMA synchronous=NORMAL');
        await customStatement('PRAGMA cache_size=-8000');
        await customStatement('PRAGMA busy_timeout=5000');
        await customStatement('PRAGMA temp_store=MEMORY');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createAll();
          await delete(apiCache).go();
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/takion.sqlite');

    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    final db = NativeDatabase(file);
    return db;
  });
}
