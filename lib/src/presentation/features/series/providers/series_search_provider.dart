import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final seriesSearchResultsProvider = createSearchProvider<SeriesSearchPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchSeries(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => const SeriesSearchPage(results: [], count: 0, currentPage: 1),
);
