import 'dart:convert';
import 'package:takion/src/data/common/drift/daos/junction_dao.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/data/common/drift/database.dart';
import 'package:takion/src/domain/entities.dart';

class EntityMapper {
  final MetronEntityDao _entityDao;
  final JunctionDao _junctionDao;

  EntityMapper(this._entityDao, this._junctionDao);

  Future<IssueDetails> issueToEntity(MetronIssue row) async {
    final lookups = await _buildLookups([row]);
    return _issueToEntity(row, lookups);
  }

  Future<List<IssueDetails>> batchIssueToEntity(
    List<MetronIssue> rows,
  ) async {
    if (rows.isEmpty) return <IssueDetails>[];
    final lookups = await _buildLookups(rows);
    return rows.map((row) => _issueToEntity(row, lookups)).toList();
  }

  Future<_IssueLookups> _buildLookups(List<MetronIssue> rows) async {
    final issueIds = rows.map((r) => r.id).toList();
    final seriesIds = <int>{};
    final publisherIds = <int>{};
    final imprintIds = <int>{};
    for (final row in rows) {
      if (row.seriesId != null) seriesIds.add(row.seriesId!);
      if (row.publisherId != null) publisherIds.add(row.publisherId!);
      if (row.imprintId != null) imprintIds.add(row.imprintId!);
    }

    final charactersByIssue =
        await _junctionDao.getIssueCharactersForIssues(issueIds);
    final arcsByIssue = await _junctionDao.getIssueArcsForIssues(issueIds);
    final teamsByIssue = await _junctionDao.getIssueTeamsForIssues(issueIds);
    final universesByIssue =
        await _junctionDao.getIssueUniversesForIssues(issueIds);
    final creatorsByIssue =
        await _junctionDao.getIssueCreatorsForIssues(issueIds);

    final characterIds = <int>{};
    final arcIds = <int>{};
    final teamIds = <int>{};
    final universeIds = <int>{};
    final creatorIds = <int>{};
    for (final list in charactersByIssue.values) {
      for (final j in list) {
        characterIds.add(j.characterId);
      }
    }
    for (final list in arcsByIssue.values) {
      for (final j in list) {
        arcIds.add(j.arcId);
      }
    }
    for (final list in teamsByIssue.values) {
      for (final j in list) {
        teamIds.add(j.teamId);
      }
    }
    for (final list in universesByIssue.values) {
      for (final j in list) {
        universeIds.add(j.universeId);
      }
    }
    for (final list in creatorsByIssue.values) {
      for (final j in list) {
        creatorIds.add(j.creatorId);
      }
    }

    final seriesById = await _entityDao.getSeriesByIds(seriesIds.toList());
    final publisherById = await _entityDao.getPublishersByIds(
      publisherIds.toList(),
    );
    final imprintById = await _entityDao.getImprintsByIds(imprintIds.toList());
    final characterById = await _entityDao.getCharactersByIds(
      characterIds.toList(),
    );
    final arcById = await _entityDao.getArcsByIds(arcIds.toList());
    final teamById = await _entityDao.getTeamsByIds(teamIds.toList());
    final universeById = await _entityDao.getUniversesByIds(
      universeIds.toList(),
    );
    final creatorById = await _entityDao.getCreatorsByIds(creatorIds.toList());

    return _IssueLookups(
      seriesById: seriesById,
      publisherById: publisherById,
      imprintById: imprintById,
      characterById: characterById,
      arcById: arcById,
      teamById: teamById,
      universeById: universeById,
      creatorById: creatorById,
      charactersByIssue: charactersByIssue,
      arcsByIssue: arcsByIssue,
      teamsByIssue: teamsByIssue,
      universesByIssue: universesByIssue,
      creatorsByIssue: creatorsByIssue,
    );
  }

