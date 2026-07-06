import 'package:takion/src/domain/entities/character_list_page.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

final characterSearchResultsProvider = createSearchProvider<CharacterListPage>(
  (repository, query, {required page, required limit, cancelToken}) =>
      repository.searchCharacters(
    query,
    page: page,
    limit: limit,
    cancelToken: cancelToken,
  ),
  emptyFactory: () => CharacterListPage(results: [], count: 0, currentPage: 1),
);
