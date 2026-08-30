import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class BrowsePagedData<T> {
  const BrowsePagedData({
    required this.results,
    required this.count,
    required this.currentPage,
    required this.hasPrevious,
    required this.hasNext,
    required this.previousPage,
    required this.nextPage,
  });

  final List<T> results;
  final int count;
  final int currentPage;
  final bool hasPrevious;
  final bool hasNext;
  final int? previousPage;
  final int? nextPage;
}

class BrowsePagedListScreen<T> extends StatefulWidget {
  const BrowsePagedListScreen({
    super.key,
    required this.title,
    required this.pageAsync,
    required this.onRefresh,
    required this.onPrevious,
    required this.onNext,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.errorPrefix,
    this.appBarActions,
    this.header,
  });

  final String title;
  final AsyncValue<BrowsePagedData<T>> pageAsync;
  final Future<void> Function() onRefresh;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Widget Function(BuildContext context, T item, int index, int total)
  itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final String errorPrefix;
  final List<Widget>? appBarActions;
  final Widget? header;

  @override
  State<BrowsePagedListScreen<T>> createState() =>
      _BrowsePagedListScreenState<T>();
}

class _BrowsePagedListScreenState<T> extends State<BrowsePagedListScreen<T>> {
  BrowsePagedData<T>? _lastData;

  @override
  void didUpdateWidget(covariant BrowsePagedListScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageAsync.hasValue) {
      _lastData = widget.pageAsync.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageAsync = widget.pageAsync;
    final data = pageAsync.value ?? _lastData;

    final childContent = pageAsync.when(
      loading: () {
        if (data != null) {
          return _buildScaffold(data, isLoading: true);
        }
        return _buildSkeletonList();
      },
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: widget.errorPrefix),
      data: (pageData) {
        return _buildScaffold(pageData, isLoading: false);
      },
    );

    final showInlineLoading = pageAsync.isLoading && data != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: widget.appBarActions,
        bottom: showInlineLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: widget.header != null
          ? Column(
              children: [
                widget.header!,
                Expanded(child: childContent),
              ],
            )
          : childContent,
    );
  }

  Widget _buildScaffold(
    BrowsePagedData<T> pageData, {
    required bool isLoading,
  }) {
    final pageSize = metronDefaultPageSize;
    final totalPages = (pageData.count / pageSize).ceil().clamp(1, 9999);

    return PagedListScaffold(
      onRefresh: widget.onRefresh,
      currentPage: pageData.currentPage,
      totalPages: totalPages,
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      onPrevious: widget.onPrevious,
      onNext: widget.onNext,
      itemCount: pageData.results.length,
      header: null,
      isLoading: isLoading,
      skeleton: _buildSkeletonList(),
      itemBuilder: (context, index) {
        final item = pageData.results[index];
        return widget.itemBuilder(
          context,
          item,
          index,
          pageData.results.length,
        );
      },
      emptyMessage: widget.emptyMessage,
      emptyIcon: widget.emptyIcon,
    );
  }

  Widget _buildSkeletonList() {
    return ShimmerWidget(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        padding: const EdgeInsets.only(bottom: 8),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: index == 0 ? 12 : 2,
              bottom: index == 7 ? 0 : 2,
            ),
            child: const Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    SkeletonBox(width: 56, height: 80, borderRadius: 8),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(height: 16, width: double.infinity),
                          SizedBox(height: 8),
                          SkeletonBox(height: 14, width: 180),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
