import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';

class PagedSearchSection<T> extends ConsumerWidget {
  const PagedSearchSection({
    super.key,
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.sortOption,
    required this.sortContext,
    required this.sortLabelFn,
    required this.onRefresh,
    required this.isFiltering,
    required this.isLoading,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemBuilder,
    this.onItemIndexed,
  });

  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final ContentSortOption sortOption;
  final SortPreferenceContext sortContext;
  final String Function(ContentSortOption) sortLabelFn;
  final Future<void> Function() onRefresh;
  final bool isFiltering;
  final bool isLoading;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget Function(
    BuildContext,
    int index,
    T item,
    bool isFirst,
    bool isLast,
  )
  itemBuilder;
  final void Function(int index, int total)? onItemIndexed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPagination = totalPages > 1;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: items.isEmpty && !isLoading
              ? RefreshIndicator(
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (!isFiltering)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedListHeaderDelegate(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: totalCount,
                                unit: 'result',
                                pageCount: items.length,
                                sortLabel: sortLabelFn(sortOption),
                                onSortTap: () => showSortBottomSheet(
                                  context,
                                  ref,
                                  sortContext,
                                  sortLabelFn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EmptyContentState(
                            icon: emptyIcon,
                            message: emptyMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    slivers: [
                      if (!isFiltering)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedListHeaderDelegate(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ListHeader(
                                count: totalCount,
                                unit: 'result',
                                pageCount: items.length,
                                sortLabel: sortLabelFn(sortOption),
                                onSortTap: isLoading
                                    ? null
                                    : () => showSortBottomSheet(
                                        context,
                                        ref,
                                        sortContext,
                                        sortLabelFn,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            onItemIndexed?.call(index, items.length);
                            return Opacity(
                              opacity: isLoading ? 0.6 : 1.0,
                              child: itemBuilder(
                                context,
                                index,
                                item,
                                index == 0,
                                index == items.length - 1,
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
      bottomNavigationBar: hasPagination
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !hasPrevious
                        ? null
                        : onPreviousPage,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Page $currentPage of $totalPages',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isLoading || !hasNext ? null : onNextPage,
                  ),
                ],
              ),
            )
          : null,
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
