import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/domain/extensions/collection_item_extension.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/components/paged_list_scaffold.dart';

@RoutePage()
class MyComicsScreen extends ConsumerStatefulWidget {
  const MyComicsScreen({super.key});

  @override
  ConsumerState<MyComicsScreen> createState() => _MyComicsScreenState();
}

class _MyComicsScreenState extends ConsumerState<MyComicsScreen> {
  int _page = 1;
  CollectionItemsPage? _lastPage;

  Future<void> _refreshPage() async {
    ref.invalidate(collectionItemsProvider(_page));
    await ref.read(collectionItemsProvider(_page).future);
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryMyComics),
    );
    final pageAsync = ref.watch(collectionItemsProvider(_page));

    if (pageAsync.hasValue) {
      _lastPage = pageAsync.value;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Comics')),
      body: pageAsync.when(
        loading: () {
          if (_lastPage != null) {
            return _buildContent(_lastPage!, sortOption, isLoading: true);
          }
          return const AsyncStatePanel.loading();
        },
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load comics: $error',
        ),
        data: (pageData) =>
            _buildContent(pageData, sortOption, isLoading: false),
      ),
    );
  }

  Widget _buildContent(
    CollectionItemsPage pageData,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final sortedItems = sortCollectionItems(pageData.results, sortOption);
    final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
    final totalPages = (pageData.count / pageSize).ceil().clamp(1, 9999);

    return PagedListScaffold(
      onRefresh: _refreshPage,
      currentPage: _page,
      totalPages: totalPages,
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      isLoading: isLoading,
      header: ListHeader(
        count: pageData.count,
        unit: 'comic',
        enabled: !isLoading,
        sortLabel: issueSortLabel(sortOption),
        onSortTap: () => showSortBottomSheet(
          context,
          ref,
          SortPreferenceContext.libraryMyComics,
          issueSortLabel,
        ),
      ),
      onPrevious: () {
        final previousPage = pageData.previousPage;
        if (previousPage == null) return;
        setState(() {
          _page = previousPage;
        });
      },
      onNext: () {
        final nextPage = pageData.nextPage;
        if (nextPage == null) return;
        setState(() {
          _page = nextPage;
        });
      },
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        return Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: IssueListTile(
            issue: item.toIssueList(),
            isFirst: index == 0,
            isLast: index == sortedItems.length - 1,
          ),
        );
      },
      emptyMessage: 'No comics in your collection yet.',
      emptyIcon: Icons.library_books_outlined,
    );
  }
}
