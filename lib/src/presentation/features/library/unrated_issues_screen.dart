import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/domain/extensions/collection_item_extension.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';

@RoutePage()
class UnratedIssuesScreen extends ConsumerWidget {
  const UnratedIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryUnrated),
    );
    final itemsAsync = ref.watch(unratedCollectionItemsProvider);

    Future<void> refresh() async {
      ref.invalidate(unratedCollectionItemsProvider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Unrated Comics')),
      body: itemsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load unrated comics: $error',
        ),
        data: (items) {
          final sortedItems = sortCollectionItems(items, sortOption);
          if (sortedItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: Icons.star_border_outlined,
                      message: 'No unrated comics yet.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: sortedItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ListHeader(
                      count: sortedItems.length,
                      unit: 'comic',
                      sortLabel: issueSortLabel(sortOption),
                      onSortTap: () => showSortBottomSheet(
                        context,
                        ref,
                        SortPreferenceContext.libraryUnrated,
                        issueSortLabel,
                      ),
                    ),
                  );
                }
                final item = sortedItems[index - 1];
                return IssueListTile(
                  issue: item.toIssueList(),
                  isFirst: index == 1,
                  isLast: index == sortedItems.length,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
