import 'package:takion/src/domain/entities/creator_list.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

class CreatorListPage with SearchPageMixin {
  const CreatorListPage({
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
  final List<CreatorList> results;
  final int currentPage;
}
