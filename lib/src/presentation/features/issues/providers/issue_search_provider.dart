import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final issueSearchResultsProvider = createSearchProvider<IssueSearchPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchIssues(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => const IssueSearchPage(results: [], count: 0, currentPage: 1),
);
