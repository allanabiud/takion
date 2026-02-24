import 'package:flutter/material.dart';
import 'package:takion/src/presentation/widgets/page_navigation_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final hasPagination = totalPages > 1;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: itemCount == 0
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: hasPagination ? 96 : 12),
                  children: [
                    const SizedBox(height: 220),
                    Center(child: Text(emptyMessage)),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(0, 12, 0, hasPagination ? 96 : 12),
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
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
                ),
              ),
            ),
          ),
      ],
    );
  }
}