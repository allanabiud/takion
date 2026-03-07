import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/collection_issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';

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
        actions: [
          DisplaySettingsButton(
            selectedOption: sortOption,
            optionLabel: issueSortLabel,
            onSelected: (option) {
              ref
                  .read(sortPreferencesProvider.notifier)
                  .setPreference(sortContext, option);
            },
          ),
        ],
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return CollectionIssueListTile(
                  item: item,
                  isFirst: index == 0,
                  isLast: index == sortedItems.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
