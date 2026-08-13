import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/common/search_utils.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

part 'imprint_search_provider.g.dart';

@riverpod
class ImprintSearch extends _$ImprintSearch {
  SearchArgs? _args;

  @override
  Future<ImprintListPage> build(SearchArgs args) async {
    _args = args;
    final repository = ref.watch(metronRepositoryProvider);
    return performPaginatedSearch(
      ref: ref,
      args: args,
      emptyResult: const ImprintListPage(results: [], count: 0, currentPage: 1),
      searchFetcher: (query, {required page, required limit, cancelToken}) =>
          repository.searchImprints(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(metronRepositoryProvider);
    await performSearchRefresh(
      ref: ref,
      args: _args,
      searchRefreshFetcher: (query, page) =>
          repository.searchImprints(query, page: page, forceRefresh: true),
    );
  }
}