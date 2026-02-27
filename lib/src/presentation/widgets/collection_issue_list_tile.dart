import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';

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

  String _issueTitle() {
    final seriesName = item.issue?.series?.name.trim();
    final issueNumber = item.issue?.number.trim() ?? '';

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

    final effectiveIsCollected = providerStatus?.isCollected ?? (item.quantity > 0);
    final effectiveIsRead = providerStatus?.isRead ?? item.isRead;
    final effectiveRating = providerStatus?.rating ?? item.rating;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _issueTitle(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.issue?.storeDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat.yMMMd().format(item.issue!.storeDate!),
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
      ),
    );
  }
}
