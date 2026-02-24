import 'package:takion/src/domain/entities/issue_list.dart';

class SeriesIssueListPage {
  const SeriesIssueListPage({
    required this.count,
    required this.results,
    required this.currentPage,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<IssueList> results;
  final int currentPage;

  int? _extractPage(String? url, {required bool defaultToFirstPage}) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final parsedPage = int.tryParse(uri.queryParameters['page'] ?? '');
    if (parsedPage != null) return parsedPage;
    return defaultToFirstPage ? 1 : null;
  }

  int? get nextPage => _extractPage(next, defaultToFirstPage: false);
  int? get previousPage => _extractPage(previous, defaultToFirstPage: true);
  bool get hasNext => nextPage != null;
  bool get hasPrevious => previousPage != null;
}
