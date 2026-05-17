import 'dart:async';
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
    ) async {
      if (args.query.trim().isEmpty) {
        return const SeriesSearchPage(results: [], count: 0, currentPage: 1);
      }

      // Debounce: Wait for 500ms before actually hitting the API
      // If the query changes during this time, this execution will be cancelled
      // by Riverpod automatically (because this is an autoDispose provider).
      await Future.delayed(const Duration(milliseconds: 500));

      // Keep the provider alive for a bit after success to cache results
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(metronRepositoryProvider);
      final results = await repository.searchSeries(args.query, page: args.page);

      // Cache for 5 minutes
      timer = Timer(const Duration(minutes: 5), () {
        link.close();
      });

      return results;
    });
