import "package:takion/src/domain/catalog/entities/entities.dart";

class CharacterIssueListPage {
  const CharacterIssueListPage({
    required this.count,
    required this.results,
    required this.currentPage,
    this.next,
    this.previous,
    this.realPageSize,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<IssueList> results;
  final int currentPage;

  /// The number of results Metron returns per page, when known (i.e. when the
  /// response indicated more than one page). Null when the single-page size is
  /// unknown or only one page exists.
  final int? realPageSize;

  int? _extractPage(String? url, {required bool defaultToFirstPage}) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final parsedPage = int.tryParse(uri.queryParameters["page"] ?? "");
    if (parsedPage != null) return parsedPage;
    return defaultToFirstPage ? 1 : null;
  }

  int? get nextPage => _extractPage(next, defaultToFirstPage: false);
  int? get previousPage => _extractPage(previous, defaultToFirstPage: true);
  bool get hasNext => nextPage != null;
  bool get hasPrevious => previousPage != null;
}
