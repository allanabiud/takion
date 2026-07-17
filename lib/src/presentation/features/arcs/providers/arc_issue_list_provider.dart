import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class ArcIssueListArgs {
  const ArcIssueListArgs({
    required this.arcId,
    required this.page,
    this.limit = metronDefaultPageSize,
  });

  final int arcId;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArcIssueListArgs &&
        other.arcId == arcId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(arcId, page, limit);
}

final arcIssueListProvider = FutureProvider.autoDispose
    .family<ArcIssueListPage, ArcIssueListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final sortOption = ref.watch(
        sortPreferenceForContextProvider(SortPreferenceContext.arcIssues),
      );

      final page1 = await repository.getArcIssueList(
        args.arcId,
        page: 1,
        limit: args.limit,
        cancelToken: cancelToken,
      );

      final totalPages = ((page1.count - 1) ~/ args.limit) + 1;

      ArcIssueListPage resultPage;
      if (sortOption == ContentSortOption.dateNewest && totalPages > 1) {
        final targetPage = totalPages - args.page + 1;
        if (targetPage == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getArcIssueList(
            args.arcId,
            page: targetPage,
            limit: args.limit,
            cancelToken: cancelToken,
          );
        }
      } else {
        if (args.page == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getArcIssueList(
            args.arcId,
            page: args.page,
            limit: args.limit,
            cancelToken: cancelToken,
          );
        }
      }

      timer = Timer(const Duration(minutes: 5), () => link.close());

      return ArcIssueListPage(
        count: page1.count,
        results: resultPage.results,
        currentPage: args.page,
        next: args.page < totalPages ? 'placeholder?page=${args.page + 1}' : null,
        previous: args.page > 1 ? 'placeholder?page=${args.page - 1}' : null,
      );
    });

final arcDetailsIssuesProvider = FutureProvider.autoDispose
    .family<ArcIssueListPage, int>((ref, arcId) async {
  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  final page1 = await ref.watch(arcIssueListProvider(
    ArcIssueListArgs(arcId: arcId, page: 1),
  ).future);

  final results = <IssueList>[...page1.results];

  Future<ArcIssueListPage>? page2Future;
  if (page1.nextPage != null) {
    page2Future = ref.watch(arcIssueListProvider(
      ArcIssueListArgs(arcId: arcId, page: page1.nextPage!),
    ).future);
  }

  final rawLastPage = page1.count > 0
      ? ((page1.count - 1) ~/ metronDefaultPageSize) + 1
      : 1;
  final knownMaxPage = page1.nextPage ?? 1;

  Future<ArcIssueListPage>? lastPageFuture;
  if (rawLastPage > knownMaxPage) {
    lastPageFuture = ref.watch(arcIssueListProvider(
      ArcIssueListArgs(arcId: arcId, page: rawLastPage),
    ).future);
  }

  final futures = <Future<List<IssueList>>>[];
  if (page2Future != null) {
    futures.add(page2Future.then((p) => p.results).catchError((e) {
      AppLogger.debug('Failed to fetch arc page 2, falling back to empty', error: e);
      return <IssueList>[];
    }));
  }
  if (lastPageFuture != null) {
    futures.add(lastPageFuture.then((p) => p.results).catchError((e) {
      AppLogger.debug('Failed to fetch arc last page, falling back to empty', error: e);
      return <IssueList>[];
    }));
  }

  if (futures.isNotEmpty) {
    final allResults = await Future.wait(futures);
    for (final list in allResults) {
      results.addAll(list);
    }
  }

  timer = Timer(const Duration(minutes: 5), () => link.close());
  return ArcIssueListPage(
    count: page1.count,
    results: results,
    currentPage: 1,
  );
});
