import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';

class IssueCard extends ConsumerWidget {
  final int? issueId;
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double width;
  final bool isCollected;
  final bool isWishlisted;
  final bool isRead;
  final bool isPulled;

  const IssueCard({
    super.key,
    this.issueId,
    this.imageUrl,
    required this.title,
    this.onTap,
    this.width = 120,
    this.isCollected = false,
    this.isWishlisted = false,
    this.isRead = false,
    this.isPulled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = issueId != null && ref.watch(isIssueFavoriteProvider(issueId!)).asData?.value == true;
    
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 32),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image, size: 32),
                  ),
            if (isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  cover,
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCollected
                              ? Icons.inventory_2
                              : Icons.inventory_2_outlined,
                          size: 16,
                          color: isCollected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isRead
                              ? Icons.bookmark_added
                              : Icons.bookmark_added_outlined,
                          size: 16,
                          color: isRead
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isPulled
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          size: 16,
                          color: isPulled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isWishlisted ? Icons.turned_in : Icons.turned_in_not,
                          size: 16,
                          color: isWishlisted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
