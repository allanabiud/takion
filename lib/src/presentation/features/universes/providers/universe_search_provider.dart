import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
