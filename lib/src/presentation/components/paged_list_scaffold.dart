import 'package:flutter/material.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/page_navigation_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final hasPagination = totalPages > 1;
    final showInlineLoading = isLoading && itemCount > 0;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: (itemCount == 0 && !isLoading)
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
                        padding: EdgeInsets.only(
                          bottom: hasPagination ? 96 : 12,
                        ),
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
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: hasPagination ? 96 : 12,
                        ),
                        child: const Center(
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
                  padding: EdgeInsets.fromLTRB(
                    0,
                    header != null ? 0 : 12,
                    0,
                    hasPagination ? 96 : 12,
                  ),
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

                    return itemBuilder(
                      context,
                      header != null ? index - 1 : index,
                    );
                  },
                ),
        ),
        if (showInlineLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.02)),
            ),
          ),
        if (hasPagination)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: PageNavigationBar(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  hasPrevious: hasPrevious,
                  hasNext: hasNext,
                  onPrevious: onPrevious,
                  onNext: onNext,
                  enabled: !isLoading,
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
