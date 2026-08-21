import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";

/// A fast, synchronous in-memory metadata store for Metron catalog entities.
/// Allows UI widgets (list tiles, cards, covers, badges) to synchronously resolve
/// basic entity names and relationships without spawning asynchronous futures or
/// triggering secondary database queries.
class MetronMetadataCache {
  final Map<int, String> _seriesNames = {};
  final Map<int, String> _publisherNames = {};
  final Map<int, String> _characterNames = {};
  final Map<int, String> _creatorNames = {};
  final Map<int, String> _imprintNames = {};

  String? getSeriesName(int id) => _seriesNames[id];
  String? getPublisherName(int id) => _publisherNames[id];
  String? getCharacterName(int id) => _characterNames[id];
  String? getCreatorName(int id) => _creatorNames[id];
  String? getImprintName(int id) => _imprintNames[id];

  void indexSeries(int id, String name) {
    if (name.isNotEmpty) _seriesNames[id] = name;
  }

  void indexPublisher(int id, String name) {
    if (name.isNotEmpty) _publisherNames[id] = name;
  }

  void indexCharacter(int id, String name) {
    if (name.isNotEmpty) _characterNames[id] = name;
  }

  void indexCreator(int id, String name) {
    if (name.isNotEmpty) _creatorNames[id] = name;
  }

  void indexImprint(int id, String name) {
    if (name.isNotEmpty) _imprintNames[id] = name;
  }

  void indexBatchSeries(Map<int, String> entries) {
    _seriesNames.addAll(entries);
  }

  void indexBatchPublishers(Map<int, String> entries) {
    _publisherNames.addAll(entries);
  }

  void indexBatchCharacters(Map<int, String> entries) {
    _characterNames.addAll(entries);
  }

  void indexBatchCreators(Map<int, String> entries) {
    _creatorNames.addAll(entries);
  }

  void indexBatchImprints(Map<int, String> entries) {
    _imprintNames.addAll(entries);
  }

  Future<void> hydrateFromDatabase(MetronEntityDao entityDao) async {
    final series = await entityDao.getAllSeriesNames();
    final publishers = await entityDao.getAllPublisherNames();
    final characters = await entityDao.getAllCharacterNames();
    final creators = await entityDao.getAllCreatorNames();
    final imprints = await entityDao.getAllImprintNames();

    _seriesNames.addAll(series);
    _publisherNames.addAll(publishers);
    _characterNames.addAll(characters);
    _creatorNames.addAll(creators);
    _imprintNames.addAll(imprints);
  }

  void clear() {
    _seriesNames.clear();
    _publisherNames.clear();
    _characterNames.clear();
    _creatorNames.clear();
    _imprintNames.clear();
  }
}

/// Global Riverpod provider for [MetronMetadataCache].
final metronMetadataCacheProvider = Provider<MetronMetadataCache>((ref) {
  return MetronMetadataCache();
});

