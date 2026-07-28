import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final seriesSearchResultsProvider = createSearchProvider<SeriesSearchPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchSeries(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      ),
  emptyFactory: () =>
      const SeriesSearchPage(results: [], count: 0, currentPage: 1),
);
