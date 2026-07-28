import 'package:flutter/material.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final hasPagination = totalPages > 1;
    final showInlineLoading = isLoading && itemCount > 0 && skeleton == null;

    final body = RefreshIndicator(
      onRefresh: onRefresh,
      child: (isLoading && skeleton != null)
          ? skeleton!
          : (itemCount == 0 && !isLoading)
          ? CustomScrollView(
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
                    child: EmptyContentState(
                      icon: emptyIcon,
                      message: emptyMessage,
                    ),
                  ),
                ),
              ],
            )
          : (isLoading && itemCount == 0)
          ? CustomScrollView(
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
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, header != null ? 0 : 12, 0, 12),
              itemCount: itemCount + (header != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (header != null && index == 0) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: header,
                      ),
                      if (showInlineLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  );
                }

                return itemBuilder(context, header != null ? index - 1 : index);
              },
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
}
