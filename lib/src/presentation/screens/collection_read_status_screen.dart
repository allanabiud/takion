import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/extensions/collection_item_extension.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/list_header.dart';
import 'package:takion/src/presentation/widgets/sort_bottom_sheet.dart';

@RoutePage()
class CollectionReadStatusScreen extends ConsumerWidget {
  const CollectionReadStatusScreen({super.key, required this.isRead});

  final bool isRead;

  String get _title => isRead ? 'Read Comics' : 'Unread Comics';

  String get _emptyMessage => isRead
      ? 'No read comics in your collection yet.'
      : 'No unread comics in your collection.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortContext = isRead
        ? SortPreferenceContext.libraryRead
        : SortPreferenceContext.libraryUnread;
    final sortOption = ref.watch(sortPreferenceForContextProvider(sortContext));
    final itemsAsync = ref.watch(collectionItemsByReadStatusProvider(isRead));

    Future<void> refresh() async {
      ref.invalidate(collectionItemsByReadStatusProvider(isRead));
      await ref.read(collectionItemsByReadStatusProvider(isRead).future);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: itemsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load collection items: $error',
        ),
        data: (items) {
          final sortedItems = sortCollectionItems(items, sortOption);
          if (sortedItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyContentState(
                      icon: isRead
                          ? Icons.bookmark_added_outlined
                          : Icons.bookmark_border_outlined,
                      message: _emptyMessage,
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
                        sortContext,
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
