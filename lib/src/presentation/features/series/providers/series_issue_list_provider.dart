import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class SeriesIssueListArgs {
  const SeriesIssueListArgs({required this.seriesId, required this.page});

  final int seriesId;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesIssueListArgs &&
        other.seriesId == seriesId &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(seriesId, page);
}

final seriesIssueListProvider = FutureProvider.autoDispose
    .family<SeriesIssueListPage, SeriesIssueListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(metronRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final sortOption = ref.watch(
        sortPreferenceForContextProvider(SortPreferenceContext.seriesDetailsIssues),
      );

      final page1 = await repository.getSeriesIssueList(
        args.seriesId,
        page: 1,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );

      final totalPages = ((page1.count - 1) ~/ metronDefaultPageSize) + 1;

      SeriesIssueListPage resultPage;
      if (sortOption == ContentSortOption.dateNewest && totalPages > 1) {
        final targetPage = totalPages - args.page + 1;
        if (targetPage == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getSeriesIssueList(
            args.seriesId,
            page: targetPage,
            limit: metronDefaultPageSize,
            cancelToken: cancelToken,
          );
        }
      } else {
        if (args.page == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getSeriesIssueList(
            args.seriesId,
            page: args.page,
            limit: metronDefaultPageSize,
            cancelToken: cancelToken,
          );
        }
      }

      timer = Timer(const Duration(minutes: 5), () => link.close());

      return SeriesIssueListPage(
        count: page1.count,
        results: resultPage.results,
        currentPage: args.page,
        next: args.page < totalPages ? 'placeholder?page=${args.page + 1}' : null,
        previous: args.page > 1 ? 'placeholder?page=${args.page - 1}' : null,
      );
    });

final seriesDetailsIssuesProvider = FutureProvider.autoDispose
    .family<SeriesIssueListPage, int>((ref, seriesId) async {
  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  final page1 = await ref.watch(seriesIssueListProvider(
    SeriesIssueListArgs(seriesId: seriesId, page: 1),
  ).future);

  final results = <IssueList>[...page1.results];

  Future<SeriesIssueListPage>? page2Future;
  if (page1.nextPage != null) {
    page2Future = ref.watch(seriesIssueListProvider(
      SeriesIssueListArgs(seriesId: seriesId, page: page1.nextPage!),
    ).future);
  }

  final rawLastPage = page1.count > 0
      ? ((page1.count - 1) ~/ metronDefaultPageSize) + 1
      : 1;
  final knownMaxPage = page1.nextPage ?? 1;

  Future<SeriesIssueListPage>? lastPageFuture;
  if (rawLastPage > knownMaxPage) {
    lastPageFuture = ref.watch(seriesIssueListProvider(
      SeriesIssueListArgs(seriesId: seriesId, page: rawLastPage),
    ).future);
  }

  final futures = <Future<List<IssueList>>>[];
  if (page2Future != null) {
    futures.add(page2Future.then((p) => p.results).catchError((_) => <IssueList>[]));
  }
  if (lastPageFuture != null) {
    futures.add(lastPageFuture.then((p) => p.results).catchError((_) => <IssueList>[]));
  }

  if (futures.isNotEmpty) {
    final allResults = await Future.wait(futures);
    for (final list in allResults) {
      results.addAll(list);
    }
  }

  timer = Timer(const Duration(minutes: 5), () => link.close());
  return SeriesIssueListPage(
    count: page1.count,
    results: results,
    currentPage: 1,
  );
});
