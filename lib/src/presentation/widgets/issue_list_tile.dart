import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';

class IssueListTile extends ConsumerWidget {
  final IssueList issue;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final bool? isCollected;
  final bool? isRead;
  final int? rating;
  final bool useCardBackground;
  final bool showDivider;
  final double horizontalPadding;

  const IssueListTile({
    super.key,
    required this.issue,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.isCollected,
    this.isRead,
    this.rating,
    this.useCardBackground = false,
    this.showDivider = true,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double imageHeight = 98;
    const double imageWidth = 67;
    final effectiveOnTap =
        onTap ??
        (issue.id == null
            ? null
            : () {
                context.pushRoute(
                  IssueDetailsRoute(
                    issueId: issue.id!,
                    initialImageUrl: issue.image,
                  ),
                );
              });

    final providerStatus = ref.watch(issueCollectionStatusProvider(issue.id));
    final pullEntryAsync = issue.id == null
        ? null
        : ref.watch(issuePullListEntryProvider(issue.id!));
    final effectiveIsCollected =
        isCollected ?? providerStatus?.isCollected ?? false;
    final effectiveIsWishlisted = providerStatus?.isWishlisted ?? false;
    final effectiveIsRead = isRead ?? providerStatus?.isRead ?? false;
    final effectiveIsPulled = pullEntryAsync?.asData?.value != null;
    final effectiveRating = rating ?? providerStatus?.rating;
    final isFavorite = issue.id != null && ref.watch(isIssueFavoriteProvider(issue.id!)).asData?.value == true;

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: issue.image != null
          ? CachedNetworkImage(
              imageUrl: issue.image!,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: imageWidth,
                height: imageHeight,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: imageWidth,
                height: imageHeight,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, size: 40),
              ),
            )
          : Container(
              width: imageWidth,
              height: imageHeight,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image, size: 40),
            ),
    );

    final leading = imageWidget;

    final tileContent = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (issue.storeDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      DateFormat.yMMMd().format(issue.storeDate!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        effectiveIsCollected
                            ? Icons.inventory_2
                            : Icons.inventory_2_outlined,
                        size: 16,
                        color: effectiveIsCollected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        effectiveIsRead
                            ? Icons.bookmark_added
                            : Icons.bookmark_added_outlined,
                        size: 16,
                        color: effectiveIsRead
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        effectiveIsPulled
                            ? Icons.shopping_bag
                            : Icons.shopping_bag_outlined,
                        size: 16,
                        color: effectiveIsPulled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        effectiveIsWishlisted
                            ? Icons.turned_in
                            : Icons.turned_in_not,
                        size: 16,
                        color: effectiveIsWishlisted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      if (isFavorite) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.red,
                        ),
                      ],
                      const Spacer(),
                      if ((effectiveRating ?? 0) > 0)
                        ...List.generate(5, (index) {
                          final value = (effectiveRating ?? 0).clamp(0, 5);
                          return Icon(
                            index < value ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (useCardBackground) {
      const radius = 24.0;
      return Card(
        margin: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, bottom: isLast ? 12 : 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(radius) : Radius.zero,
            bottom: isLast ? const Radius.circular(radius) : Radius.zero,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: effectiveOnTap, child: tileContent),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: isFirst ? 12 : 2,
        bottom: isLast ? 12 : 0,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: effectiveOnTap,
              child: tileContent,
            ),
          ),
          if (showDivider && !isLast) const Divider(height: 1),
        ],
      ),
    );
  }
}
