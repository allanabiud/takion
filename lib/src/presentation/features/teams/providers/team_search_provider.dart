import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/domain/common/search_utils.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

part "team_search_provider.g.dart";

@riverpod
class TeamSearch extends _$TeamSearch {
  SearchArgs? _args;

  @override
  Future<TeamListPage> build(SearchArgs args) async {
    _args = args;
    final repository = ref.watch(metronRepositoryProvider);
    return performPaginatedSearch(
      ref: ref,
      args: args,
      emptyResult: const TeamListPage(results: [], count: 0, currentPage: 1),
      searchFetcher: repository.searchTeams,
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(metronRepositoryProvider);
    await performSearchRefresh(
      ref: ref,
      args: _args,
      searchRefreshFetcher: (query, page) =>
          repository.searchTeams(query, page: page, forceRefresh: true),
    );
  }
}