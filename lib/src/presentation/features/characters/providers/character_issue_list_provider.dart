import "dart:async";
import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

class CharacterIssueListArgs {
  const CharacterIssueListArgs({
    required this.characterId,
    required this.page,
    this.limit = metronDefaultPageSize,
  });

  final int characterId;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterIssueListArgs &&
        other.characterId == characterId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(characterId, page, limit);
}

final characterIssueListProvider = FutureProvider.autoDispose
    .family<CharacterIssueListPage, CharacterIssueListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final sortOption = ref.watch(
        sortPreferenceForContextProvider(SortPreferenceContext.characterIssues),
      );

      final page1 = await repository.getCharacterIssueList(
        args.characterId,
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
          resultPage = await repository.getCharacterIssueList(
            args.characterId,
            page: targetPage,
            limit: args.limit,
            cancelToken: cancelToken,
          );
          if (resultPage.results.isEmpty && page1.count > 0) {
            AppLogger.warning(
              "CharacterIssueList: page $targetPage returned empty for "
              "character ${args.characterId} (count ${page1.count}). "
              "Falling back to page 1.",
            );
            resultPage = page1;
          }
        }
      } else {
        if (args.page == 1) {
          resultPage = page1;
        } else {
          resultPage = await repository.getCharacterIssueList(
            args.characterId,
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

final characterDetailsIssuesProvider = FutureProvider.autoDispose
    .family<CharacterIssueListPage, int>((ref, characterId) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);

      final page1 = await repository.getCharacterIssueList(
        characterId,
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

      final futures = <Future<CharacterIssueListPage>>[];

      if (totalPages > 1) {
        futures.add(
          repository
              .getCharacterIssueList(characterId, page: totalPages)
              .catchError((e) {
            AppLogger.debug("Failed to fetch character last page", error: e);
            return const CharacterIssueListPage(count: 0, results: [], currentPage: 1);
          }),
        );
      }

      if (totalPages > 2) {
        futures.add(
          repository
              .getCharacterIssueList(characterId, page: totalPages - 1)
              .catchError((e) {
            AppLogger.debug(
              "Failed to fetch character penultimate page",
              error: e,
            );
            return const CharacterIssueListPage(count: 0, results: [], currentPage: 1);
          }),
        );
      }

      if (futures.isNotEmpty) {
        final pages = await Future.wait(futures);
        for (final p in pages) {
          for (final issue in p.results) {
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
        realPageSize: page1.realPageSize,
      );
    });
