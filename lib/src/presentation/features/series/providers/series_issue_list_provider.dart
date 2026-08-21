import "dart:async";
import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

part "series_issue_list_provider.g.dart";

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

@riverpod
class SeriesIssueList extends _$SeriesIssueList {
  @override
  Future<SeriesIssueListPage> build(SeriesIssueListArgs args) async {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());

    final repository = ref.watch(metronRepositoryProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );

    final page1 = await repository.getSeriesIssueList(
      args.seriesId,
      page: 1,
      limit: metronDefaultPageSize,
      cancelToken: cancelToken,
    );

    final pageSize = page1.realPageSize ?? metronDefaultPageSize;
    final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

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
        if (resultPage.results.isEmpty && page1.count > 0) {
          AppLogger.warning(
            "SeriesIssueList: page $targetPage returned empty for series "
            "${args.seriesId} (count ${page1.count}). Falling back to page 1.",
          );
          resultPage = page1;
        }
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

    final sortedResults = sortIssues(resultPage.results, sortOption);

    timer = Timer(const Duration(minutes: 5), link.close);

    return SeriesIssueListPage(
      count: page1.count,
      results: sortedResults,
      currentPage: args.page,
      realPageSize: page1.realPageSize,
      next: args.page < totalPages ? "placeholder?page=${args.page + 1}" : null,
      previous: args.page > 1 ? "placeholder?page=${args.page - 1}" : null,
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(metronRepositoryProvider);
    final sortOption = ref.read(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );

    final page1 = await repository.getSeriesIssueList(
      args.seriesId,
      page: 1,
      limit: metronDefaultPageSize,
      forceRefresh: true,
    );

    final pageSize = page1.realPageSize ?? metronDefaultPageSize;
    final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

    final backingPage = sortOption == ContentSortOption.dateNewest
        ? totalPages - args.page + 1
        : args.page;

    if (backingPage != 1) {
      await repository.getSeriesIssueList(
        args.seriesId,
        page: backingPage,
        limit: metronDefaultPageSize,
        forceRefresh: true,
      );
    }

    ref.invalidateSelf();
  }
}

final seriesDetailsIssuesProvider = FutureProvider.autoDispose
    .family<SeriesIssueListPage, int>((ref, seriesId) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(metronRepositoryProvider);

      final page1 = await repository.getSeriesIssueList(
        seriesId,
        page: 1,
      );

      final pageSize = page1.realPageSize ?? metronDefaultPageSize;
      final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

      final resultsMap = <int, IssueList>{};
      for (final issue in page1.results) {
        if (issue.id != null) {
          resultsMap[issue.id!] = issue;
        }
      }

      if (totalPages > 1) {
        try {
          var lastPage = await repository.getSeriesIssueList(
            seriesId,
            page: totalPages,
          );
          if (lastPage.results.isEmpty && totalPages > 1) {
            lastPage = await repository.getSeriesIssueList(
              seriesId,
              page: totalPages - 1,
            );
          }
          for (final issue in lastPage.results) {
            if (issue.id != null) {
              resultsMap[issue.id!] = issue;
            }
          }
        } catch (e) {
          AppLogger.debug("Failed to fetch series last page", error: e);
        }

        if (totalPages > 2) {
          try {
            final prevPage = await repository.getSeriesIssueList(
              seriesId,
              page: totalPages - 1,
            );
            for (final issue in prevPage.results) {
              if (issue.id != null) {
                resultsMap[issue.id!] = issue;
              }
            }
          } catch (e) {
            AppLogger.debug("Failed to fetch series penultimate page", error: e);
          }
        }
      }

      timer = Timer(const Duration(minutes: 5), link.close);

      return SeriesIssueListPage(
        count: page1.count,
        results: resultsMap.values.toList(),
        currentPage: 1,
        realPageSize: page1.realPageSize,
      );
    });
