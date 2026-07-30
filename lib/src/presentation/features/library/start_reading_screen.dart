import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/start_reading_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

@RoutePage()
class StartReadingScreen extends ConsumerWidget {
  const StartReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.startReading),
    );
    final suggestionsAsync = ref.watch(startReadingAllSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Start Reading')),
      body: suggestionsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load start reading',
        ),
        data: (items) {
          final sortedItems = sortItemsByNameAndDate(
            items,
            sortOption: sortOption,
            nameOf: (item) =>
                '${item.issue.series?.name ?? ''} #${item.issue.number}',
            dateOf: (item) => item.issue.storeDate ?? DateTime.now(),
          );

          if (sortedItems.isEmpty) {
            return const EmptyContentState(
              icon: Icons.menu_book_outlined,
              message: 'No start reading suggestions.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedListHeaderDelegate(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ListHeader(
                      count: sortedItems.length,
                      unit: 'suggestion',
                      sortLabel: issueSortLabel(sortOption),
                      onSortTap: () => showSortBottomSheet(
                        context,
                        ref,
                        SortPreferenceContext.startReading,
                        issueSortLabel,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = sortedItems[index];
                    return IssueListTile(
                      issue: item.issue,
                      isFirst: index == 0,
                      isLast: index == sortedItems.length - 1,
                    );
                  },
                  childCount: sortedItems.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PinnedListHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedListHeaderDelegate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: child);
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_PinnedListHeaderDelegate oldDelegate) =>
      child != oldDelegate.child;
}
