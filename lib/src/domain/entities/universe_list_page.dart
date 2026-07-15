import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/domain/search/search_utils.dart';

class UniverseListPage with SearchPageMixin {
  const UniverseListPage({
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
  final List<UniverseList> results;
  final int currentPage;
}
