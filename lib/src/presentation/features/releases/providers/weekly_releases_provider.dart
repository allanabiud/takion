import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

part 'weekly_releases_provider.g.dart';

@riverpod
class WeeklyReleasesNotifier extends _$WeeklyReleasesNotifier {
  @override
  Future<List<IssueList>> build([DateTime? date]) async {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() => timer?.cancel());

    final targetDate = date ?? DateTime.now();
    final repository = ref.watch(catalogRepositoryProvider);
    final result = await AppPerformanceMetrics.instance.trackProvider(
      'weeklyReleasesProvider',
      () => repository.getWeeklyReleasesForDate(targetDate),
    );

    timer = Timer(const Duration(minutes: 5), () => link.close());
    return result;
  }

  Future<void> refresh() async {
    final targetDate = date ?? DateTime.now();

    // ignore: invalid_use_of_internal_member
    state = AsyncLoading<List<IssueList>>().copyWithPrevious(state);

    final newState = await AsyncValue.guard(() async {
      final repository = ref.read(catalogRepositoryProvider);
      return repository.getWeeklyReleasesForDate(
        targetDate,
        forceRefresh: true,
      );
    });
    state = newState;
  }
}

final focReleasesProvider = FutureProvider.autoDispose
    .family<List<IssueList>, DateTime>((ref, date) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final repository = ref.watch(catalogRepositoryProvider);
      final result = await repository.getFocReleasesForDate(date);

      timer = Timer(const Duration(minutes: 5), () => link.close());
      return result;
    });
