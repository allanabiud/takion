import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_search_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

enum DiscoverBrowseIssueOrder { standard, recentlyAdded }

const _discoverBrowsePageLimit = 50;
const _recentlyAddedWindow = Duration(days: 7);

final recentlyAddedCutoffProvider = Provider<DateTime>((ref) {
  final nowUtc = DateTime.now().toUtc();
  final startOfTodayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
  return startOfTodayUtc.subtract(_recentlyAddedWindow);
});

class DiscoverBrowseIssuesArgs {
  const DiscoverBrowseIssuesArgs({required this.page, required this.order});

  final int page;
  final DiscoverBrowseIssueOrder order;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoverBrowseIssuesArgs &&
        other.page == page &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(page, order);
}

final discoverBrowseIssuesProvider = FutureProvider.autoDispose
    .family<IssueSearchPage, DiscoverBrowseIssuesArgs>((ref, args) {
      final repository = ref.watch(metronRepositoryProvider);
      final isRecentlyAdded =
          args.order == DiscoverBrowseIssueOrder.recentlyAdded;
      final recentlyAddedCutoff = ref.watch(recentlyAddedCutoffProvider);
      return repository.getIssueList(
        page: args.page,
        ordering: isRecentlyAdded ? '-modified' : null,
        modifiedGt: isRecentlyAdded ? recentlyAddedCutoff : null,
        limit: _discoverBrowsePageLimit,
      );
    });
