import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'issues_provider.g.dart';

@riverpod
class WeeklyReleasesNotifier extends _$WeeklyReleasesNotifier {
  @override
  Future<List<IssueList>> build([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final repository = ref.watch(metronRepositoryProvider);

    return repository.getWeeklyReleasesForDate(targetDate);
  }

  Future<void> refresh() async {
    final targetDate = date ?? DateTime.now();

    // ignore: invalid_use_of_internal_member
    state = AsyncLoading<List<IssueList>>().copyWithPrevious(state);

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
class IssueDetailsNotifier extends _$IssueDetailsNotifier {
  @override
  Future<IssueDetails> build(int issueId) async {
    final repository = ref.watch(metronRepositoryProvider);
    return repository.getIssueDetails(issueId);
  }

  Future<void> refresh() async {
    // ignore: invalid_use_of_internal_member
    state = AsyncLoading<IssueDetails>().copyWithPrevious(state);

    final newState = await AsyncValue.guard(() async {
      final repository = ref.read(metronRepositoryProvider);
      return repository.getIssueDetails(issueId, forceRefresh: true);
    });
    state = newState;
  }
}

@riverpod
Future<List<IssueList>> currentWeeklyReleases(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getWeeklyReleasesForDate(DateTime.now());
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
