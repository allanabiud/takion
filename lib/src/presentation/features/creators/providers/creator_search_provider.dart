import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
