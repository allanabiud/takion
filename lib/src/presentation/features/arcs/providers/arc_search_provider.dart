import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final arcSearchResultsProvider = createSearchProvider<ArcListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchArcs(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      ),
  emptyFactory: () => ArcListPage(results: [], count: 0, currentPage: 1),
);
