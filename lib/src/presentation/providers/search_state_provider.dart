import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

const kSearchBarHeroTag = 'discover-search-bar-hero';

enum SearchTarget { series, issues }

class SearchState {
  const SearchState({
    this.target = SearchTarget.series,
    this.history = const [],
  });

  final SearchTarget target;
  final List<String> history;

  SearchState copyWith({
    SearchTarget? target,
    List<String>? history,
  }) {
    return SearchState(
      target: target ?? this.target,
      history: history ?? this.history,
    );
  }
}

class SearchStateNotifier extends Notifier<SearchState> {
  static const _settingsBoxName = 'settings_box';
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
    final hive = ref.read(hiveServiceProvider);
    final settingsBox = await hive.openBox<dynamic>(_settingsBoxName);

    final rawHistory = settingsBox.get(_historyKey);
    final history = rawHistory is List
        ? rawHistory
              .whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    final rawTarget = settingsBox.get(_targetKey);
    final targetIndex = rawTarget is int ? rawTarget : 0;
    final target = SearchTarget.values.elementAt(
      targetIndex.clamp(0, SearchTarget.values.length - 1),
    );

    state = state.copyWith(target: target, history: history);
  }

  Future<void> _persist() async {
    final hive = ref.read(hiveServiceProvider);
    final settingsBox = await hive.openBox<dynamic>(_settingsBoxName);
    await settingsBox.put(_historyKey, state.history);
    await settingsBox.put(_targetKey, state.target.index);
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

final searchStateProvider =
    NotifierProvider<SearchStateNotifier, SearchState>(
      () => SearchStateNotifier(),
    );
