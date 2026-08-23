import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";

class PagedSearchSection<T> extends ConsumerStatefulWidget {
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
  ConsumerState<PagedSearchSection<T>> createState() =>
      _PagedSearchSectionState<T>();
}

class _PagedSearchSectionState<T> extends ConsumerState<PagedSearchSection<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPagination = widget.totalPages > 1;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: widget.items.isEmpty && !widget.isLoading
              ? RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (!widget.isFiltering)
                        PinnedListHeader(
                          child: ListHeader(
                            count: widget.totalCount,
                            unit: "result",
                            pageCount: widget.items.length,
                            sortLabel: widget.sortLabelFn(widget.sortOption),
                            onSortTap: () => showSortBottomSheet(
                              context,
                              ref,
                              widget.sortContext,
                              widget.sortLabelFn,
                            ),
                          ),
                        ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EmptyContentState(
                            icon: widget.emptyIcon,
                            message: widget.emptyMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (!widget.isFiltering)
                        PinnedListHeader(
                          child: ListHeader(
                            count: widget.totalCount,
                            unit: "result",
                            pageCount: widget.items.length,
                            sortLabel: widget.sortLabelFn(widget.sortOption),
                            onSortTap: widget.isLoading
                                ? null
                                : () => showSortBottomSheet(
                                    context,
                                    ref,
                                    widget.sortContext,
                                    widget.sortLabelFn,
                                  ),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = widget.items[index];
                          widget.onItemIndexed?.call(
                            index,
                            widget.items.length,
                          );
                          return Opacity(
                            opacity: widget.isLoading ? 0.6 : 1.0,
                            child: widget.itemBuilder(
                              context,
                              index,
                              item,
                              index == 0,
                              index == widget.items.length - 1,
                            ),
                          );
                        }, childCount: widget.items.length),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );

    void changePage(VoidCallback? action) {
      action?.call();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          body,
          if (widget.isLoading && widget.items.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
      floatingActionButton: ScrollToTopFab(controller: _scrollController),
      bottomNavigationBar: hasPagination
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: widget.isLoading || !widget.hasPrevious
                        ? null
                        : () => changePage(widget.onPreviousPage),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Page ${widget.currentPage} of ${widget.totalPages}",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: widget.isLoading || !widget.hasNext
                        ? null
                        : () => changePage(widget.onNextPage),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
