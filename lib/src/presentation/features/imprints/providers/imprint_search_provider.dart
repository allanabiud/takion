import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/imprint_list_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class ImprintSearchArgs {
  const ImprintSearchArgs({required this.query, required this.page});

  final String query;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImprintSearchArgs &&
        other.query == query &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(query, page);
}

final imprintSearchResultsProvider = FutureProvider.autoDispose
    .family<ImprintListPage, ImprintSearchArgs>((ref, args) async {
  if (args.query.trim().isEmpty) {
    return ImprintListPage(results: [], count: 0, currentPage: 1);
  }

  await Future.delayed(const Duration(milliseconds: 500));

  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());

  final repository = ref.watch(metronRepositoryProvider);
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  final results = await repository.searchImprints(
    args.query,
    page: args.page,
    limit: metronDefaultPageSize,
    cancelToken: cancelToken,
  );
  if (results.previousPage != null) {
    unawaited(
      repository.searchImprints(
        args.query,
        page: results.previousPage!,
        limit: metronDefaultPageSize,
      ),
    );
  }
  if (results.nextPage != null) {
    unawaited(
      repository.searchImprints(
        args.query,
        page: results.nextPage!,
        limit: metronDefaultPageSize,
      ),
    );
  }

  timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });

  return results;
});
