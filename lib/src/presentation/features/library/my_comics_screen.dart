import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/domain/extensions/collection_item_extension.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/components.dart';

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

    final statsAsync = ref.watch(collectionStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Comics')),
      body: Column(
        children: [
          if (statsAsync.asData?.value != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Collection Value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    statsAsync.asData!.value.totalValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          // Pinned sort header
          pageAsync.when(
            loading: () {
              if (_lastPage != null) {
                return _buildPinnedHeader(
                  _lastPage!, sortOption, isLoading: true,
                );
              }
              return const SizedBox.shrink();
            },
            error: (_, _) => const SizedBox.shrink(),
            data: (pageData) => _buildPinnedHeader(
              pageData, sortOption, isLoading: false,
            ),
          ),
          Expanded(
            child: pageAsync.when(
              loading: () {
                if (_lastPage != null) {
                  return _buildContent(_lastPage!, isLoading: true);
                }
                return const AsyncStatePanel.loading();
              },
              error: (error, _) => AsyncStatePanel.error(
                errorMessage: 'Failed to load comics',
              ),
              data: (pageData) => _buildContent(
                  pageData, isLoading: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedHeader(
    CollectionItemsPage pageData,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    return ListHeader(
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
    );
  }

  Widget _buildContent(
    CollectionItemsPage pageData, {
    required bool isLoading,
  }) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryMyComics),
    );
    final sortedItems = sortCollectionItems(pageData.results, sortOption);

    final totalPages = (pageData.count / metronDefaultPageSize).ceil().clamp(
      1,
      9999,
    );

    return PagedListScaffold(
      onRefresh: _refreshPage,
      currentPage: _page,
      totalPages: totalPages,
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      isLoading: isLoading,
      header: null,
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
