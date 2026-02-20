import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'discover_provider.freezed.dart';
part 'discover_provider.g.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default([]) List<Issue> results,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;
}

@riverpod
class DiscoverSearch extends _$DiscoverSearch {
  @override
  SearchState build() => const SearchState();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(query: query, results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(metronRepositoryProvider);
      final results = await repository.searchIssues(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
