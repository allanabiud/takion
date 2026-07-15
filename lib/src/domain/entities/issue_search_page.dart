import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/search/search_utils.dart';

class IssueSearchPage with SearchPageMixin {
  const IssueSearchPage({
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
  final List<IssueList> results;
  final int currentPage;
}
