import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/core/errors/error_mapper.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/providers/providers.dart";

int? _defaultPageSize(Object? _) => null;

/// Generic paged entity list screen with sorting, pull-to-refresh, and bottom navigation.
class EntityPagedListScreen<T, TItem> extends ConsumerStatefulWidget {
  const EntityPagedListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.watchPage,
    required this.invalidatePage,
    required this.countOf,
    required this.resultsOf,
    required this.hasNextOf,
    required this.hasPreviousOf,
    this.pageSizeOf = _defaultPageSize,
    required this.sortContext,
    required this.sortLabel,
    required this.sortItems,
    required this.tileBuilder,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.errorMessage,
    this.unit = "item",
    this.pluralUnit,
    this.enableRefresh = true,
    this.emptyHeight,
    this.appBarActions,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final AsyncValue<T> Function(WidgetRef ref, int page) watchPage;
  final void Function(WidgetRef ref, int page) invalidatePage;
  final int Function(T page) countOf;
  final List<TItem> Function(T page) resultsOf;
  final bool Function(T page) hasNextOf;
  final bool Function(T page) hasPreviousOf;
  final int? Function(T page) pageSizeOf;
  final SortPreferenceContext sortContext;
  final String Function(ContentSortOption option) sortLabel;
  final List<TItem> Function(List<TItem> items, ContentSortOption option)
  sortItems;
  final Widget Function(
    BuildContext context,
    TItem item, {
    required bool isFirst,
    required bool isLast,
  })
  tileBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final String errorMessage;
  final String unit;
  final String? pluralUnit;
  final bool enableRefresh;
  final double? emptyHeight;
  final List<Widget>? appBarActions;
  final Future<void> Function(WidgetRef ref, int page)? onRefresh;

  @override
  ConsumerState<EntityPagedListScreen<T, TItem>> createState() =>
      _EntityPagedListScreenState<T, TItem>();
}

class _EntityPagedListScreenState<T, TItem>
    extends ConsumerState<EntityPagedListScreen<T, TItem>> {
  int _page = 1;
  T? _lastPage;
  int _totalPages = 1;
  final _overlapHandle = SliverOverlapAbsorberHandle();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlapHandle.dispose();
    super.dispose();
  }

  bool get _pageHasPrevious {
    final lastPage = _lastPage;
    return lastPage == null ? false : widget.hasPreviousOf(lastPage);
  }

  bool get _pageHasNext {
    final lastPage = _lastPage;
    return lastPage == null ? false : widget.hasNextOf(lastPage);
  }

  void _changePage(int newPage) {
    setState(() => _page = newPage);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sortPreferenceForContextProvider(widget.sortContext), (
      prev,
      next,
    ) {
      if (prev != null && prev != next) {
        _changePage(1);
      }
    });

    final sortOption = ref.watch(
      sortPreferenceForContextProvider(widget.sortContext),
    );
    final itemsAsync = widget.watchPage(ref, _page);
    final isLoading = itemsAsync.isLoading;

    if (itemsAsync.hasValue) {
      final page = itemsAsync.value;
      if (page != null) {
        _lastPage = page;
        final pageSize = widget.pageSizeOf(page) ?? metronDefaultPageSize;
        _totalPages = pageSize > 0
            ? (widget.countOf(page) / pageSize).ceil()
            : 1;
      }
    }

    final body = itemsAsync.when(
      loading: () {
        final lastPage = _lastPage;
        if (lastPage != null) {
          return _buildContent(lastPage, sortOption, isLoading: true);
        }
        return const AsyncStatePanel.loading();
      },
      error: (error, _) => AsyncStatePanel.fromFailure(
        failure: ErrorMapper.fromException(error),
        onRetry: () {
          if (widget.onRefresh != null) {
            widget.onRefresh!(ref, _page);
          } else {
            widget.invalidatePage(ref, _page);
          }
        },
      ),
      data: (page) => _buildContent(page, sortOption, isLoading: false),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (widget.subtitle.isNotEmpty)
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: widget.appBarActions,
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      floatingActionButton: ScrollToTopFab(controller: _scrollController),
      body: widget.enableRefresh
          ? RefreshIndicator(
              onRefresh: () async {
                if (widget.onRefresh != null) {
                  await widget.onRefresh!(ref, _page);
                } else {
                  widget.invalidatePage(ref, _page);
                }
              },
              child: body,
            )
          : body,
      bottomNavigationBar: _totalPages > 1
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !_pageHasPrevious
                        ? null
                        : () => _changePage(_page - 1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Page $_page of $_totalPages",
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
                        : () => _changePage(_page + 1),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildContent(
    T page,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final results = widget.sortItems(widget.resultsOf(page), sortOption);
    final count = widget.countOf(page);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverOverlapAbsorber(
          handle: _overlapHandle,
          sliver: PinnedListHeader(
            child: ListHeader(
              count: count,
              unit: widget.unit,
              pluralUnit: widget.pluralUnit,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              enabled: !isLoading,
              sortLabel: widget.sortLabel(sortOption),
              onSortTap: () => showSortBottomSheet(
                context,
                ref,
                widget.sortContext,
                widget.sortLabel,
              ),
            ),
          ),
        ),
        SliverOverlapInjector(handle: _overlapHandle),
        results.isEmpty && !isLoading
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: widget.emptyHeight != null
                    ? SizedBox(
                        height: widget.emptyHeight,
                        child: EmptyContentState(
                          icon: widget.emptyIcon,
                          message: widget.emptyMessage,
                        ),
                      )
                    : EmptyContentState(
                        icon: widget.emptyIcon,
                        message: widget.emptyMessage,
                      ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = results[index];
                  return Opacity(
                    opacity: isLoading ? 0.6 : 1.0,
                    child: widget.tileBuilder(
                      context,
                      item,
                      isFirst: index == 0,
                      isLast: index == results.length - 1,
                    ),
                  );
                }, childCount: results.length),
              ),
      ],
    );
  }
}
