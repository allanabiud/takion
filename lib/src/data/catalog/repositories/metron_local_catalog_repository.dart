import "package:takion/src/data/catalog/mappers/entity_mapper.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/catalog/repositories/local_catalog_repository.dart";
import "package:takion/src/domain/entities.dart";

/// Implements local catalog cache reads on top of the Drift entity DAO and
/// the [EntityMapper], returning domain-safe projections.
class MetronLocalCatalogRepository implements LocalCatalogRepository {
  MetronLocalCatalogRepository(this._entityDao, this._mapper);

  final MetronEntityDao _entityDao;
  final EntityMapper _mapper;

  SeriesList _seriesToDomain(MetronSery row) {
    return SeriesList(
      id: row.id,
      name: row.name,
      volume: row.volume,
      yearBegan: row.yearBegan,
      yearEnd: row.yearEnd,
      issueCount: row.issueCount,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  LocalIssue _issueToDomain(MetronIssue row) {
    return LocalIssue(
      id: row.id,
      seriesId: row.seriesId,
      number: row.number,
      imageUrl: row.imageUrl,
      coverDate: row.coverDate != null
          ? DateTime.tryParse(row.coverDate!)
          : null,
      storeDate: row.storeDate != null
          ? DateTime.tryParse(row.storeDate!)
          : null,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
      price: row.price,
      isFullyHydrated: row.isFullyHydrated,
    );
  }

  CreatorList _creatorToDomain(MetronCreator row) {
    return CreatorList(
      id: row.id,
      name: row.name,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  @override
  Future<SeriesList?> getSeries(int seriesId) async {
    final row = await _entityDao.getSeries(seriesId);
    return row == null ? null : _seriesToDomain(row);
  }

  @override
  Future<Map<int, SeriesList>> getSeriesByIds(List<int> seriesIds) async {
    final rows = await _entityDao.getSeriesByIds(seriesIds);
    return {
      for (final entry in rows.entries) entry.key: _seriesToDomain(entry.value),
    };
  }

  @override
  Future<LocalIssue?> getIssue(int issueId) async {
    final row = await _entityDao.getIssue(issueId);
    return row == null ? null : _issueToDomain(row);
  }

  @override
  Future<Map<int, LocalIssue>> getIssuesByIds(List<int> issueIds) async {
    final rows = await _entityDao.getIssuesByIds(issueIds);
    return {
      for (final entry in rows.entries) entry.key: _issueToDomain(entry.value),
    };
  }

  @override
  Future<CreatorList?> getCreator(int creatorId) async {
    final row = await _entityDao.getCreator(creatorId);
    return row == null ? null : _creatorToDomain(row);
  }

  @override
  Future<Map<int, CreatorList>> getCreatorsByIds(List<int> creatorIds) async {
    final rows = await _entityDao.getCreatorsByIds(creatorIds);
    return {
      for (final entry in rows.entries)
        entry.key: _creatorToDomain(entry.value),
    };
  }

  @override
  Future<List<LocalIssue>> getIssuesBySeries(
    int seriesId, {
    int limit = 200,
  }) async {
    final rows = await _entityDao.getIssuesBySeries(seriesId, limit: limit);
    return rows.map(_issueToDomain).toList();
  }

  @override
  Stream<SeriesList?> watchSeries(int seriesId) {
    return _entityDao
        .watchSeries(seriesId)
        .map((row) => row == null ? null : _seriesToDomain(row));
  }

  @override
  Stream<String?> watchSeriesCoverUrl(int seriesId) {
    return _entityDao.watchSeriesCoverUrl(seriesId);
  }

  @override
  Future<List<SeriesList>> searchSeriesLocally(
    String query, {
    int limit = 50,
  }) async {
    final rows = await _entityDao.searchSeriesLocally(query, limit: limit);
    return rows.map(_seriesToDomain).toList();
  }

  @override
  Stream<SeriesDetails?> watchSeriesDetails(int seriesId) {
    return _entityDao
        .watchSeries(seriesId)
        .asyncMap((row) => row == null ? null : _mapper.seriesToEntity(row));
  }

  @override
  Stream<IssueDetails?> watchIssueDetails(int issueId) {
    return _entityDao
        .watchIssue(issueId)
        .asyncMap((row) => row == null ? null : _mapper.issueToEntity(row));
  }

  @override
  Stream<List<LocalIssue>> watchIssuesBySeries(int seriesId) {
    return _entityDao
        .watchIssuesBySeries(seriesId)
        .map((rows) => rows.map(_issueToDomain).toList());
  }

  @override
  Stream<List<LocalIssue>> watchAllIssues() {
    return _entityDao.watchAllIssues().map(
      (rows) => rows.map(_issueToDomain).toList(),
    );
  }

  @override
  Future<List<IssueDetails>> hydrateIssueDetails(List<int> issueIds) async {
    final rows = await _entityDao.getIssuesByIds(issueIds);
    final ordered = <MetronIssue>[];
    for (final id in issueIds) {
      final row = rows[id];
      if (row != null) ordered.add(row);
    }
    return _mapper.batchIssueToEntity(ordered);
  }

  @override
  Future<IssueDetails?> hydrateIssueDetail(int issueId) async {
    final row = await _entityDao.getIssue(issueId);
    if (row == null) return null;
    return _mapper.issueToEntity(row);
  }
}
