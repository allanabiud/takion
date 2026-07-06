import 'package:takion/src/domain/entities/team_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final teamSearchResultsProvider = createSearchProvider<TeamListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchTeams(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => TeamListPage(results: [], count: 0, currentPage: 1),
);
