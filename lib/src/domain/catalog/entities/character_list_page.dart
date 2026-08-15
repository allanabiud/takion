import "package:takion/src/domain/catalog/entities/entities.dart";
import "package:takion/src/domain/common/search_utils.dart";

class CharacterListPage with SearchPageMixin {
  const CharacterListPage({
    required this.count,
    required this.results,
    required this.currentPage,
    this.next,
    this.previous,
  });

  final int count;
  @override
  final String? next;
  @override
  final String? previous;
  final List<CharacterList> results;
  final int currentPage;
}
