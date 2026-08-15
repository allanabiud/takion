import "dart:async";
import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/durations.dart";
import "package:takion/src/core/constants/pagination.dart";

class SearchArgs {
  const SearchArgs({required this.query, required this.page});

  final String query;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchArgs && other.query == query && other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}

mixin SearchPageMixin {
  String? get next;
  String? get previous;

  int? get nextPage {
    if (next == null || next!.isEmpty) return null;
    final uri = Uri.tryParse(next!);
    if (uri == null) return null;
    return int.tryParse(uri.queryParameters["page"] ?? "");
  }

  int? get previousPage {
    if (previous == null || previous!.isEmpty) return null;
    final uri = Uri.tryParse(previous!);
    if (uri == null) return null;
    return int.tryParse(uri.queryParameters["page"] ?? "") ?? 1;
  }

  bool get hasNext => nextPage != null;
  bool get hasPrevious => previousPage != null;
}

typedef SearchFetcher<T> = Future<T> Function(
  String query, {
  required int page,
  required int limit,
  CancelToken? cancelToken,
});

Future<T> performPaginatedSearch<T extends SearchPageMixin>({
  required Ref ref,
  required SearchArgs args,
  required SearchFetcher<T> searchFetcher,
  required T emptyResult,
  Duration debounceDuration = AppDurations.searchDebounce,
  Duration keepAliveDuration = AppDurations.defaultKeepAlive,
  int pageSize = metronDefaultPageSize,
}) async {

  if (args.query.trim().isEmpty) return emptyResult;

  if (debounceDuration > Duration.zero) {
    await Future.delayed(debounceDuration);
  }

  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final results = await searchFetcher(
    args.query,
    page: args.page,
    limit: pageSize,
    cancelToken: cancelToken,
  );

  if (results.previousPage != null) {
    unawaited(
      searchFetcher(
        args.query,
        page: results.previousPage!,
        limit: pageSize,
      ),
    );
  }
  if (results.nextPage != null) {
    unawaited(
      searchFetcher(
        args.query,
        page: results.nextPage!,
        limit: pageSize,
      ),
    );
  }

  timer = Timer(keepAliveDuration, link.close);

  return results;
}

Future<void> performSearchRefresh({
  required Ref ref,
  required SearchArgs? args,
  required Future<void> Function(String query, int page) searchRefreshFetcher,
}) async {
  final query = args?.query;
  final page = args?.page ?? 1;
  if (query == null || query.trim().isEmpty) return;
  await searchRefreshFetcher(query, page);
  ref.invalidateSelf();
}


