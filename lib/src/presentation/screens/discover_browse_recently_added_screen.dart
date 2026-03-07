import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/discover_browse_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/browse_paged_list_screen.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

@RoutePage()
class DiscoverBrowseRecentlyAddedScreen extends ConsumerStatefulWidget {
  const DiscoverBrowseRecentlyAddedScreen({super.key});

  @override
  ConsumerState<DiscoverBrowseRecentlyAddedScreen> createState() =>
      _DiscoverBrowseRecentlyAddedScreenState();
}

class _DiscoverBrowseRecentlyAddedScreenState
    extends ConsumerState<DiscoverBrowseRecentlyAddedScreen> {
  int _page = 1;

  DiscoverBrowseIssuesArgs get _args => DiscoverBrowseIssuesArgs(
    page: _page,
    order: DiscoverBrowseIssueOrder.recentlyAdded,
  );

  Future<void> _refreshPage() async {
    ref.invalidate(discoverBrowseIssuesProvider(_args));
    await ref.read(discoverBrowseIssuesProvider(_args).future);
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.browseRecentlyAdded,
      ),
    );
    final pageAsync = ref.watch(discoverBrowseIssuesProvider(_args));
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

    return BrowsePagedListScreen<IssueList>(
      title: 'Recently Added',
      pageAsync: browsePageAsync,
      appBarActions: [
        DisplaySettingsButton(
          selectedOption: sortOption,
          optionLabel: issueSortLabel,
          onSelected: (option) {
            ref
                .read(sortPreferencesProvider.notifier)
                .setPreference(
                  SortPreferenceContext.browseRecentlyAdded,
                  option,
                );
          },
        ),
      ],
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
      emptyMessage: 'No recently added issues available.',
      emptyIcon: Icons.schedule_outlined,
      errorPrefix: 'Failed to load recently added issues',
    );
  }
}
