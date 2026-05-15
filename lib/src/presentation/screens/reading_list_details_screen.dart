import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/providers/reading_list_details_provider.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';
import 'package:takion/src/presentation/widgets/add_reading_list_items_bottom_sheet.dart';
import 'package:takion/src/presentation/widgets/reading_list_cover.dart';
import 'package:takion/src/presentation/widgets/reading_list_grid_item.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/widgets/timeline_item_tile.dart';
import 'package:timelines_plus/timelines_plus.dart';

@RoutePage()
class ReadingListDetailsScreen extends ConsumerWidget {
  final String listId;

  const ReadingListDetailsScreen({
    super.key,
    @PathParam('listId') required this.listId,
  });

  Color _getRoleColor(BuildContext context, ItemRole role) {
    final theme = Theme.of(context);
    switch (role) {
      case ItemRole.core: return Colors.red;
      case ItemRole.prologue: return Colors.orange;
      case ItemRole.tieIn: return Colors.blue;
      case ItemRole.epilogue: return Colors.purple;
      case ItemRole.standard: return theme.colorScheme.primary;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ReadingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading List'),
        content: Text('Are you sure you want to delete "${list.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(readingListsProvider.notifier).deleteList(list.id);
      if (context.mounted) {
        TakionAlerts.success(context, 'Reading list deleted');
        context.router.pop();
      }
    }
  }

  Widget buildHeader(BuildContext context, ReadingList list, double progress, int readCount, int totalCount) {
    final theme = Theme.of(context);
    Widget buildBadge(String label, IconData icon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 4),
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReadingListCover(list: list, width: 100, height: 120),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    if (list.description.isNotEmpty) ...[const SizedBox(height: 4), Text(list.description, style: theme.textTheme.bodyMedium)],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [buildBadge(list.isOrdered ? 'Ordered' : 'Unordered', list.isOrdered ? Icons.account_tree_outlined : Icons.grid_view_outlined), const SizedBox(width: 8), buildBadge(list.contentType.name, Icons.category_outlined)]),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$readCount / $totalCount ${list.contentType == ListContentType.series ? 'Series' : 'Issues'} Read', style: theme.textTheme.bodySmall),
              Text('${(progress * 100).toInt()}% Complete', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listValue = ref.watch(readingListDetailsProvider(listId));
    return listValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (list) {
        if (list == null) return const Scaffold(body: Center(child: Text('List not found')));
        final readCount = list.items.where((i) => i.isRead).length;
        final totalCount = list.items.length;
        final progress = totalCount > 0 ? readCount / totalCount : 0.0;
        
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref, list),
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          body: list.isOrdered 
            ? buildOrderedBody(context, list, progress, readCount, totalCount) 
            : buildUnorderedBody(context, list, progress, readCount, totalCount),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
                IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                const Spacer(),
                FloatingActionButton(onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => AddReadingListItemsBottomSheet(list: list)), child: const Icon(Icons.add)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOrderedBody(BuildContext context, ReadingList list, double progress, int readCount, int totalCount) {
    return ListView.builder(
      itemCount: list.items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return buildHeader(context, list, progress, readCount, totalCount);
        final item = list.items[index - 1];
        final roleColor = _getRoleColor(context, item.role);
        final isRead = item.isRead;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TimelineTile(
            nodeAlign: TimelineNodeAlign.start,
            node: TimelineNode(
              indicator: DotIndicator(
                size: 28,
                color: isRead ? roleColor : Theme.of(context).colorScheme.surface,
                border: Border.all(color: roleColor, width: 2),
                child: isRead
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
              startConnector: index - 1 == 0 ? null : SolidLineConnector(color: roleColor, thickness: 3),
              endConnector: index - 1 == list.items.length - 1 ? null : SolidLineConnector(color: roleColor, thickness: 3),
            ),
            contents: item.isSeries ? TimelineSeriesTile(item: item) : TimelineIssueTile(item: item),
          ),
        );
      },
    );
  }

  Widget buildUnorderedBody(BuildContext context, ReadingList list, double progress, int readCount, int totalCount) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: buildHeader(context, list, progress, readCount, totalCount)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.45, crossAxisSpacing: 12, mainAxisSpacing: 12),
            delegate: SliverChildBuilderDelegate((context, index) => ReadingListGridItem(item: list.items[index], onTap: () {}), childCount: list.items.length),
          ),
        ),
      ],
    );
  }
}
