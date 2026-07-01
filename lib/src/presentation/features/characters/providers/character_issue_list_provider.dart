import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/character_issue_list_page.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

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
      final result = await repository.getCharacterIssueList(
        args.characterId,
        page: args.page,
        limit: args.limit,
        cancelToken: cancelToken,
      );

      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });

final characterDetailsIssuesProvider = FutureProvider.autoDispose
    .family<CharacterIssueListPage, int>((ref, characterId) async {
  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  final page1 = await ref.watch(characterIssueListProvider(
    CharacterIssueListArgs(characterId: characterId, page: 1),
  ).future);

  final results = <IssueList>[...page1.results];

  Future<CharacterIssueListPage>? page2Future;
  if (page1.nextPage != null) {
    page2Future = ref.watch(characterIssueListProvider(
      CharacterIssueListArgs(characterId: characterId, page: page1.nextPage!),
    ).future);
  }

  final rawLastPage = page1.count > 0
      ? ((page1.count - 1) ~/ metronDefaultPageSize) + 1
      : 1;
  final knownMaxPage = page1.nextPage ?? 1;

  Future<CharacterIssueListPage>? lastPageFuture;
  if (rawLastPage > knownMaxPage) {
    lastPageFuture = ref.watch(characterIssueListProvider(
      CharacterIssueListArgs(characterId: characterId, page: rawLastPage),
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
  return CharacterIssueListPage(
    count: page1.count,
    results: results,
    currentPage: 1,
  );
});
