import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/paged_list_scaffold.dart';

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

class BrowsePagedListScreen<T> extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: appBarActions),
      body: pageAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) =>
            AsyncStatePanel.error(errorMessage: '$errorPrefix: $error'),
        data: (pageData) {
          final pageSize = pageData.results.isEmpty
              ? 100
              : pageData.results.length;
          final totalPages = (pageData.count / pageSize).ceil().clamp(1, 9999);

          return PagedListScaffold(
            onRefresh: onRefresh,
            currentPage: pageData.currentPage,
            totalPages: totalPages,
            hasPrevious: pageData.hasPrevious,
            hasNext: pageData.hasNext,
            onPrevious: onPrevious,
            onNext: onNext,
            itemCount: pageData.results.length,
            itemBuilder: (context, index) {
              final item = pageData.results[index];
              return itemBuilder(context, item, index, pageData.results.length);
            },
            emptyMessage: emptyMessage,
            emptyIcon: emptyIcon,
          );
        },
      ),
    );
  }
}
