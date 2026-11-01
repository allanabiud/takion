import "package:drift/drift.dart" show Value, Variable;
import "package:takion/src/data/catalog/dto/dto.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/data/reading_list/dto/reading_list_dto.dart";

/// Bridge between [PagedLocalCache] pages and the normalized catalog tables.
///
/// Caching upserts each list DTO's entity data into the shared `metron_*`
/// tables. Only fields the DTO actually provides are written, so richer
/// columns (`isFullyHydrated`, detail payloads) are never clobbered by a
/// list payload. Reads re-hydrate DTOs from those tables by id, keeping
/// cached pages consistent with the rest of the catalog instead of keeping
/// JSON blobs in the settings key-value store.
///
/// An embedded issue series is normalized by its id (`dto.series.id`); a
/// series snapshot without an id has no row to link to, so such pages read
/// back with `series == null` - the same convention the issue-stub upsert
/// already uses for `dto.series?.id`.
abstract class PagedCacheCodec<T> {
  const PagedCacheCodec();

  /// The normalized-table primary key for [item].
  int entityId(T item);

  /// Upserts every item into the normalized catalog tables.
  Future<void> upsertEntities(AppDatabase db, List<T> items);

  /// Re-hydrates DTOs for [ids], preserving order. Returns `null` when any
  /// id is missing, so callers treat the page as a cache miss rather than
  /// silently serving a partial page.
  Future<List<T>?> loadByIds(AppDatabase db, List<int> ids);
}

/// Marks a nullable column as written when [value] is non-null. A `null`
/// stays absent so an earlier richer value survives the conflict update.
Value<T> _present<T>(T? value) =>
    value == null ? const Value.absent() : Value(value);

class _IssueListCodec extends PagedCacheCodec<IssueListDto> {
  const _IssueListCodec();

  @override
  int entityId(IssueListDto item) => item.id;

  @override
  Future<void> upsertEntities(AppDatabase db, List<IssueListDto> items) async {
    final issues = <MetronIssuesCompanion>[];
    final series = <MetronSeriesCompanion>[];
    for (final dto in items) {
      issues.add(
        MetronIssuesCompanion(
          id: Value(dto.id),
          number: Value(dto.number),
          seriesId: _present(dto.series?.id),
          coverDate: _present(dto.coverDate),
          storeDate: _present(dto.storeDate),
          imageUrl: _present(dto.image),
          issueName: _present(dto.issueName),
          modified: _present(dto.modified),
          coverHash: _present(dto.coverHash),
        ),
      );
      final embedded = dto.series;
      if (embedded != null && embedded.id != null) {
        series.add(
          MetronSeriesCompanion(
            id: Value(embedded.id!),
            name: Value(embedded.name),
            volume: Value<int?>(embedded.volume),
            yearBegan: Value<int?>(embedded.yearBegan),
          ),
        );
      }
    }
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronIssues, issues);
      batch.insertAllOnConflictUpdate(db.metronSeries, series);
    });
  }

  @override
  Future<List<IssueListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    if (ids.isEmpty) return <IssueListDto>[];
    final placeholders = List.filled(ids.length, "?").join(", ");
    final rows = await db
        .customSelect(
          "SELECT i.id, i.number, i.series_id, i.cover_date, i.store_date, "
          "i.image_url, i.issue_name, i.modified, i.cover_hash, "
          "s.name AS series_name, s.volume AS series_volume, "
          "s.year_began AS series_year_began "
          "FROM metron_issues i "
          "LEFT JOIN metron_series s ON s.id = i.series_id "
          "WHERE i.id IN ($placeholders)",
          variables: [for (final id in ids) Variable.withInt(id)],
        )
        .get();

    final byId = <int, Map<String, Object?>>{
      for (final row in rows) row.data["id"] as int: row.data,
    };
    final dtos = <IssueListDto>[];
    for (final id in ids) {
      final data = byId[id];
      if (data == null) return null;
      final seriesId = data["series_id"] as int?;
      final seriesName = data["series_name"] as String?;
      dtos.add(
        IssueListDto(
          id: id,
          number: data["number"] as String? ?? "",
          series: seriesId != null && seriesName != null
              ? IssueListSeriesDto(
                  name: seriesName,
                  volume: (data["series_volume"] as num?)?.toInt() ?? 1,
                  yearBegan: (data["series_year_began"] as num?)?.toInt() ?? 0,
                  id: seriesId,
                )
              : null,
          coverDate: data["cover_date"] as String?,
          storeDate: data["store_date"] as String?,
          image: data["image_url"] as String?,
          issueName: data["issue_name"] as String?,
          modified: data["modified"] as String?,
          coverHash: data["cover_hash"] as String?,
        ),
      );
    }
    return dtos;
  }
}

