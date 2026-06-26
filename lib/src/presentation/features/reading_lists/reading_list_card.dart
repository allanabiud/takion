import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/reading_list_cover.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';

class ReadingListCard extends ConsumerWidget {
  final ReadingList list;
  final VoidCallback onTap;
  final bool? isSelected;
  final bool alreadyExists;
  final ValueChanged<bool?>? onSelected;
  final bool compact;
  final bool flat;

  const ReadingListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.isSelected,
    this.alreadyExists = false,
    this.onSelected,
    this.compact = false,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(readingListEffectiveStatusProvider(list));
    final status =
        statusAsync.value ??
        (readCount: 0, totalCount: list.items.length, progress: 0.0);
    final progress = status.progress;
    final isCompleted = progress >= 1.0;
    final isFavoriteAsync = ref.watch(isReadingListFavoriteProvider(list.id));
    final isFavorite = isFavoriteAsync.value ?? false;

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
    final unitLabel = list.contentType == ListContentType.series
        ? 'Series'
        : 'Issues';

    final cardChild = Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: alreadyExists ? 0.6 : 1.0,
            child: Padding(
              padding: compact
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.all(12),
              child: Row(
                children: [
                  ReadingListCover(list: list, peekOffset: 6),
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (alreadyExists)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Added',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (isFavorite)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            Icon(
                              list.isOrdered
                                  ? Icons.account_tree_outlined
                                  : Icons.grid_view_outlined,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(progress * 100).toInt()}% Done',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
        ),
        if (isSelected == true || alreadyExists)
          Positioned(
            left: 4,
            top: 4,
            child: Icon(
              isSelected == true ? Icons.check_circle : Icons.check_circle_outline,
              color: alreadyExists 
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
      ],
    );

    if (flat) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected == true
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : Border.all(color: Colors.transparent),
        ),
        margin: EdgeInsets.zero,
        child: cardChild,
      );
    }

    return Card(
      margin: compact
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected == true
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: cardChild,
    );
  }
}
