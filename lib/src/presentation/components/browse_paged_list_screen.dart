import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/components/paged_list_scaffold.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.appBarActions),
      body: pageAsync.when(
        loading: () {
          if (data != null) {
            return _buildScaffold(data, isLoading: true);
          }
          return const AsyncStatePanel.loading();
        },
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: '${widget.errorPrefix}: $error',
        ),
        data: (pageData) {
          return _buildScaffold(pageData, isLoading: false);
        },
      ),
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
      header: widget.header,
      isLoading: isLoading,
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
}
