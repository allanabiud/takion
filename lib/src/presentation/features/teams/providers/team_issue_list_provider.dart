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
        final targetPage = totalPages - args.page + 1;
        if (targetPage == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getTeamIssueList(
            args.teamId,
            page: targetPage,
            limit: args.limit,
            cancelToken: cancelToken,
          );
          if (resultPage.results.isEmpty && page1.count > 0) {
            AppLogger.warning(
              "TeamIssueList: page $targetPage returned empty for team "
              "${args.teamId} (count ${page1.count}). Falling back to page 1.",
            );
            resultPage = page1;
          }
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

      timer = Timer(const Duration(minutes: 5), link.close);

      return CharacterIssueListPage(
        count: page1.count,
        results: resultPage.results,
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

      final page1 = await ref.watch(
        teamIssueListProvider(
          TeamIssueListArgs(teamId: teamId, page: 1),
        ).future,
      );

      final pageSize = page1.realPageSize ?? metronDefaultPageSize;
      final totalPages = pageSize > 0 ? (page1.count / pageSize).ceil() : 1;

      final results = <IssueList>[...page1.results];

      Future<CharacterIssueListPage>? page2Future;
      if (page1.nextPage != null && page1.nextPage! <= totalPages) {
        page2Future = ref.watch(
          teamIssueListProvider(
            TeamIssueListArgs(teamId: teamId, page: page1.nextPage!),
          ).future,
        );
      }

      final rawLastPage = totalPages;
      final knownMaxPage = page1.nextPage ?? 1;

      Future<CharacterIssueListPage>? lastPageFuture;
      if (rawLastPage > knownMaxPage) {
        lastPageFuture = ref.watch(
          teamIssueListProvider(
            TeamIssueListArgs(teamId: teamId, page: rawLastPage),
          ).future,
        );
      }

      final futures = <Future<List<IssueList>>>[];
      if (page2Future != null) {
        futures.add(
          page2Future.then((p) => p.results).catchError((e) {
            AppLogger.debug(
              "Failed to fetch team page 2, falling back to empty",
              error: e,
            );
            return <IssueList>[];
          }),
        );
      }
      if (lastPageFuture != null) {
        futures.add(
          lastPageFuture.then((p) => p.results).catchError((e) {
            AppLogger.debug(
              "Failed to fetch team last page, falling back to empty",
              error: e,
            );
            return <IssueList>[];
          }),
        );
      }

      if (futures.isNotEmpty) {
        final allResults = await Future.wait(futures);
        for (final list in allResults) {
          results.addAll(list);
        }
      }

      timer = Timer(const Duration(minutes: 5), link.close);
      return CharacterIssueListPage(
        count: page1.count,
        results: results,
        currentPage: 1,
        realPageSize: page1.realPageSize,
      );
    });
