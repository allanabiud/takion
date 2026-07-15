import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
export 'package:takion/src/domain/search/search_utils.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