class _SeriesListCodec extends PagedCacheCodec<SeriesListDto> {
  const _SeriesListCodec();

  @override
  int entityId(SeriesListDto item) => item.id;

  @override
  Future<void> upsertEntities(AppDatabase db, List<SeriesListDto> items) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronSeries, [
        for (final dto in items)
          MetronSeriesCompanion(
            id: Value(dto.id),
            name: Value(dto.series),
            yearBegan: _present(dto.yearBegan),
            yearEnd: _present(dto.yearEnd),
            volume: _present(dto.volume),
            issueCount: _present(dto.issueCount),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<SeriesListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronSeries,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <SeriesListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        SeriesListDto(
          id: row.id,
          series: row.name,
          yearBegan: row.yearBegan,
          yearEnd: row.yearEnd,
          volume: row.volume,
          issueCount: row.issueCount,
          modified: row.modified,
        ),
      );
    }
    return dtos;
  }
}

class _CharacterListCodec extends PagedCacheCodec<CharacterListDto> {
  const _CharacterListCodec();

  @override
  int entityId(CharacterListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<CharacterListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronCharacters, [
        for (final dto in items)
          MetronCharactersCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            slug: Value<String?>(dto.slug),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<CharacterListDto>?> loadByIds(
    AppDatabase db,
    List<int> ids,
  ) async {
    final rows = await (db.select(
      db.metronCharacters,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <CharacterListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        CharacterListDto(
          id: row.id,
          name: row.name,
          slug: row.slug ?? "",
          modified: row.modified,
        ),
      );
    }
    return dtos;
  }
}

class _CreatorListCodec extends PagedCacheCodec<CreatorListDto> {
  const _CreatorListCodec();

  @override
  int entityId(CreatorListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<CreatorListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronCreators, [
        for (final dto in items)
          MetronCreatorsCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<CreatorListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronCreators,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <CreatorListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        CreatorListDto(id: row.id, name: row.name, modified: row.modified),
      );
    }
    return dtos;
  }
}

class _ImprintListCodec extends PagedCacheCodec<ImprintListDto> {
  const _ImprintListCodec();

  @override
  int entityId(ImprintListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<ImprintListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronImprints, [
        for (final dto in items)
          MetronImprintsCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<ImprintListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronImprints,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <ImprintListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        ImprintListDto(id: row.id, name: row.name, modified: row.modified),
      );
    }
    return dtos;
  }
}

class _PublisherListCodec extends PagedCacheCodec<PublisherListDto> {
  const _PublisherListCodec();

  @override
  int entityId(PublisherListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<PublisherListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronPublishers, [
        for (final dto in items)
          MetronPublishersCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<PublisherListDto>?> loadByIds(
    AppDatabase db,
    List<int> ids,
  ) async {
    final rows = await (db.select(
      db.metronPublishers,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <PublisherListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        PublisherListDto(id: row.id, name: row.name, modified: row.modified),
      );
    }
    return dtos;
  }
}

class _TeamListCodec extends PagedCacheCodec<TeamListDto> {
  const _TeamListCodec();

  @override
  int entityId(TeamListDto item) => item.id;

  @override
  Future<void> upsertEntities(AppDatabase db, List<TeamListDto> items) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronTeams, [
        for (final dto in items)
          MetronTeamsCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<TeamListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronTeams,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <TeamListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(TeamListDto(id: row.id, name: row.name, modified: row.modified));
    }
    return dtos;
  }
}

class _UniverseListCodec extends PagedCacheCodec<UniverseListDto> {
  const _UniverseListCodec();

