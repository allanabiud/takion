import "dart:async";
import "package:dio/dio.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/constants/pagination.dart";
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
    if (args.query.trim().isEmpty) {
      return const CreatorListPage(results: [], count: 0, currentPage: 1);
    }

    final localCatalog = ref.watch(localCatalogRepositoryProvider);
    final localStubs = await localCatalog.searchCreatorsLocally(
      args.query,
      limit: metronDefaultPageSize,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());

    final repository = ref.watch(metronRepositoryProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    try {
      final remotePage = await repository.searchCreators(
        args.query,
        page: args.page,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );

      timer = Timer(const Duration(minutes: 5), link.close);

      final seenIds = <int>{for (final item in remotePage.results) item.id};
      final mergedResults = [
        ...remotePage.results,
        for (final stub in localStubs)
          if (!seenIds.contains(stub.id)) stub,
      ];

      return CreatorListPage(
        count: remotePage.count > mergedResults.length
            ? remotePage.count
            : mergedResults.length,
        results: mergedResults,
        currentPage: args.page,
        next: remotePage.next,
        previous: remotePage.previous,
      );
    } catch (_) {
      if (localStubs.isNotEmpty) {
        return CreatorListPage(
          count: localStubs.length,
          results: localStubs,
          currentPage: args.page,
        );
      }
      rethrow;
    }
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
