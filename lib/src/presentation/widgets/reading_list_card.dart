import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/widgets/reading_list_cover.dart';

class ReadingListCard extends StatelessWidget {
  final ReadingList list;
  final VoidCallback onTap;

  const ReadingListCard({
    super.key,
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = list.items.isEmpty
        ? 0.0
        : list.items.where((i) => i.isRead).length / list.items.length;
    final isCompleted = progress >= 1.0;

    String contentTypeLabel;
    switch (list.contentType) {
      case ListContentType.series:
        contentTypeLabel = 'Series';
        break;
      case ListContentType.issue:
        contentTypeLabel = 'Issues';
        break;
    }

    final itemCount = list.items.length;
    final unitLabel = list.contentType == ListContentType.series ? 'Series' : 'Issues';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ReadingListCover(list: list),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          list.isOrdered ? Icons.account_tree_outlined : Icons.grid_view_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemCount $unitLabel • $contentTypeLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${(progress * 100).toInt()}% Done',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
