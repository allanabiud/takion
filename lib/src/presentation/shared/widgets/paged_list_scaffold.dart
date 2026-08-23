import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/pinned_list_header.dart";
import "package:takion/src/presentation/shared/widgets/scroll_to_top_fab.dart";

class PagedListScaffold extends StatefulWidget {
  const PagedListScaffold({
    super.key,
    required this.onRefresh,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.header,
    this.isLoading = false,
    this.skeleton,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio = 0.72,
    this.bottomSpacing = 12,
  });

  final Future<void> Function() onRefresh;
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget? header;
  final bool isLoading;
  final Widget? skeleton;
  final int? gridCrossAxisCount;
  final double gridChildAspectRatio;
  final double bottomSpacing;

  @override
  State<PagedListScaffold> createState() => _PagedListScaffoldState();
}

class _PagedListScaffoldState extends State<PagedListScaffold> {
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

  void _changePage(VoidCallback action) {
    action();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPagination = widget.totalPages > 1;
    final showInlineLoading = widget.isLoading && widget.itemCount > 0;

    final body = RefreshIndicator(
      onRefresh: widget.onRefresh,
      child:
          (widget.isLoading && widget.itemCount == 0 && widget.skeleton != null)
          ? widget.skeleton!
          : (widget.itemCount == 0 && !widget.isLoading)
          ? _EmptyState(
              header: widget.header,
              emptyIcon: widget.emptyIcon,
              emptyMessage: widget.emptyMessage,
            )
          : (widget.isLoading && widget.itemCount == 0)
          ? _LoadingEmptyState(header: widget.header)
          : _buildScrollableContent(
              context,
              showInlineLoading: showInlineLoading,
            ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          body,
          if (showInlineLoading) ...[
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.02)),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ],
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
                        : () => _changePage(widget.onPrevious),
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
                        : () => _changePage(widget.onNext),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildScrollableContent(
    BuildContext context, {
    required bool showInlineLoading,
  }) {
    if (widget.gridCrossAxisCount != null) {
      final grid = SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridCrossAxisCount!,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: widget.gridChildAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            widget.itemBuilder,
            childCount: widget.itemCount,
          ),
        ),
      );

      if (widget.header != null) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            PinnedListHeader(child: widget.header!),
            grid,
            SliverToBoxAdapter(child: SizedBox(height: widget.bottomSpacing)),
          ],
        );
      }

      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          grid,
          SliverToBoxAdapter(child: SizedBox(height: widget.bottomSpacing)),
        ],
      );
    }

    if (widget.header != null) {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          PinnedListHeader(child: widget.header!),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              widget.itemBuilder,
              childCount: widget.itemCount,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    this.header,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  final Widget? header;
  final IconData emptyIcon;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (header != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: header,
            ),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EmptyContentState(icon: emptyIcon, message: emptyMessage),
          ),
        ),
      ],
    );
  }
}

class _LoadingEmptyState extends StatelessWidget {
  const _LoadingEmptyState({this.header});

  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (header != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: header,
            ),
          ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
