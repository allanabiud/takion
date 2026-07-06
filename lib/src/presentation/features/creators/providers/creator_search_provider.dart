import 'package:takion/src/domain/entities/creator_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final creatorSearchResultsProvider = createSearchProvider<CreatorListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchCreators(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => CreatorListPage(results: [], count: 0, currentPage: 1),
);
