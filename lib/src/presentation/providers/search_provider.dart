import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'search_provider.freezed.dart';
part 'search_provider.g.dart';

enum SearchType { series, issues, characters, creators, storyArcs }

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default(SearchType.series) SearchType searchType,
    @Default([]) List<dynamic> results, // Can be issues, series etc.
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;
}

@riverpod
class SearchHistory extends _$SearchHistory {
  static const _boxName = 'search_history_box';

  @override
  List<String> build() {
    final hive = ref.read(hiveServiceProvider);
    try {
      final box = hive.getBox<String>(_boxName);
      return box.values.toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addQuery(String query) async {
    if (query.trim().isEmpty) return;
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<String>(_boxName);

    // Remove if already exists to move to top
    final existingKey = box.keys.firstWhere(
      (k) => box.get(k) == query,
      orElse: () => null,
    );
    if (existingKey != null) await box.delete(existingKey);

    await box.add(query);
    if (box.length > 20) await box.deleteAt(0); // Keep last 20

    state = box.values.toList().reversed.toList();
  }

  Future<void> removeQuery(String query) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<String>(_boxName);
    final key = box.keys.firstWhere(
      (k) => box.get(k) == query,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
      state = box.values.toList().reversed.toList();
    }
  }

  Future<void> clearHistory() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox<String>(_boxName);
    await box.clear();
    state = [];
  }
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() => const SearchState();

  void setSearchType(SearchType type) {
    state = state.copyWith(searchType: type);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: query, results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, errorMessage: null);
    ref.read(searchHistoryProvider.notifier).addQuery(query);

    try {
      final repository = ref.read(metronRepositoryProvider);
      List<dynamic> results = [];

      switch (state.searchType) {
        case SearchType.series:
          results = await repository.searchIssues(
            query,
          ); // For now mapping all to searchIssues
          break;
        case SearchType.issues:
          results = await repository.searchIssues(query);
          break;
        default:
          // Implement others when repo supports them
          results = [];
      }

      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
