import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'issue_details_provider.g.dart';

@riverpod
class IssueDetailsNotifier extends _$IssueDetailsNotifier {
  Future<void> _cacheIssueImage(IssueDetails details) async {
    final image = details.image?.trim();
    if (image == null || image.isEmpty) return;
    await ref.read(entityImageCacheProvider).set('issue', details.id, image);
    ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
  }

  @override
  Future<IssueDetails> build(int issueId) async {
    ref.keepAlive();
    final repository = ref.watch(catalogRepositoryProvider);
    final details = await AppPerformanceMetrics.instance.trackProvider(
      'issueDetailsProvider',
      () => repository.getIssueDetails(issueId),
    );
    await _cacheIssueImage(details);
    return details;
  }

  Future<void> refresh() async {
    // ignore: invalid_use_of_internal_member
    state = AsyncLoading<IssueDetails>().copyWithPrevious(state);

    final newState = await AsyncValue.guard(() async {
      final repository = ref.read(catalogRepositoryProvider);
      final details = await repository.getIssueDetails(
        issueId,
        forceRefresh: true,
      );
      await _cacheIssueImage(details);
      return details;
    });
    state = newState;
  }
}
