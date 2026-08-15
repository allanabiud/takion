import "dart:async";
import "package:dio/dio.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/refresh_async.dart";

part "weekly_releases_provider.g.dart";

@riverpod
class WeeklyReleases extends _$WeeklyReleases {
  @override
  Future<List<IssueList>> build([DateTime? date]) async {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    final targetDate = date ?? DateTime.now();
    final repository = ref.watch(catalogRepositoryProvider);
    final result = await AppPerformanceMetrics.instance.trackProvider(
      "weeklyReleasesProvider",
      () => repository.getWeeklyReleasesForDate(
        targetDate,
        cancelToken: cancelToken,
      ),
    );

    timer = Timer(const Duration(minutes: 5), link.close);
    return result;
  }

  Future<void> refresh() async {
    final targetDate = date ?? DateTime.now();
    await refreshAsync<List<IssueList>>(
      setState: (value) => state = value,
      previousState: state,
      fetch: () async {
        final repository = ref.read(catalogRepositoryProvider);
        return repository.getWeeklyReleasesForDate(
          targetDate,
          forceRefresh: true,
          cancelToken: CancelToken(),
        );
      },
    );
  }
}

@riverpod
class FocReleases extends _$FocReleases {
  @override
  Future<List<IssueList>> build(DateTime date) async {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    final repository = ref.watch(catalogRepositoryProvider);
    final result = await repository.getFocReleasesForDate(
      date,
      cancelToken: cancelToken,
    );

    timer = Timer(const Duration(minutes: 5), link.close);
    return result;
  }

  Future<void> refresh() async {
    final date = this.date;
    await refreshAsync<List<IssueList>>(
      setState: (value) => state = value,
      previousState: state,
      fetch: () async {
        final repository = ref.read(catalogRepositoryProvider);
        return repository.getFocReleasesForDate(
          date,
          forceRefresh: true,
          cancelToken: CancelToken(),
        );
      },
    );
  }
}