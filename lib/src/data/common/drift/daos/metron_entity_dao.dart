import "package:drift/drift.dart";
import "package:takion/src/data/common/drift/database.dart";

/// CRUD and stream queries for the Metron catalog tables, one method family
/// per entity (issues, series, creators, characters, arcs, teams, universes,
/// publishers, imprints, reading lists) plus batched stub upserts.
class MetronEntityDao extends DatabaseAccessor<AppDatabase> {
  MetronEntityDao(super.db);


  Future<MetronIssue?> getIssue(int id) async {
    return (select(
      attachedDatabase.metronIssues,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronIssue>> getIssuesByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronIssues,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Future<List<MetronIssue>> getIssuesBySeries(
    int seriesId, {
    int limit = 200,
  }) {
    return (select(attachedDatabase.metronIssues)
          ..where((t) => t.seriesId.equals(seriesId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.coverDate,
              mode: OrderingMode.desc,
            ),
            (t) =>
                OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<MetronIssue>> watchIssuesBySeries(
    int seriesId, {
    int limit = 200,
  }) {
    return (select(attachedDatabase.metronIssues)
          ..where((t) => t.seriesId.equals(seriesId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.coverDate,
              mode: OrderingMode.desc,
            ),
            (t) =>
                OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<MetronIssue?> watchIssue(int id) {
    return (select(
      attachedDatabase.metronIssues,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<MetronIssue>> watchAllIssues() {
    return select(attachedDatabase.metronIssues).watch();
  }

  Future<void> upsertIssue(MetronIssuesCompanion companion) async {
    await into(attachedDatabase.metronIssues).insertOnConflictUpdate(companion);
    if (companion.seriesId.present && companion.seriesId.value != null) {
      await _recomputeSeriesCoverIfNeeded(companion.seriesId.value!);
    }
  }

  Future<void> _recomputeSeriesCoverIfNeeded(int seriesId) async {
    final series = await getSeries(seriesId);
    if (series == null) return;
    final existingCover = series.computedCoverUrl;
    if (existingCover != null && existingCover.isNotEmpty) return;
    final coverUrl = await computeSeriesCoverUrl(seriesId);
    if (coverUrl != null) {
      await (update(attachedDatabase.metronSeries)
            ..where((t) => t.id.equals(seriesId)))
          .write(MetronSeriesCompanion(computedCoverUrl: Value(coverUrl)));
    }
  }


  Future<MetronSery?> getSeries(int id) async {
    return (select(
      attachedDatabase.metronSeries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronSery>> getSeriesByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronSeries,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Future<Map<int, int>> getSeriesIssueCounts(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronSeries,
    )..where((t) => t.id.isIn(ids))).get();
    return {
      for (final row in rows)
        if (row.issueCount != null) row.id: row.issueCount!,
    };
  }

  Stream<MetronSery?> watchSeries(int id) {
    return (select(
      attachedDatabase.metronSeries,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<List<MetronSery>> searchSeriesLocally(
    String query, {
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query
        .trim()
        .replaceAll("%", "\\%")
        .replaceAll("_", "\\_");
    return (select(attachedDatabase.metronSeries)
          ..where((t) => t.name.like("%$cleanQuery%"))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
            (t) =>
                OrderingTerm(expression: t.yearBegan, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> upsertSeries(MetronSeriesCompanion companion) async {
    await into(attachedDatabase.metronSeries).insertOnConflictUpdate(companion);
  }

  Future<String?> computeSeriesCoverUrl(int seriesId) async {
    final query = selectOnly(attachedDatabase.metronIssues)
      ..addColumns([attachedDatabase.metronIssues.imageUrl])
      ..where(attachedDatabase.metronIssues.seriesId.equals(seriesId))
      ..orderBy([
        OrderingTerm(
          expression: attachedDatabase.metronIssues.coverDate,
          mode: OrderingMode.asc,
        ),
        OrderingTerm(
          expression: attachedDatabase.metronIssues.id,
          mode: OrderingMode.asc,
        ),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return row.read(attachedDatabase.metronIssues.imageUrl);
  }

  Stream<String?> watchSeriesCoverUrl(int seriesId) {
    final query = selectOnly(attachedDatabase.metronIssues)
      ..addColumns([attachedDatabase.metronIssues.imageUrl])
      ..where(attachedDatabase.metronIssues.seriesId.equals(seriesId))
      ..orderBy([
        OrderingTerm(
          expression: attachedDatabase.metronIssues.coverDate,
          mode: OrderingMode.asc,
        ),
        OrderingTerm(
          expression: attachedDatabase.metronIssues.id,
          mode: OrderingMode.asc,
        ),
      ])
      ..limit(1);
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return row.read(attachedDatabase.metronIssues.imageUrl);
    });
  }


  Future<MetronCreator?> getCreator(int id) async {
    return (select(
      attachedDatabase.metronCreators,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronCreator>> getCreatorsByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronCreators,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronCreator?> watchCreator(int id) {
    return (select(
      attachedDatabase.metronCreators,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertCreator(MetronCreatorsCompanion companion) async {
    await into(
      attachedDatabase.metronCreators,
    ).insertOnConflictUpdate(companion);
  }


  Future<MetronCharacter?> getCharacter(int id) async {
    return (select(
      attachedDatabase.metronCharacters,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronCharacter>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronCharacters,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronCharacter?> watchCharacter(int id) {
    return (select(
      attachedDatabase.metronCharacters,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertCharacter(MetronCharactersCompanion companion) async {
    await into(
      attachedDatabase.metronCharacters,
    ).insertOnConflictUpdate(companion);
  }


  Future<MetronArc?> getArc(int id) async {
    return (select(
      attachedDatabase.metronArcs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronArc>> getArcsByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronArcs,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronArc?> watchArc(int id) {
    return (select(
      attachedDatabase.metronArcs,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertArc(MetronArcsCompanion companion) async {
    await into(attachedDatabase.metronArcs).insertOnConflictUpdate(companion);
  }


  Future<MetronTeam?> getTeam(int id) async {
    return (select(
      attachedDatabase.metronTeams,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronTeam>> getTeamsByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronTeams,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronTeam?> watchTeam(int id) {
    return (select(
      attachedDatabase.metronTeams,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertTeam(MetronTeamsCompanion companion) async {
    await into(attachedDatabase.metronTeams).insertOnConflictUpdate(companion);
  }


  Future<MetronUniverse?> getUniverse(int id) async {
    return (select(
      attachedDatabase.metronUniverses,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronUniverse>> getUniversesByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronUniverses,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronUniverse?> watchUniverse(int id) {
    return (select(
      attachedDatabase.metronUniverses,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertUniverse(MetronUniversesCompanion companion) async {
    await into(
      attachedDatabase.metronUniverses,
    ).insertOnConflictUpdate(companion);
  }


  Future<MetronPublisher?> getPublisher(int id) async {
    return (select(
      attachedDatabase.metronPublishers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronPublisher>> getPublishersByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronPublishers,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronPublisher?> watchPublisher(int id) {
    return (select(
      attachedDatabase.metronPublishers,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertPublisher(MetronPublishersCompanion companion) async {
    await into(
      attachedDatabase.metronPublishers,
    ).insertOnConflictUpdate(companion);
  }


  Future<MetronImprint?> getImprint(int id) async {
    return (select(
      attachedDatabase.metronImprints,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, MetronImprint>> getImprintsByIds(List<int> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      attachedDatabase.metronImprints,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.id: r};
  }

  Stream<MetronImprint?> watchImprint(int id) {
    return (select(
      attachedDatabase.metronImprints,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertImprint(MetronImprintsCompanion companion) async {
    await into(
      attachedDatabase.metronImprints,
    ).insertOnConflictUpdate(companion);
  }


  Future<MetronReadingList?> getMetronReadingList(int id) async {
    return (select(
      attachedDatabase.metronReadingLists,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<MetronReadingList?> watchMetronReadingList(int id) {
    return (select(
      attachedDatabase.metronReadingLists,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> upsertMetronReadingList(
    MetronReadingListsCompanion companion,
  ) async {
    await into(
      attachedDatabase.metronReadingLists,
    ).insertOnConflictUpdate(companion);
  }

  Future<List<MetronReadingListItem>> getMetronReadingListItems(
    int listId,
  ) async {
    return (select(attachedDatabase.metronReadingListItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.order, mode: OrderingMode.asc),
          ]))
        .get();
  }


  Future<void> upsertIssueStub(
    int id,
    int? seriesId,
    String number,
    String? imageUrl, {
    DateTime? storeDate,
    DateTime? coverDate,
    String? coverHash,
  }) async {
    await into(attachedDatabase.metronIssues).insertOnConflictUpdate(
      MetronIssuesCompanion(
        id: Value(id),
        number: Value(number),
        seriesId: Value(seriesId),
        imageUrl: Value(imageUrl),
        storeDate: Value(storeDate?.toIso8601String()),
        coverDate: Value(coverDate?.toIso8601String()),
        coverHash: Value(coverHash),
        isFullyHydrated: const Value(false),
      ),
    );
    if (seriesId != null) {
      await _recomputeSeriesCoverIfNeeded(seriesId);
    }
  }

  Future<void> upsertSeriesStub(
    int id,
    String name, {
    int? publisherId,
    int? yearBegan,
    int? yearEnd,
    int? volume,
    int? issueCount,
    String? modified,
  }) async {
    await into(attachedDatabase.metronSeries).insertOnConflictUpdate(
      MetronSeriesCompanion(
        id: Value(id),
        name: Value(name),
        publisherId: Value(publisherId),
        yearBegan: Value(yearBegan),
        yearEnd: Value(yearEnd),
        volume: Value(volume),
        issueCount: Value(issueCount),
        modified: Value(modified),
        isFullyHydrated: const Value(false),
      ),
    );
  }

  Future<void> upsertCharacterStubsBatch(
    List<MetronCharactersCompanion> stubs,
  ) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronCharacters,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }

  Future<void> upsertCreatorStubsBatch(
    List<MetronCreatorsCompanion> stubs,
  ) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronCreators,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }

  Future<void> upsertArcStubsBatch(List<MetronArcsCompanion> stubs) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronArcs,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }

  Future<void> upsertTeamStubsBatch(List<MetronTeamsCompanion> stubs) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronTeams,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }

  Future<void> upsertUniverseStubsBatch(
    List<MetronUniversesCompanion> stubs,
  ) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronUniverses,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }

  Future<void> upsertIssueStubsBatch(List<MetronIssuesCompanion> stubs) async {
    if (stubs.isEmpty) return;
    final affectedSeriesIds = <int>{};
    for (final stub in stubs) {
      if (stub.seriesId.present && stub.seriesId.value != null) {
        affectedSeriesIds.add(stub.seriesId.value!);
      }
    }
    await transaction(() async {
      await batch((b) {
        for (final stub in stubs) {
          b.insert(
            attachedDatabase.metronIssues,
            stub,
            onConflict: DoUpdate(
              (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
            ),
          );
        }
      });
      for (final seriesId in affectedSeriesIds) {
        await _recomputeSeriesCoverIfNeeded(seriesId);
      }
    });
  }

  Future<void> upsertSeriesStubsBatch(List<MetronSeriesCompanion> stubs) async {
    if (stubs.isEmpty) return;
    await batch((b) {
      for (final stub in stubs) {
        b.insert(
          attachedDatabase.metronSeries,
          stub,
          onConflict: DoUpdate(
            (_) => stub.copyWith(isFullyHydrated: const Value.absent()),
          ),
        );
      }
    });
  }
}
