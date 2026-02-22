import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'issues_provider.g.dart';

@riverpod
class WeeklyReleasesNotifier extends _$WeeklyReleasesNotifier {
  @override
  Future<List<Issue>> build([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final repository = ref.watch(metronRepositoryProvider);

    // Note: MetronRemoteDataSourceImpl needs to be updated to accept a date
    // for getWeeklyReleases. For now, we'll keep using the provider with parameters.
    return repository.getWeeklyReleasesForDate(targetDate);
  }

  Future<void> refresh() async {
    final targetDate = date ?? DateTime.now();

    // Explicitly set to loading while preserving previous data
    // This ensures .isRefreshing becomes true
    state = AsyncValue<List<Issue>>.loading().copyWithPrevious(state);

    final newState = await AsyncValue.guard(() async {
      final repository = ref.read(metronRepositoryProvider);
      return repository.getWeeklyReleasesForDate(
        targetDate,
        forceRefresh: true,
      );
    });
    state = newState;
  }
}

@riverpod
Future<List<Issue>> currentWeeklyReleases(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getWeeklyReleases();
}

@riverpod
Future<List<Issue>> recentlyAddedIssues(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getRecentlyModifiedIssues(limit: 12);
}

@riverpod
class SelectedWeek extends _$SelectedWeek {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }

  void nextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void previousWeek() {
    state = state.subtract(const Duration(days: 7));
  }
}
