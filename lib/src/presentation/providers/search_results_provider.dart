import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/search_provider.dart';

part 'search_results_provider.freezed.dart';
part 'search_results_provider.g.dart';

@freezed
abstract class SearchResultsState with _$SearchResultsState {
  const factory SearchResultsState({
    @Default('') String query,
    @Default(SearchType.series) SearchType searchType,
    @Default([]) List<dynamic> results,
    @Default(0) int totalCount,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchResultsState;
}

@Riverpod(keepAlive: true)
class SearchResultsNotifier extends _$SearchResultsNotifier {
  @override
  SearchResultsState build() => const SearchResultsState();

  Future<void> refresh() async {
    return initiateSearch(state.query, state.searchType, forceRefresh: true);
  }

  Future<void> initiateSearch(String query, SearchType type, {bool forceRefresh = false}) async {
    state = state.copyWith(
      query: query,
      searchType: type,
      isLoading: true,
      results: [],
      totalCount: 0,
      errorMessage: null,
    );

    try {
      final repository = ref.read(metronRepositoryProvider);
      List<dynamic> results = [];

      switch (type) {
        case SearchType.series:
          results = await repository.searchSeries(query, forceRefresh: forceRefresh);
          break;
        case SearchType.issues:
          results = await repository.searchIssues(query, forceRefresh: forceRefresh);
          break;
        default:
          results = [];
      }

      if (ref.mounted) {
        state = state.copyWith(
          results: results,
          totalCount: results.length,
          isLoading: false,
        );
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }
}
