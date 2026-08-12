class SearchArgs {
  const SearchArgs({required this.query, required this.page});

  final String query;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchArgs && other.query == query && other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}

mixin SearchPageMixin {
  String? get next;
  String? get previous;

  int? get nextPage {
    if (next == null || next!.isEmpty) return null;
    final uri = Uri.tryParse(next!);
    if (uri == null) return null;
    return int.tryParse(uri.queryParameters['page'] ?? '');
  }

  int? get previousPage {
    if (previous == null || previous!.isEmpty) return null;
    final uri = Uri.tryParse(previous!);
    if (uri == null) return null;
    return int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
  }

  bool get hasNext => nextPage != null;
  bool get hasPrevious => previousPage != null;
}
