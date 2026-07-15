import 'package:takion/src/domain/entities/arc_list.dart';
import 'package:takion/src/domain/search/search_utils.dart';

class ArcListPage with SearchPageMixin {
  const ArcListPage({
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
  final List<ArcList> results;
  final int currentPage;
}
