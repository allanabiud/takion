import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/characters/providers/character_details_provider.dart';
import 'package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';

@RoutePage()
class CharacterIssuesScreen extends ConsumerStatefulWidget {
  const CharacterIssuesScreen({super.key, @pathParam required this.characterId});

  final int characterId;

  @override
  ConsumerState<CharacterIssuesScreen> createState() =>
      _CharacterIssuesScreenState();
}

class _CharacterIssuesScreenState extends ConsumerState<CharacterIssuesScreen> {
  int _page = 1;
  CharacterIssueListPage? _lastPage;
  int _totalPages = 1;
  final _overlapHandle = SliverOverlapAbsorberHandle();

  @override
  void dispose() {
    _overlapHandle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.characterIssues),
    );
    final characterAsync = ref.watch(
      characterDetailsProvider(widget.characterId),
    );
    final characterName = characterAsync.asData?.value.name ?? '';
    final args = CharacterIssueListArgs(
      characterId: widget.characterId,
      page: _page,
    );
    final issuesAsync = ref.watch(characterIssueListProvider(args));
    final isLoading = issuesAsync.isLoading;

    if (issuesAsync.hasValue) {
      _lastPage = issuesAsync.value;
      _totalPages =
          ((issuesAsync.value!.count - 1) ~/ metronDefaultPageSize) + 1;
    }

    final body = issuesAsync.when(
      loading: () {
        if (_lastPage != null) {
          return _buildContent(context, ref, _lastPage!, sortOption,
              isLoading: true);
        }
        return const AsyncStatePanel.loading();
      },
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load issues: $error',
      ),
      data: (issuePage) =>
          _buildContent(context, ref, issuePage, sortOption, isLoading: false),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issues'),
            if (characterName.isNotEmpty)
              Text(
                characterName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: _totalPages > 1
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !_pageHasPrevious
                        ? null
                        : () => setState(() => _page--),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Page $_page of $_totalPages',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isLoading || !_pageHasNext
                        ? null
                        : () => setState(() => _page++),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  bool get _pageHasPrevious =>
      _lastPage?.hasPrevious ?? false;

  bool get _pageHasNext =>
      _lastPage?.hasNext ?? false;

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CharacterIssueListPage issuePage,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final sortedIssues = sortIssues(issuePage.results, sortOption);
    final issueCount = issuePage.count;

    return CustomScrollView(
      slivers: [
        SliverOverlapAbsorber(
          handle: _overlapHandle,
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              isLoading: isLoading,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListHeader(
                    count: issueCount,
                    unit: 'issue',
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                        ),
                        TextButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  showSortBottomSheet(
                                    context,
                                    ref,
                                    SortPreferenceContext.characterIssues,
                                    issueSortLabel,
                                  );
                                },
                          icon: const Icon(Icons.swap_vert),
                          label: Text(issueSortLabel(sortOption)),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverOverlapInjector(handle: _overlapHandle),
        sortedIssues.isEmpty && !isLoading
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyContentState(
                  icon: Icons.menu_book_outlined,
                  message: 'No issues available.',
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final issue = sortedIssues[index];
                    return Opacity(
                      opacity: isLoading ? 0.6 : 1.0,
                      child: IssueListTile(
                        issue: issue,
                        isFirst: index == 0,
                        isLast: index == sortedIssues.length - 1,
                      ),
                    );
                  },
                  childCount: sortedIssues.length,
                ),
              ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.child, this.isLoading = false});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Container(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      );

  @override
  double get maxExtent => isLoading ? 74.0 : 56.0;

  @override
  double get minExtent => isLoading ? 74.0 : 56.0;

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || isLoading != oldDelegate.isLoading;
}
