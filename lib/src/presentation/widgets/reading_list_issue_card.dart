import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';

class ReadingListIssueCard extends ConsumerWidget {
  final int? issueId;
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;
  final bool isCollected;
  final bool isWishlisted;
  final bool isRead;
  final bool isPulled;

  const ReadingListIssueCard({
    super.key,
    this.issueId,
    this.imageUrl,
    required this.title,
    this.onTap,
    this.isCollected = false,
    this.isWishlisted = false,
    this.isRead = false,
    this.isPulled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = issueId != null && ref.watch(isIssueFavoriteProvider(issueId!)).asData?.value == true;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl != null
                          ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image, size: 24),
                            ),
                      if (isFavorite)
                        Positioned(
                          top: 4, right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, size: 12, color: Colors.red),
                          ),
                        ),
                      if (isRead)
                        Positioned(
                          bottom: 4, right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(isCollected ? Icons.inventory_2 : Icons.inventory_2_outlined, size: 14, color: isCollected ? theme.colorScheme.primary : theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Icon(isRead ? Icons.bookmark_added : Icons.bookmark_added_outlined, size: 14, color: isRead ? theme.colorScheme.primary : theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Icon(isPulled ? Icons.shopping_bag : Icons.shopping_bag_outlined, size: 14, color: isPulled ? theme.colorScheme.primary : theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Icon(isWishlisted ? Icons.turned_in : Icons.turned_in_not, size: 14, color: isWishlisted ? theme.colorScheme.primary : theme.colorScheme.outline),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
