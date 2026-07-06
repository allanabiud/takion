import 'package:takion/src/domain/entities/publisher_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final publisherSearchResultsProvider = createSearchProvider<PublisherListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchPublishers(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => PublisherListPage(results: [], count: 0, currentPage: 1),
);
