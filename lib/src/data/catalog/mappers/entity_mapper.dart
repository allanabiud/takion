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
    IssueDetailsSeries? series;
    if (row.seriesId != null) {
      final s = await _entityDao.getSeries(row.seriesId!);
      if (s != null) {
        series = IssueDetailsSeries(
          id: s.id,
          name: s.name,
          sortName: s.sortName,
          volume: s.volume,
          yearBegan: s.yearBegan,
        );
      }
    }

    IssueDetailsNamedRef? publisher;
    if (row.publisherId != null) {
      final p = await _entityDao.getPublisher(row.publisherId!);
      if (p != null) {
        publisher = IssueDetailsNamedRef(id: p.id, name: p.name);
      }
    }

    IssueDetailsNamedRef? imprint;
    if (row.imprintId != null) {
      final i = await _entityDao.getImprint(row.imprintId!);
      if (i != null) {
        imprint = IssueDetailsNamedRef(id: i.id, name: i.name);
      }
    }

    final characterJunctions = await _junctionDao.getIssueCharacters(row.id);
    final characters = <IssueDetailsParticipation>[];
    for (final j in characterJunctions) {
      final c = await _entityDao.getCharacter(j.characterId);
      characters.add(
        IssueDetailsParticipation(id: j.characterId, name: c?.name ?? ''),
      );
    }

    final arcJunctions = await _junctionDao.getIssueArcs(row.id);
    final arcs = <IssueDetailsParticipation>[];
    for (final j in arcJunctions) {
      final a = await _entityDao.getArc(j.arcId);
      arcs.add(IssueDetailsParticipation(id: j.arcId, name: a?.name ?? ''));
    }

    final teamJunctions = await _junctionDao.getIssueTeams(row.id);
    final teams = <IssueDetailsParticipation>[];
    for (final j in teamJunctions) {
      final t = await _entityDao.getTeam(j.teamId);
      teams.add(IssueDetailsParticipation(id: j.teamId, name: t?.name ?? ''));
    }

    final universeJunctions = await _junctionDao.getIssueUniverses(row.id);
    final universes = <IssueDetailsParticipation>[];
    for (final j in universeJunctions) {
      final u = await _entityDao.getUniverse(j.universeId);
      universes.add(
        IssueDetailsParticipation(id: j.universeId, name: u?.name ?? ''),
      );
    }

    final creditJunctions = await _junctionDao.getIssueCreators(row.id);
    final credits = <IssueDetailsCredit>[];
    for (final j in creditJunctions) {
      final c = await _entityDao.getCreator(j.creatorId);
      credits.add(
        IssueDetailsCredit(
          id: j.creatorId,
          creator: c?.name,
          creatorId: j.creatorId,
          roles: j.role != null
              ? j.role!
                    .split(', ')
                    .map((r) => IssueDetailsCreditRole(id: 0, name: r))
                    .toList()
              : const [],
        ),
      );
    }

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
