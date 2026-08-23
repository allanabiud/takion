import "dart:async";
import "package:dio/dio.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/common/search_utils.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

part "series_search_provider.g.dart";

@riverpod
class SeriesSearch extends _$SeriesSearch {
  SearchArgs? _args;

  @override
  Future<SeriesSearchPage> build(SearchArgs args) async {
    _args = args;
    if (args.query.trim().isEmpty) {
      return const SeriesSearchPage(results: [], count: 0, currentPage: 1);
    }

    // 1. Instant local search from LocalCatalogRepository
    final localCatalog = ref.watch(localCatalogRepositoryProvider);
    final localStubs = await localCatalog.searchSeriesLocally(
      args.query,
      limit: metronDefaultPageSize,
    );

    // Small debounce for remote API call
    await Future.delayed(const Duration(milliseconds: 300));

    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());

    final repository = ref.watch(metronRepositoryProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    try {
      final remotePage = await repository.searchSeries(
        args.query,
        page: args.page,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );

      if (remotePage.previousPage != null) {
        unawaited(
          repository.searchSeries(
            args.query,
            page: remotePage.previousPage!,
            limit: metronDefaultPageSize,
          ),
        );
      }
      if (remotePage.nextPage != null) {
        unawaited(
          repository.searchSeries(
            args.query,
            page: remotePage.nextPage!,
            limit: metronDefaultPageSize,
          ),
        );
      }

      timer = Timer(const Duration(minutes: 5), link.close);

      // Merge local stubs and remote results without duplicates
      final seenIds = <int>{for (final item in remotePage.results) item.id};
      final mergedResults = [
        ...remotePage.results,
        for (final stub in localStubs)
          if (!seenIds.contains(stub.id)) stub,
      ];

      return SeriesSearchPage(
        count: remotePage.count > mergedResults.length
            ? remotePage.count
            : mergedResults.length,
        results: mergedResults,
        currentPage: args.page,
        next: remotePage.next,
        previous: remotePage.previous,
      );
    } catch (_) {
      // If remote fails or is offline, return local results
      if (localStubs.isNotEmpty) {
        return SeriesSearchPage(
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
          repository.searchSeries(query, page: page, forceRefresh: true),
    );
  }
}
