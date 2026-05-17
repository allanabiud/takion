import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class IssueSearchArgs {
  const IssueSearchArgs({
    required this.query,
    required this.page,
  });

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

final issueSearchResultsProvider =
    FutureProvider.autoDispose.family<IssueSearchPage, IssueSearchArgs>((
      ref,
      args,
    ) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.searchIssues(args.query, page: args.page);
    });
