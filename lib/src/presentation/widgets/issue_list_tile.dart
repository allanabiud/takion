import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/presentation/providers/collection_provider.dart';

class IssueListTile extends ConsumerWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const IssueListTile({
    super.key,
    required this.issue,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 24.0;
    final collectionAsync = ref.watch(collectionProvider);

    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: isLast ? 12 : 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(radius) : Radius.zero,
          bottom: isLast ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Column
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: issue.image != null
                    ? CachedNetworkImage(
                        imageUrl: issue.image!,
                        width: 70,
                        height: 105,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 70,
                          height: 105,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 105,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image, size: 28),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 105,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image, size: 28),
                      ),
              ),
              const SizedBox(width: 16),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (issue.storeDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat.yMMMd().format(issue.storeDate!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Status Icons Row
                    collectionAsync.when(
                      data: (collectionMap) {
                        final isCollected = collectionMap.containsKey(issue.id);
                        final isRead = collectionMap[issue.id] ?? false;

                        return Row(
                          children: [
                            Icon(
                              isCollected ? Icons.book : Icons.book_outlined,
                              size: 18,
                              color: isCollected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              isRead
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 18,
                              color: isRead
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
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
