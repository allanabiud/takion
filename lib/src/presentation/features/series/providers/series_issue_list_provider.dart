import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class SeriesIssueListArgs {
  const SeriesIssueListArgs({required this.seriesId, required this.page});

  final int seriesId;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesIssueListArgs &&
        other.seriesId == seriesId &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(seriesId, page);
}

final seriesIssueListProvider = FutureProvider.autoDispose
    .family<SeriesIssueListPage, SeriesIssueListArgs>((ref, args) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(metronRepositoryProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final result = await repository.getSeriesIssueList(
        args.seriesId,
        page: args.page,
        limit: metronDefaultPageSize,
        cancelToken: cancelToken,
      );

      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });
