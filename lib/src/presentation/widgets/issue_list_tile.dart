import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_list.dart'; // Updated import
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';

class IssueListTile extends ConsumerWidget {
  final IssueList issue; // Updated to IssueList
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final bool? isCollected;
  final bool? isRead;
  final int? rating;

  const IssueListTile({
    super.key,
    required this.issue,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.isCollected,
    this.isRead,
    this.rating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 24.0;
    const double imageHeight = 110;
    const double imageWidth = 75;
    final heroTag = issue.id != null ? 'issue-cover-${issue.id}' : null;
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
          final effectiveIsCollected = isCollected ?? providerStatus?.isCollected ?? false;
          final effectiveIsRead = isRead ?? providerStatus?.isRead ?? false;
          final effectiveRating = rating ?? providerStatus?.rating;

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
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (heroTag != null)
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
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
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: imageWidth,
                              height: imageHeight,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Container(
                            width: imageWidth,
                            height: imageHeight,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 40),
                          ),
                  ),
                )
              else
                ClipRRect(
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
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: imageWidth,
                            height: imageHeight,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image, size: 40),
                        ),
                ),
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
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat.yMMMd().format(issue.storeDate!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
                            effectiveIsRead ? Icons.bookmark : Icons.bookmark_border,
                            size: 16,
                            color: effectiveIsRead
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
            ],
          ),
        ),
      ),
    );
  }
}
