import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/features/discover/providers/discover_browse_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/components/browse_paged_list_screen.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';

@RoutePage()
class DiscoverBrowseIssuesScreen extends ConsumerStatefulWidget {
  const DiscoverBrowseIssuesScreen({super.key});

  @override
  ConsumerState<DiscoverBrowseIssuesScreen> createState() =>
      _DiscoverBrowseIssuesScreenState();
}

class _DiscoverBrowseIssuesScreenState
    extends ConsumerState<DiscoverBrowseIssuesScreen> {
  int _page = 1;
  int? _lastCount;

  DiscoverBrowseIssuesArgs get _args => DiscoverBrowseIssuesArgs(
    page: _page,
    order: DiscoverBrowseIssueOrder.standard,
  );

  Future<void> _refreshPage() async {
    ref.invalidate(discoverBrowseIssuesProvider(_args));
    await ref.read(discoverBrowseIssuesProvider(_args).future);
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.browseIssues),
    );
    final pageAsync = ref.watch(discoverBrowseIssuesProvider(_args));

    if (pageAsync.hasValue) {
      _lastCount = pageAsync.value?.count;
    }

    final browsePageAsync = pageAsync.whenData((pageData) {
      final hasPrevious = _page > 1;
      final hasNext = pageData.next != null;
      return BrowsePagedData<IssueList>(
        results: sortIssues(pageData.results, sortOption),
        count: pageData.count,
        currentPage: _page,
        hasPrevious: hasPrevious,
        hasNext: hasNext,
        previousPage: hasPrevious ? _page - 1 : null,
        nextPage: hasNext ? _page + 1 : null,
      );
    });

    final displayCount = pageAsync.value?.count ?? _lastCount;

    return BrowsePagedListScreen<IssueList>(
      title: 'Browse Issues',
      pageAsync: browsePageAsync,
      header: displayCount != null
          ? ListHeader(
              count: displayCount,
              unit: 'issue',
              pageCount: pageAsync.value?.results.length,
              enabled: !pageAsync.isLoading,
              sortLabel: issueSortLabel(sortOption),
              onSortTap: () => showSortBottomSheet(
                context,
                ref,
                SortPreferenceContext.browseIssues,
                issueSortLabel,
              ),
            )
          : null,
      onRefresh: _refreshPage,
      onPrevious: () {
        if (_page <= 1) return;
        setState(() {
          _page = _page - 1;
        });
      },
      onNext: () {
        setState(() {
          _page = _page + 1;
        });
      },
      itemBuilder: (context, item, index, total) => IssueListTile(
        issue: item,
        isFirst: index == 0,
        isLast: index == total - 1,
      ),
      emptyMessage: 'No issues available.',
      emptyIcon: Icons.menu_book_outlined,
      errorPrefix: 'Failed to load issues',
    );
  }
}