  IssueDetails _issueToEntity(MetronIssue row, _IssueLookups lookups) {
    IssueDetailsSeries? series;
    if (row.seriesId != null) {
      final s = lookups.seriesById[row.seriesId];
      if (s != null) {
        series = IssueDetailsSeries(
          id: s.id,
          name: s.name,
          sortName: s.sortName,
          volume: s.volume,
          yearBegan: s.yearBegan,
          seriesType: s.seriesTypeName != null
              ? IssueDetailsNamedRef(
                  id: s.seriesTypeId ?? 0,
                  name: s.seriesTypeName!,
                )
              : null,
        );
      }
    }

    IssueDetailsNamedRef? publisher;
    if (row.publisherId != null) {
      final p = lookups.publisherById[row.publisherId];
      if (p != null) {
        publisher = IssueDetailsNamedRef(id: p.id, name: p.name);
      }
    }

    IssueDetailsNamedRef? imprint;
    if (row.imprintId != null) {
      final i = lookups.imprintById[row.imprintId];
      if (i != null) {
        imprint = IssueDetailsNamedRef(id: i.id, name: i.name);
      }
    }

    final characterJunctions = lookups.charactersByIssue[row.id] ?? const [];
    final characters = <IssueDetailsParticipation>[
      for (final j in characterJunctions)
        IssueDetailsParticipation(
          id: j.characterId,
          name: lookups.characterById[j.characterId]?.name ?? '',
        ),
    ];

    final arcJunctions = lookups.arcsByIssue[row.id] ?? const [];
    final arcs = <IssueDetailsParticipation>[
      for (final j in arcJunctions)
        IssueDetailsParticipation(
          id: j.arcId,
          name: lookups.arcById[j.arcId]?.name ?? '',
        ),
    ];

    final teamJunctions = lookups.teamsByIssue[row.id] ?? const [];
    final teams = <IssueDetailsParticipation>[
      for (final j in teamJunctions)
        IssueDetailsParticipation(
          id: j.teamId,
          name: lookups.teamById[j.teamId]?.name ?? '',
        ),
    ];

    final universeJunctions = lookups.universesByIssue[row.id] ?? const [];
    final universes = <IssueDetailsParticipation>[
      for (final j in universeJunctions)
        IssueDetailsParticipation(
          id: j.universeId,
          name: lookups.universeById[j.universeId]?.name ?? '',
        ),
    ];

    final creditJunctions = lookups.creatorsByIssue[row.id] ?? const [];
    final credits = <IssueDetailsCredit>[
      for (final j in creditJunctions)
        IssueDetailsCredit(
          id: j.creatorId,
          creator: lookups.creatorById[j.creatorId]?.name,
          creatorId: j.creatorId,
          roles: j.role != null
              ? j.role!
                    .split(', ')
                    .map((r) => IssueDetailsCreditRole(id: 0, name: r))
                    .toList()
              : const [],
        ),
    ];

    return IssueDetails(
      id: row.id,
      number: row.number,
      series: series,
      publisher: publisher,
      imprint: imprint,
      coverDate: row.coverDate != null
          ? DateTime.tryParse(row.coverDate!)
          : null,
      storeDate: row.storeDate != null
          ? DateTime.tryParse(row.storeDate!)
          : null,
      focDate: row.focDate != null ? DateTime.tryParse(row.focDate!) : null,
      image: row.imageUrl,
      description: row.description,
      page: row.pageCount,
      price: row.price,
      sku: row.sku,
      upc: row.upc,
      isbn: row.isbn,
      coverHash: row.coverHash,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
      characters: characters,
      arcs: arcs,
      teams: teams,
      universes: universes,
      credits: credits,
    );
  }

