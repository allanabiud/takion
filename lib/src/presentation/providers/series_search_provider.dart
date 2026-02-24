import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_search_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class SeriesSearchArgs {
  const SeriesSearchArgs({
    required this.query,
    required this.page,
  });

  final String query;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesSearchArgs &&
        other.query == query &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}

final seriesSearchResultsProvider =
    FutureProvider.autoDispose.family<SeriesSearchPage, SeriesSearchArgs>((
      ref,
      args,
    ) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.searchSeries(args.query, page: args.page);
    });
