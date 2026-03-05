import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';

class CollectionIssueListTile extends ConsumerWidget {
  const CollectionIssueListTile({
    super.key,
    required this.item,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final CollectionItem item;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  String _issueTitle({String? hydratedSeriesName, String? hydratedNumber}) {
    final seriesName = hydratedSeriesName ?? item.issue?.series?.name.trim();
    final issueNumber = hydratedNumber ?? item.issue?.number.trim() ?? '';

    if (seriesName != null && seriesName.isNotEmpty) {
      if (issueNumber.isNotEmpty) return '$seriesName #$issueNumber';
      return seriesName;
    }

    if (issueNumber.isNotEmpty) return 'Issue #$issueNumber';
    return 'Issue';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 24.0;
    final issueId = item.issue?.id;
    final providerStatus = ref.watch(issueCollectionStatusProvider(issueId));
    final pullEntryAsync = issueId == null
        ? null
        : ref.watch(issuePullListEntryProvider(issueId));

    final effectiveIsCollected =
        providerStatus?.isCollected ?? (item.quantity > 0);
    final effectiveIsWishlisted = providerStatus?.isWishlisted ?? false;
    final effectiveIsRead = providerStatus?.isRead ?? item.isRead;
    final effectiveIsPulled = pullEntryAsync?.asData?.value != null;
    final effectiveRating = providerStatus?.rating ?? item.rating;
    final shouldHydrateIssue =
        issueId != null &&
        ((item.issue?.number.trim().isEmpty ?? true) ||
            (item.issue?.series?.name.trim().isEmpty ?? true));
    final hydratedIssue = shouldHydrateIssue
        ? ref.watch(issueDetailsProvider(issueId)).asData?.value
        : null;
    final hydratedSeriesName = hydratedIssue?.series?.name.trim();
    final hydratedNumber = hydratedIssue?.number.trim();
    final hydratedStoreDate = hydratedIssue?.storeDate;
    final hydratedImage = hydratedIssue?.image?.trim();
    final imageUrl = (hydratedImage != null && hydratedImage.isNotEmpty)
        ? hydratedImage
        : item.issue?.image?.trim();

    final effectiveOnTap =
        onTap ??
        (issueId == null
            ? null
            : () {
                context.pushRoute(IssueDetailsRoute(issueId: issueId));
              });

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
        onTap: effectiveOnTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _issueTitle(
                        hydratedSeriesName: hydratedSeriesName,
                        hydratedNumber: hydratedNumber,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hydratedStoreDate != null ||
                        item.issue?.storeDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          DateFormat.yMMMd().format(
                            hydratedStoreDate ?? item.issue!.storeDate!,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: effectiveIsWishlisted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
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
              const SizedBox(width: 12),
              SizedBox(
                width: 46,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, _) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, _, error) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
