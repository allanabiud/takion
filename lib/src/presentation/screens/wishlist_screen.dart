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
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryWishlist),
    );
    final itemsAsync = ref.watch(wishlistCollectionItemsProvider);

    Future<void> refresh() async {
      ref.invalidate(wishlistCollectionItemsProvider);
      await ref.read(wishlistCollectionItemsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          DisplaySettingsButton(
            selectedOption: sortOption,
            optionLabel: issueSortLabel,
            onSelected: (option) {
              ref
                  .read(sortPreferencesProvider.notifier)
                  .setPreference(SortPreferenceContext.libraryWishlist, option);
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load wishlist comics: $error',
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
                      icon: Icons.favorite_border,
                      message: 'No wishlist comics yet.',
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
