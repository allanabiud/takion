import 'package:takion/src/domain/entities/publisher_list.dart';
import 'package:takion/src/presentation/providers/search_utils.dart';

class PublisherListPage with SearchPageMixin {
  const PublisherListPage({
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
  final List<PublisherList> results;
  final int currentPage;
}
