import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";

/// A fast, synchronous in-memory metadata store for Metron catalog entities.
/// Allows UI widgets (list tiles, cards, covers, badges) to synchronously resolve
/// basic entity names and relationships without spawning asynchronous futures or
/// triggering secondary database queries.
class MetronMetadataCache {
  MetronMetadataCache({this.versionNotifier});

  final MetadataVersionNotifier? versionNotifier;

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

  void _notify() {
    versionNotifier?.bump();
  }

  void indexSeries(int id, String name) {
    if (name.isNotEmpty && _seriesNames[id] != name) {
      _seriesNames[id] = name;
      _notify();
    }
  }

  void indexPublisher(int id, String name) {
    if (name.isNotEmpty && _publisherNames[id] != name) {
      _publisherNames[id] = name;
      _notify();
    }
  }

  void indexCharacter(int id, String name) {
    if (name.isNotEmpty && _characterNames[id] != name) {
      _characterNames[id] = name;
      _notify();
    }
  }

  void indexCreator(int id, String name) {
    if (name.isNotEmpty && _creatorNames[id] != name) {
      _creatorNames[id] = name;
      _notify();
    }
  }

  void indexImprint(int id, String name) {
    if (name.isNotEmpty && _imprintNames[id] != name) {
      _imprintNames[id] = name;
      _notify();
    }
  }

  void indexBatchSeries(Map<int, String> entries) {
    if (entries.isNotEmpty) {
      _seriesNames.addAll(entries);
      _notify();
    }
  }

  void indexBatchPublishers(Map<int, String> entries) {
    if (entries.isNotEmpty) {
      _publisherNames.addAll(entries);
      _notify();
    }
  }

  void indexBatchCharacters(Map<int, String> entries) {
    if (entries.isNotEmpty) {
      _characterNames.addAll(entries);
      _notify();
    }
  }

  void indexBatchCreators(Map<int, String> entries) {
    if (entries.isNotEmpty) {
      _creatorNames.addAll(entries);
      _notify();
    }
  }

  void indexBatchImprints(Map<int, String> entries) {
    if (entries.isNotEmpty) {
      _imprintNames.addAll(entries);
      _notify();
    }
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
    _notify();
  }

  void clear() {
    _seriesNames.clear();
    _publisherNames.clear();
    _characterNames.clear();
    _creatorNames.clear();
    _imprintNames.clear();
    _notify();
  }
}

class MetadataVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state++;
  }
}

final metronMetadataVersionProvider =
    NotifierProvider<MetadataVersionNotifier, int>(
      MetadataVersionNotifier.new,
    );

/// Global Riverpod provider for [MetronMetadataCache].
final metronMetadataCacheProvider = Provider<MetronMetadataCache>((ref) {
  final versionNotifier = ref.read(metronMetadataVersionProvider.notifier);
  return MetronMetadataCache(versionNotifier: versionNotifier);
});
