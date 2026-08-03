import 'package:flutter/material.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/pinned_list_header.dart';

class PagedListScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasPagination = totalPages > 1;
    final showInlineLoading = isLoading && itemCount > 0 && skeleton == null;

    final body = RefreshIndicator(
      onRefresh: onRefresh,
      child: (isLoading && skeleton != null)
          ? skeleton!
          : (itemCount == 0 && !isLoading)
          ? _EmptyState(
              header: header,
              emptyIcon: emptyIcon,
              emptyMessage: emptyMessage,
            )
          : (isLoading && itemCount == 0)
          ? _LoadingEmptyState(header: header)
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
          if (showInlineLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.02)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: hasPagination
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !hasPrevious ? null : onPrevious,
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
                    onPressed: isLoading || !hasNext ? null : onNext,
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
    if (gridCrossAxisCount != null) {
      final grid = SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCrossAxisCount!,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: gridChildAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => itemBuilder(context, index),
            childCount: itemCount,
          ),
        ),
      );

      if (header != null) {
        return CustomScrollView(
          slivers: [
            PinnedListHeader(
              isLoading: showInlineLoading,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header!,
                  if (showInlineLoading)
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
            grid,
            SliverToBoxAdapter(child: SizedBox(height: bottomSpacing)),
          ],
        );
      }

      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          grid,
          SliverToBoxAdapter(child: SizedBox(height: bottomSpacing)),
        ],
      );
    }

    if (header != null) {
      return CustomScrollView(
        slivers: [
          PinnedListHeader(
            isLoading: showInlineLoading,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header!,
                if (showInlineLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(context, index),
              childCount: itemCount,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
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
