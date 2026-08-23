import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/domain/common/search_utils.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

part "creator_search_provider.g.dart";

@riverpod
class CreatorSearch extends _$CreatorSearch {
  SearchArgs? _args;

  @override
  Future<CreatorListPage> build(SearchArgs args) async {
    _args = args;
    final repository = ref.watch(metronRepositoryProvider);
    return performPaginatedSearch(
      ref: ref,
      args: args,
      emptyResult: const CreatorListPage(results: [], count: 0, currentPage: 1),
      searchFetcher: repository.searchCreators,
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(metronRepositoryProvider);
    await performSearchRefresh(
      ref: ref,
      args: _args,
      searchRefreshFetcher: (query, page) =>
          repository.searchCreators(query, page: page, forceRefresh: true),
    );
  }
}
