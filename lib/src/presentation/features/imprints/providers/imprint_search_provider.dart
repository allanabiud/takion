import 'package:takion/src/domain/entities/imprint_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final imprintSearchResultsProvider = createSearchProvider<ImprintListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchImprints(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => ImprintListPage(results: [], count: 0, currentPage: 1),
);
