import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/collection_issue_list_tile.dart';

@RoutePage()
class CollectionReadStatusScreen extends ConsumerWidget {
  const CollectionReadStatusScreen({
    super.key,
    required this.isRead,
  });

  final bool isRead;

  String get _title => isRead ? 'Read Comics' : 'Unread Comics';

  String get _emptyMessage =>
      isRead
          ? 'No read comics in your collection yet.'
          : 'No unread comics in your collection.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(collectionItemsByReadStatusProvider(isRead));

    Future<void> refresh() async {
      ref.invalidate(collectionItemsByReadStatusProvider(isRead));
      await ref.read(collectionItemsByReadStatusProvider(isRead).future);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: itemsAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load collection items: $error',
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 220),
                  Center(child: Text(_emptyMessage)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CollectionIssueListTile(
                  item: item,
                  isFirst: index == 0,
                  isLast: index == items.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
