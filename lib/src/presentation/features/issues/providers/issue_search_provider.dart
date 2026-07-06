import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

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
