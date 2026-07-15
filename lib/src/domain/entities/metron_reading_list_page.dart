import 'package:takion/src/domain/entities/entities.dart';

class MetronReadingListPage {
  const MetronReadingListPage({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<MetronReadingList> results;

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
    final pageStr = uri.queryParameters['page'];
    if (pageStr == null || pageStr.isEmpty) {
      return 1;
    }
    return int.tryParse(pageStr);
  }

  bool get hasNext => nextPage != null;
  bool get hasPrevious => previousPage != null;
}
