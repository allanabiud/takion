import 'package:takion/src/domain/entities/universe_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final universeSearchResultsProvider = createSearchProvider<UniverseListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchUniverses(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => UniverseListPage(results: [], count: 0, currentPage: 1),
);
