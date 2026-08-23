import "dart:async";
import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

class TeamIssueListArgs {
  const TeamIssueListArgs({
    required this.teamId,
    required this.page,
    this.limit = metronDefaultPageSize,
  });

  final int teamId;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamIssueListArgs &&
        other.teamId == teamId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(teamId, page, limit);
}

Future<CharacterIssueListPage> _fetchValidIssuePage(
  Future<CharacterIssueListPage> Function(int page) fetcher, {
  required int targetPage,
  required int fallbackPage,
  CharacterIssueListPage? fallbackPageData,
}) async {
  if (targetPage == fallbackPage) {
    if (fallbackPageData != null) return fallbackPageData;
    try {
      return await fetcher(fallbackPage);
    } catch (_) {
      return const CharacterIssueListPage(
        count: 0,
        results: [],
        currentPage: 1,
      );
    }
  }
  final minPage = (targetPage - metronMaxWalkPages + 1).clamp(1, targetPage);
  for (var p = targetPage; p >= minPage; p--) {
    if (p == fallbackPage && fallbackPageData != null) {
      if (fallbackPageData.results.isNotEmpty) return fallbackPageData;
    }
    try {
      final res = await fetcher(p);
      if (res.results.isNotEmpty) return res;
    } catch (e) {
      AppLogger.debug("fetchValidIssuePage: page $p failed", error: e);
    }
  }
  if (fallbackPageData != null) {
    return fallbackPageData;
  }
  try {
    return await fetcher(fallbackPage);
  } catch (_) {
    return const CharacterIssueListPage(count: 0, results: [], currentPage: 1);
  }
}

final teamIssueListProvider = FutureProvider.autoDispose
    .family<CharacterIssueListPage, TeamIssueListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final sortOption = ref.watch(
        sortPreferenceForContextProvider(SortPreferenceContext.teamIssues),
      );

      final page1 = await repository.getTeamIssueList(
        args.teamId,
        page: 1,
        limit: args.limit,
        cancelToken: cancelToken,
      );

      final pageSize = page1.realPageSize ?? args.limit;
      final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

      CharacterIssueListPage resultPage;
      if (sortOption == ContentSortOption.dateNewest && totalPages > 1) {
        var targetPage = totalPages - args.page + 1;
        targetPage = targetPage.clamp(1, totalPages);
        if (targetPage == 1) {
          resultPage = page1;
        } else {
          resultPage = await _fetchValidIssuePage(
            (p) => repository.getTeamIssueList(
              args.teamId,
              page: p,
              limit: args.limit,
              cancelToken: cancelToken,
            ),
            targetPage: targetPage,
            fallbackPage: 1,
            fallbackPageData: page1,
          );
        }
      } else {
        if (args.page == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getTeamIssueList(
            args.teamId,
            page: args.page,
            limit: args.limit,
            cancelToken: cancelToken,
          );
        }
      }

      final sortedResults = sortIssues(resultPage.results, sortOption);

      timer = Timer(const Duration(minutes: 5), link.close);

      return CharacterIssueListPage(
        count: page1.count,
        results: sortedResults,
        currentPage: args.page,
        realPageSize: page1.realPageSize,
        next: args.page < totalPages
            ? "placeholder?page=${args.page + 1}"
            : null,
        previous: args.page > 1 ? "placeholder?page=${args.page - 1}" : null,
      );
    });

final teamDetailsIssuesProvider = FutureProvider.autoDispose
    .family<CharacterIssueListPage, int>((ref, teamId) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);

      final page1 = await repository.getTeamIssueList(teamId, page: 1);

      final pageSize = page1.realPageSize ?? metronDefaultPageSize;
      final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

      final resultsMap = <int, IssueList>{};
      for (final issue in page1.results) {
        if (issue.id != null) {
          resultsMap[issue.id!] = issue;
        }
      }

      if (totalPages > 1) {
        final lastPage = await _fetchValidIssuePage(
          (p) => repository.getTeamIssueList(teamId, page: p),
          targetPage: totalPages,
          fallbackPage: 1,
          fallbackPageData: page1,
        );
        for (final issue in lastPage.results) {
          if (issue.id != null) {
            resultsMap[issue.id!] = issue;
          }
        }

        if (totalPages > 2) {
          final penultPage = await _fetchValidIssuePage(
            (p) => repository.getTeamIssueList(teamId, page: p),
            targetPage: totalPages - 1,
            fallbackPage: 1,
            fallbackPageData: page1,
          );
          for (final issue in penultPage.results) {
            if (issue.id != null) {
              resultsMap[issue.id!] = issue;
            }
          }
        }

        if (totalPages > 3) {
          final antepenultPage = await _fetchValidIssuePage(
            (p) => repository.getTeamIssueList(teamId, page: p),
            targetPage: totalPages - 2,
            fallbackPage: 1,
            fallbackPageData: page1,
          );
          for (final issue in antepenultPage.results) {
            if (issue.id != null) {
              resultsMap[issue.id!] = issue;
            }
          }
        }
      }

      timer = Timer(const Duration(minutes: 5), link.close);

      return CharacterIssueListPage(
        count: page1.count,
        results: resultsMap.values.toList(),
        currentPage: 1,
        realPageSize: pageSize,
      );
    });