  Future<SeriesDetails> seriesToEntity(MetronSery row) async {
    SeriesDetailsNamedRef? publisher;
    if (row.publisherId != null) {
      final p = await _entityDao.getPublisher(row.publisherId!);
      if (p != null) {
        publisher = SeriesDetailsNamedRef(id: p.id, name: p.name);
      }
    }

    return SeriesDetails(
      id: row.id,
      name: row.name,
      sortName: row.sortName,
      volume: row.volume,
      seriesType: row.seriesTypeName != null
          ? SeriesDetailsNamedRef(
              id: row.seriesTypeId ?? 0,
              name: row.seriesTypeName!,
            )
          : null,
      status: row.status,
      yearBegan: row.yearBegan,
      yearEnd: row.yearEnd,
      description: row.description,
      issueCount: row.issueCount,
      image: row.computedCoverUrl,
      publisher: publisher,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  Future<CharacterDetails> characterToEntity(MetronCharacter row) async {
    final characterId = row.id;

    final creatorJunctions = await _junctionDao.getCharacterCreators(
      characterId,
    );
    final creators = <CharacterDetailsNamedRef>[];
    for (final j in creatorJunctions) {
      final c = await _entityDao.getCreator(j.creatorId);
      creators.add(
        CharacterDetailsNamedRef(id: j.creatorId, name: c?.name ?? ''),
      );
    }

    final teamJunctions = await _junctionDao.getCharacterTeams(characterId);
    final teams = <CharacterDetailsNamedRef>[];
    for (final j in teamJunctions) {
      final t = await _entityDao.getTeam(j.teamId);
      teams.add(CharacterDetailsNamedRef(id: j.teamId, name: t?.name ?? ''));
    }

    final universeJunctions = await _junctionDao.getCharacterUniverses(
      characterId,
    );
    final universes = <CharacterDetailsNamedRef>[];
    for (final j in universeJunctions) {
      final u = await _entityDao.getUniverse(j.universeId);
      universes.add(
        CharacterDetailsNamedRef(id: j.universeId, name: u?.name ?? ''),
      );
    }

    return CharacterDetails(
      id: row.id,
      name: row.name,
      slug: '',
      alias: row.aliasJson,
      desc: row.description,
      image: row.imageUrl,
      creators: creators,
      teams: teams,
      universes: universes,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  CreatorDetails creatorToEntity(MetronCreator row) {
    return CreatorDetails(
      id: row.id,
      name: row.name,
      birth: row.birth != null ? DateTime.tryParse(row.birth!) : null,
      death: row.death != null ? DateTime.tryParse(row.death!) : null,
      desc: row.description,
      image: row.imageUrl,
      alias: row.aliasJson != null
          ? (jsonDecode(row.aliasJson!) as List<dynamic>).cast<String>()
          : const [],
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  ArcDetails arcToEntity(MetronArc row) {
    return ArcDetails(
      id: row.id,
      name: row.name,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  Future<TeamDetails> teamToEntity(MetronTeam row) async {
    final teamId = row.id;

    final creatorJunctions = await _junctionDao.getTeamCreators(teamId);
    final creators = <TeamCreatorRef>[];
    for (final j in creatorJunctions) {
      final c = await _entityDao.getCreator(j.creatorId);
      creators.add(TeamCreatorRef(id: j.creatorId, name: c?.name ?? ''));
    }

    final universeJunctions = await _junctionDao.getTeamUniverses(teamId);
    final universes = <UniverseNamedRef>[];
    for (final j in universeJunctions) {
      final u = await _entityDao.getUniverse(j.universeId);
      universes.add(UniverseNamedRef(id: j.universeId, name: u?.name ?? ''));
    }

    return TeamDetails(
      id: row.id,
      name: row.name,
      desc: row.description,
      image: row.imageUrl,
      creators: creators,
      universes: universes,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  UniverseDetails universeToEntity(MetronUniverse row) {
    return UniverseDetails(
      id: row.id,
      name: row.name,
      publisher: row.publisherId != null
          ? UniverseNamedRef(id: row.publisherId!, name: '')
          : null,
      designation: row.designation,
      desc: row.description,
      gcdId: row.gcdId,
      image: row.imageUrl,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  ImprintDetails imprintToEntity(MetronImprint row) {
    return ImprintDetails(
      id: row.id,
      name: row.name,
      publisher: row.publisherId != null
          ? ImprintNamedRef(id: row.publisherId!, name: '')
          : null,
      founded: row.founded,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }

  PublisherDetails publisherToEntity(MetronPublisher row) {
    return PublisherDetails(
      id: row.id,
      name: row.name,
      founded: row.founded,
      country: row.country,
      desc: row.description,
      image: row.imageUrl,
      cvId: row.cvId,
      gcdId: row.gcdId,
      resourceUrl: row.resourceUrl,
      modified: row.modified != null ? DateTime.tryParse(row.modified!) : null,
    );
  }
}

class _IssueLookups {
  _IssueLookups({
    required this.seriesById,
    required this.publisherById,
    required this.imprintById,
    required this.characterById,
    required this.arcById,
    required this.teamById,
    required this.universeById,
    required this.creatorById,
    required this.charactersByIssue,
    required this.arcsByIssue,
    required this.teamsByIssue,
    required this.universesByIssue,
    required this.creatorsByIssue,
  });

  final Map<int, MetronSery> seriesById;
  final Map<int, MetronPublisher> publisherById;
  final Map<int, MetronImprint> imprintById;
  final Map<int, MetronCharacter> characterById;
  final Map<int, MetronArc> arcById;
  final Map<int, MetronTeam> teamById;
  final Map<int, MetronUniverse> universeById;
  final Map<int, MetronCreator> creatorById;
  final Map<int, List<IssueCharacter>> charactersByIssue;
  final Map<int, List<IssueArc>> arcsByIssue;
  final Map<int, List<IssueTeam>> teamsByIssue;
  final Map<int, List<IssueUniverse>> universesByIssue;
  final Map<int, List<IssueCreator>> creatorsByIssue;
}
