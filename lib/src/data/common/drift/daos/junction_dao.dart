import 'package:drift/drift.dart';
import 'package:takion/src/data/common/drift/database.dart';

class JunctionDao extends DatabaseAccessor<AppDatabase> {
  JunctionDao(super.db);

  Future<void> insertIgnoreIssueCreator(IssueCreatorsCompanion entry) async {
    await into(attachedDatabase.issueCreators).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertIssueCreators(
    List<IssueCreatorsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.issueCreators, entries);
    });
  }

  Future<void> insertIgnoreIssueCharacter(
    IssueCharactersCompanion entry,
  ) async {
    await into(attachedDatabase.issueCharacters).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertIssueCharacters(
    List<IssueCharactersCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.issueCharacters, entries);
    });
  }

  Future<void> insertIgnoreIssueArc(IssueArcsCompanion entry) async {
    await into(attachedDatabase.issueArcs).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertIssueArcs(List<IssueArcsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.issueArcs, entries);
    });
  }

  Future<void> insertIgnoreIssueTeam(IssueTeamsCompanion entry) async {
    await into(attachedDatabase.issueTeams).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertIssueTeams(List<IssueTeamsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.issueTeams, entries);
    });
  }

  Future<void> insertIgnoreIssueUniverse(IssueUniversesCompanion entry) async {
    await into(attachedDatabase.issueUniverses).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertIssueUniverses(
    List<IssueUniversesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.issueUniverses, entries);
    });
  }

  Future<void> insertIgnoreIssueImprint(IssueImprintsCompanion entry) async {
    await into(attachedDatabase.issueImprints).insertOnConflictUpdate(entry);
  }

  Future<void> insertIgnoreSeriesArc(SeriesArcsCompanion entry) async {
    await into(attachedDatabase.seriesArcs).insertOnConflictUpdate(entry);
  }

  Future<void> insertIgnoreSeriesTeam(SeriesTeamsCompanion entry) async {
    await into(attachedDatabase.seriesTeams).insertOnConflictUpdate(entry);
  }

  Future<void> insertIgnoreSeriesUniverse(
    SeriesUniversesCompanion entry,
  ) async {
    await into(attachedDatabase.seriesUniverses).insertOnConflictUpdate(entry);
  }

  Future<void> insertIgnoreAssociatedSeries(
    AssociatedSeriesCompanion entry,
  ) async {
    await into(attachedDatabase.associatedSeries).insertOnConflictUpdate(entry);
  }

  Future<void> insertIgnoreCharacterCreator(
    CharacterCreatorsCompanion entry,
  ) async {
    await into(
      attachedDatabase.characterCreators,
    ).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertCharacterCreators(
    List<CharacterCreatorsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.characterCreators, entries);
    });
  }

  Future<void> insertIgnoreCharacterTeam(CharacterTeamsCompanion entry) async {
    await into(attachedDatabase.characterTeams).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertCharacterTeams(
    List<CharacterTeamsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.characterTeams, entries);
    });
  }

  Future<void> insertIgnoreCharacterUniverse(
    CharacterUniversesCompanion entry,
  ) async {
    await into(
      attachedDatabase.characterUniverses,
    ).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertCharacterUniverses(
    List<CharacterUniversesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.characterUniverses, entries);
    });
  }

  Future<void> insertIgnoreCreatorTeam(CreatorTeamsCompanion entry) async {
    await into(attachedDatabase.creatorTeams).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertCreatorTeams(
    List<CreatorTeamsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.creatorTeams, entries);
    });
  }

  Future<void> insertIgnoreTeamUniverse(TeamUniversesCompanion entry) async {
    await into(attachedDatabase.teamUniverses).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertTeamUniverses(
    List<TeamUniversesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(attachedDatabase.teamUniverses, entries);
    });
  }

  Future<void> insertIgnoreMetronReadingListItem(
    MetronReadingListItemsCompanion entry,
  ) async {
    await into(
      attachedDatabase.metronReadingListItems,
    ).insertOnConflictUpdate(entry);
  }

  Future<void> batchInsertMetronReadingListItems(
    List<MetronReadingListItemsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(
        attachedDatabase.metronReadingListItems,
        entries,
      );
    });
  }

  Future<void> clearMetronReadingListItems(int listId) async {
    await (delete(
      attachedDatabase.metronReadingListItems,
    )..where((t) => t.listId.equals(listId))).go();
  }

  Future<List<IssueCharacter>> getIssueCharacters(int issueId) async {
    return (select(attachedDatabase.issueCharacters)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (u) =>
                OrderingTerm(expression: u.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<IssueCreator>> getIssueCreators(int issueId) async {
    return (select(attachedDatabase.issueCreators)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (u) =>
                OrderingTerm(expression: u.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<IssueArc>> getIssueArcs(int issueId) async {
    return (select(attachedDatabase.issueArcs)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (u) =>
                OrderingTerm(expression: u.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<IssueTeam>> getIssueTeams(int issueId) async {
    return (select(attachedDatabase.issueTeams)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (u) =>
                OrderingTerm(expression: u.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<IssueUniverse>> getIssueUniverses(int issueId) async {
    return (select(attachedDatabase.issueUniverses)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (u) =>
                OrderingTerm(expression: u.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<CharacterCreator>> getCharacterCreators(int characterId) async {
    return (select(
      attachedDatabase.characterCreators,
    )..where((t) => t.characterId.equals(characterId))).get();
  }

  Future<List<CharacterTeam>> getCharacterTeams(int characterId) async {
    return (select(
      attachedDatabase.characterTeams,
    )..where((t) => t.characterId.equals(characterId))).get();
  }

  Future<List<CharacterUniverse>> getCharacterUniverses(int characterId) async {
    return (select(
      attachedDatabase.characterUniverses,
    )..where((t) => t.characterId.equals(characterId))).get();
  }

  Future<List<CreatorTeam>> getTeamCreators(int teamId) async {
    return (select(
      attachedDatabase.creatorTeams,
    )..where((t) => t.teamId.equals(teamId))).get();
  }

  Future<List<TeamUniverse>> getTeamUniverses(int teamId) async {
    return (select(
      attachedDatabase.teamUniverses,
    )..where((t) => t.teamId.equals(teamId))).get();
  }

  Future<void> clearIssueJunctions(int issueId) async {
    await (delete(
      attachedDatabase.issueCreators,
    )..where((t) => t.issueId.equals(issueId))).go();
    await (delete(
      attachedDatabase.issueCharacters,
    )..where((t) => t.issueId.equals(issueId))).go();
    await (delete(
      attachedDatabase.issueArcs,
    )..where((t) => t.issueId.equals(issueId))).go();
    await (delete(
      attachedDatabase.issueTeams,
    )..where((t) => t.issueId.equals(issueId))).go();
    await (delete(
      attachedDatabase.issueUniverses,
    )..where((t) => t.issueId.equals(issueId))).go();
    await (delete(
      attachedDatabase.issueImprints,
    )..where((t) => t.issueId.equals(issueId))).go();
  }

  Future<void> clearCharacterJunctions(int characterId) async {
    await (delete(
      attachedDatabase.characterCreators,
    )..where((t) => t.characterId.equals(characterId))).go();
    await (delete(
      attachedDatabase.characterTeams,
    )..where((t) => t.characterId.equals(characterId))).go();
    await (delete(
      attachedDatabase.characterUniverses,
    )..where((t) => t.characterId.equals(characterId))).go();
  }

  Future<void> clearTeamJunctions(int teamId) async {
    await (delete(
      attachedDatabase.creatorTeams,
    )..where((t) => t.teamId.equals(teamId))).go();
    await (delete(
      attachedDatabase.teamUniverses,
    )..where((t) => t.teamId.equals(teamId))).go();
  }
}
