import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/common/search_utils.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

part 'arc_search_provider.g.dart';

@riverpod
class ArcSearch extends _$ArcSearch {
  SearchArgs? _args;

  @override
  Future<ArcListPage> build(SearchArgs args) async {
    _args = args;
    if (args.query.trim().isEmpty) {
      return ArcListPage(results: [], count: 0, currentPage: 1);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());

    final repository = ref.watch(metronRepositoryProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    final results = await repository.searchArcs(
      args.query,
      page: args.page,
      limit: metronDefaultPageSize,
      cancelToken: cancelToken,
    );

    if (results.previousPage != null) {
      unawaited(
        repository.searchArcs(
          args.query,
          page: results.previousPage!,
          limit: metronDefaultPageSize,
        ),
      );
    }
    if (results.nextPage != null) {
      unawaited(
        repository.searchArcs(
          args.query,
          page: results.nextPage!,
          limit: metronDefaultPageSize,
        ),
      );
    }

    timer = Timer(const Duration(minutes: 5), () => link.close());

    return results;
  }

  Future<void> refresh() async {
    final query = _args?.query;
    final page = _args?.page ?? 1;
    if (query == null || query.trim().isEmpty) return;
    await ref.read(metronRepositoryProvider).searchArcs(
      query,
      page: page,
      forceRefresh: true,
    );
    ref.invalidateSelf();
  }
}