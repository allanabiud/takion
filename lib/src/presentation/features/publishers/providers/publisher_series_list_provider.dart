import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class PublisherSeriesListArgs {
  const PublisherSeriesListArgs({
    required this.publisherId,
    required this.page,
  });

  final int publisherId;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PublisherSeriesListArgs &&
        other.publisherId == publisherId &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(publisherId, page);
}

final publisherSeriesListProvider = FutureProvider.autoDispose
    .family<SeriesListPage, int>((ref, publisherId) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final repository = ref.watch(metronRepositoryProvider);
      final results = await repository.getPublisherSeriesList(
        publisherId,
        page: 1,
        cancelToken: cancelToken,
      );

      timer = Timer(const Duration(minutes: 5), () {
        link.close();
      });

      return results;
    });

final publisherSeriesListPaginatedProvider = FutureProvider.autoDispose
    .family<SeriesListPage, PublisherSeriesListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);

      final repository = ref.watch(metronRepositoryProvider);
      final results = await repository.getPublisherSeriesList(
        args.publisherId,
        page: args.page,
        cancelToken: cancelToken,
      );

      timer = Timer(const Duration(minutes: 5), () {
        link.close();
      });

      return results;
    });
