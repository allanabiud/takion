import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class IssueSearchArgs {
  const IssueSearchArgs({required this.query, required this.page});

  final String query;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IssueSearchArgs &&
        other.query == query &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}

final issueSearchResultsProvider = FutureProvider.autoDispose
    .family<IssueSearchPage, IssueSearchArgs>((ref, args) async {
      final repository = ref.watch(metronRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final results = await repository.searchIssues(
        args.query,
        page: args.page,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );
      if (results.previousPage != null) {
        unawaited(
          repository.searchIssues(
            args.query,
            page: results.previousPage!,
            limit: metronDefaultPageSize,
          ),
        );
      }
      if (results.nextPage != null) {
        unawaited(
          repository.searchIssues(
            args.query,
            page: results.nextPage!,
            limit: metronDefaultPageSize,
          ),
        );
      }
      return results;
    });
