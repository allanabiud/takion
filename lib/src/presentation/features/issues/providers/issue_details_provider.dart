import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'issue_details_provider.g.dart';

@riverpod
class IssueDetailsNotifier extends _$IssueDetailsNotifier {
  @override
  Future<IssueDetails> build(int issueId) async {
    ref.keepAlive();
    final repository = ref.watch(catalogRepositoryProvider);
    return AppPerformanceMetrics.instance.trackProvider(
      'issueDetailsProvider',
      () => repository.getIssueDetails(issueId),
    );
  }

  Future<void> refresh() async {
    // ignore: invalid_use_of_internal_member
    state = AsyncLoading<IssueDetails>().copyWithPrevious(state);

    final newState = await AsyncValue.guard(() async {
      final repository = ref.read(catalogRepositoryProvider);
      return repository.getIssueDetails(issueId, forceRefresh: true);
    });
    state = newState;
  }
}
