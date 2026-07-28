import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

const kSearchBarHeroTag = 'discover-search-bar-hero';

enum SearchTarget {
  series,
  issues,
  characters,
  creators,
  universes,
  imprints,
  teams,
  publishers,
  arcs,
}

class SearchState {
  const SearchState({
    this.target = SearchTarget.series,
    this.history = const [],
  });

  final SearchTarget target;
  final List<String> history;

  SearchState copyWith({SearchTarget? target, List<String>? history}) {
    return SearchState(
      target: target ?? this.target,
      history: history ?? this.history,
    );
  }
}

class SearchStateNotifier extends Notifier<SearchState> {
  static const _historyKey = 'search_history';
  static const _targetKey = 'search_target';

  bool _hydrated = false;

  @override
  SearchState build() {
    if (!_hydrated) {
      _hydrated = true;
      Future.microtask(_hydrateFromStorage);
    }
    return const SearchState();
  }

  Future<void> _hydrateFromStorage() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final rawHistory = await dao.getString(_historyKey);
    final history = rawHistory?.split(',') ?? <String>[];
    final cleanHistory = history
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final rawTarget = await dao.getString(_targetKey);
    final targetIndex = int.tryParse(rawTarget ?? '') ?? 0;
    final target = SearchTarget.values.elementAt(
      targetIndex.clamp(0, SearchTarget.values.length - 1),
    );

    state = state.copyWith(target: target, history: cleanHistory);
  }

  Future<void> _persist() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setString(_historyKey, state.history.join(','));
    await dao.setString(_targetKey, state.target.index.toString());
  }

  void setTarget(SearchTarget target) {
    state = state.copyWith(target: target);
    _persist();
  }

  void addHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final nextHistory = [
      trimmed,
      ...state.history.where(
        (item) => item.toLowerCase() != trimmed.toLowerCase(),
      ),
    ];

    state = state.copyWith(history: nextHistory);
    _persist();
  }

  void removeHistory(String query) {
    state = state.copyWith(
      history: state.history.where((item) => item != query).toList(),
    );
    _persist();
  }
}

final searchStateProvider = NotifierProvider<SearchStateNotifier, SearchState>(
  () => SearchStateNotifier(),
);
