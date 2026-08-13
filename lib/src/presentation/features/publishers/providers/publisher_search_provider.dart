import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/common/search_utils.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

part 'publisher_search_provider.g.dart';

@riverpod
class PublisherSearch extends _$PublisherSearch {
  SearchArgs? _args;

  @override
  Future<PublisherListPage> build(SearchArgs args) async {
    _args = args;
    final repository = ref.watch(metronRepositoryProvider);
    return performPaginatedSearch(
      ref: ref,
      args: args,
      emptyResult:
          const PublisherListPage(results: [], count: 0, currentPage: 1),
      searchFetcher: (query, {required page, required limit, cancelToken}) =>
          repository.searchPublishers(
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
          repository.searchPublishers(query, page: page, forceRefresh: true),
    );
  }
}