  @override
  int entityId(UniverseListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<UniverseListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronUniverses, [
        for (final dto in items)
          MetronUniversesCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<UniverseListDto>?> loadByIds(
    AppDatabase db,
    List<int> ids,
  ) async {
    final rows = await (db.select(
      db.metronUniverses,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <UniverseListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        UniverseListDto(id: row.id, name: row.name, modified: row.modified),
      );
    }
    return dtos;
  }
}

class _ArcListCodec extends PagedCacheCodec<ArcListDto> {
  const _ArcListCodec();

  @override
  int entityId(ArcListDto item) => item.id;

  @override
  Future<void> upsertEntities(AppDatabase db, List<ArcListDto> items) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronArcs, [
        for (final dto in items)
          MetronArcsCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<ArcListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronArcs,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <ArcListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(ArcListDto(id: row.id, name: row.name, modified: row.modified));
    }
    return dtos;
  }
}

class _ReadingListCodec extends PagedCacheCodec<ReadingListDto> {
  const _ReadingListCodec();

  @override
  int entityId(ReadingListDto item) => item.id;

  @override
  Future<void> upsertEntities(
    AppDatabase db,
    List<ReadingListDto> items,
  ) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.metronReadingLists, [
        for (final dto in items)
          MetronReadingListsCompanion(
            id: Value(dto.id),
            name: Value(dto.name),
            slug: _present(dto.slug),
            listType: _present(dto.listType),
            isPrivate: _present(dto.isPrivate),
            attributionSource: _present(dto.attributionSource),
            averageRating: _present(dto.averageRating),
            ratingCount: _present(dto.ratingCount),
            modified: _present(dto.modified),
          ),
      ]);
    });
  }

  @override
  Future<List<ReadingListDto>?> loadByIds(AppDatabase db, List<int> ids) async {
    final rows = await (db.select(
      db.metronReadingLists,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final row in rows) row.id: row};
    final dtos = <ReadingListDto>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) return null;
      dtos.add(
        ReadingListDto(
          id: row.id,
          name: row.name,
          slug: row.slug,
          listType: row.listType,
          isPrivate: row.isPrivate,
          attributionSource: row.attributionSource,
          averageRating: row.averageRating,
          ratingCount: row.ratingCount,
          modified: row.modified,
        ),
      );
    }
    return dtos;
  }
}

/// Resolves the codec for a [PagedLocalCache] by its cache key prefix.
///
/// Every production prefix must be registered below; an unknown prefix (or a
/// prefix registered for the wrong DTO type) fails fast when the data source
/// constructs its caches instead of at the first cache read.
PagedCacheCodec<T> resolvePagedCacheCodec<T>(String cacheKeyPrefix) {
  final codec = _codecsByPrefix[cacheKeyPrefix];
  if (codec == null) {
    throw ArgumentError.value(
      cacheKeyPrefix,
      "cacheKeyPrefix",
      "No PagedCacheCodec registered for this paged cache prefix",
    );
  }
  return codec as PagedCacheCodec<T>;
}

final Map<String, PagedCacheCodec<dynamic>> _codecsByPrefix = {
  for (final key in const [
    "issue_list",
    "series_issue_list",
    "character_issue_list",
    "team_issue_list",
    "arc_issue_list",
    "issue_search",
    "weekly_releases",
    "foc_releases",
  ])
    key: const _IssueListCodec(),
  for (final key in const [
    "series_list",
    "publisher_series_list",
    "series_search",
  ])
    key: const _SeriesListCodec(),
  for (final key in const ["character_list", "character_search"])
    key: const _CharacterListCodec(),
  for (final key in const ["creator_list", "creator_search"])
    key: const _CreatorListCodec(),
  for (final key in const ["imprint_list", "imprint_search"])
    key: const _ImprintListCodec(),
  for (final key in const ["publisher_list", "publisher_search"])
    key: const _PublisherListCodec(),
  for (final key in const ["team_list", "team_search"])
    key: const _TeamListCodec(),
  for (final key in const ["universe_list", "universe_search"])
    key: const _UniverseListCodec(),
  for (final key in const ["arc_list", "arc_search"])
    key: const _ArcListCodec(),
  "reading_list": const _ReadingListCodec(),
};
