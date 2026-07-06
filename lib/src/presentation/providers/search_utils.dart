import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';


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

typedef SearchApiCall<TPage> = Future<TPage> Function(
  MetronRepository repository,
  String query, {
  required int page,
  required int limit,
  CancelToken? cancelToken,
});

dynamic createSearchProvider<TPage>(
  SearchApiCall<TPage> searchApi, {
  required TPage Function() emptyFactory,
  bool preFetchNeighbors = true,
}) {
  return FutureProvider.autoDispose.family<TPage, SearchArgs>(
    (ref, args) async {
      if (args.query.trim().isEmpty) {
        return emptyFactory();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(metronRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final results = await searchApi(
        repository,
        args.query,
        page: args.page,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );

      if (preFetchNeighbors && results is SearchPageMixin) {
        final mixin = results as SearchPageMixin;
        if (mixin.previousPage != null) {
          unawaited(
            searchApi(
              repository,
              args.query,
              page: mixin.previousPage!,
              limit: metronDefaultPageSize,
            ),
          );
        }
        if (mixin.nextPage != null) {
          unawaited(
            searchApi(
              repository,
              args.query,
              page: mixin.nextPage!,
              limit: metronDefaultPageSize,
            ),
          );
        }
      }

      timer = Timer(const Duration(minutes: 5), () {
        link.close();
      });

      return results;
    },
  );
}
