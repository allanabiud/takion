import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/entity_cover.dart';
import 'package:takion/src/presentation/features/library/activity_log_group.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ActivityLogGroupTile extends ConsumerWidget {
  final ActivityLogGroup group;
  final bool isFirst;
  final bool isLast;
  final bool showTimestamp;

  const ActivityLogGroupTile({
    super.key,
    required this.group,
    required this.isFirst,
    required this.isLast,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventColor = _colorForEvent(context, group.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TimelineTile(
        nodeAlign: TimelineNodeAlign.start,
        node: TimelineNode(
          indicator: DotIndicator(
            size: 32,
            color: eventColor.withValues(alpha: 0.12),
            child: Icon(_iconForEvent(group.type), color: eventColor, size: 16),
          ),
          startConnector: isFirst
              ? null
              : SolidLineConnector(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  thickness: 2,
                ),
          endConnector: isLast
              ? null
              : SolidLineConnector(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  thickness: 2,
                ),
        ),
        contents: Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12.0),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleForGroup(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showTimestamp) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'h:mm a',
                          ).format(group.latestTimestamp.toLocal()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  _buildCoverStrip(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverStrip(BuildContext context) {
    final coverEntries = <({String url, int issueId})>[];
    final seen = <String>{};
    for (var i = 0; i < group.imageUrls.length; i++) {
      final url = group.imageUrls[i];
      if (url != null && url.isNotEmpty && seen.add(url)) {
        coverEntries.add((url: url, issueId: group.issueIds[i]));
      }
    }

    if (coverEntries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: coverEntries.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final entry = coverEntries[index];
            return GestureDetector(
              onTap: () =>
                  context.pushRoute(IssueDetailsRoute(issueId: entry.issueId)),
              child: SizedBox(
                width: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: EntityCover(
                    imageUrl: entry.url,
                    aspectRatio: 2 / 3,
                    borderRadius: 4,
                    iconSize: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _titleForGroup() {
    final count = group.count;
    switch (group.type) {
      case ActivityEventType.collected:
        return 'Added $count ${count == 1 ? 'issue' : 'issues'} to collection';
      case ActivityEventType.uncollected:
        return 'Removed $count ${count == 1 ? 'issue' : 'issues'} from collection';
      case ActivityEventType.read:
        return 'Read $count ${count == 1 ? 'issue' : 'issues'}';
      case ActivityEventType.unread:
        return 'Marked $count ${count == 1 ? 'issue' : 'issues'} as unread';
      case ActivityEventType.wishlisted:
        return 'Added $count ${count == 1 ? 'issue' : 'issues'} to wishlist';
      case ActivityEventType.unwishlisted:
        return 'Removed $count ${count == 1 ? 'issue' : 'issues'} from wishlist';
      case ActivityEventType.rated:
        return 'Rated $count ${count == 1 ? 'issue' : 'issues'}';
      case ActivityEventType.subscribed:
        return 'Subscribed to $count ${count == 1 ? 'series' : 'series'}';
      case ActivityEventType.unsubscribed:
        return 'Unsubscribed from $count ${count == 1 ? 'series' : 'series'}';
      case ActivityEventType.favorited:
        return 'Favorited $count ${count == 1 ? 'item' : 'items'}';
      case ActivityEventType.unfavorited:
        return 'Unfavorited $count ${count == 1 ? 'item' : 'items'}';
      case ActivityEventType.pulled:
        return 'Added $count ${count == 1 ? 'issue' : 'issues'} to pull list';
      case ActivityEventType.unpulled:
        return 'Removed $count ${count == 1 ? 'issue' : 'issues'} from pull list';
    }
  }

  IconData _iconForEvent(ActivityEventType type) {
    switch (type) {
      case ActivityEventType.collected:
        return Icons.inventory_2;
      case ActivityEventType.uncollected:
        return Icons.remove_circle_outline;
      case ActivityEventType.read:
        return Icons.bookmark_added;
      case ActivityEventType.unread:
        return Icons.bookmark_added_outlined;
      case ActivityEventType.wishlisted:
        return Icons.turned_in;
      case ActivityEventType.unwishlisted:
        return Icons.turned_in_not;
      case ActivityEventType.rated:
        return Icons.star;
      case ActivityEventType.subscribed:
        return Icons.notifications_active;
      case ActivityEventType.unsubscribed:
        return Icons.notifications_off_outlined;
      case ActivityEventType.favorited:
        return Icons.favorite;
      case ActivityEventType.unfavorited:
        return Icons.favorite_border;
      case ActivityEventType.pulled:
        return Icons.shopping_bag;
      case ActivityEventType.unpulled:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _colorForEvent(BuildContext context, ActivityEventType type) {
    final theme = Theme.of(context);
    switch (type) {
      case ActivityEventType.collected:
        return theme.colorScheme.primary;
      case ActivityEventType.uncollected:
        return theme.colorScheme.outline;
      case ActivityEventType.read:
        return theme.colorScheme.primary;
      case ActivityEventType.unread:
        return theme.colorScheme.outline;
      case ActivityEventType.wishlisted:
        return theme.colorScheme.tertiary;
      case ActivityEventType.unwishlisted:
        return theme.colorScheme.outline;
      case ActivityEventType.rated:
        return Colors.amber;
      case ActivityEventType.subscribed:
        return theme.colorScheme.primary;
      case ActivityEventType.unsubscribed:
        return theme.colorScheme.outline;
      case ActivityEventType.favorited:
        return Colors.redAccent;
      case ActivityEventType.unfavorited:
        return theme.colorScheme.outline;
      case ActivityEventType.pulled:
        return theme.colorScheme.secondary;
      case ActivityEventType.unpulled:
        return theme.colorScheme.outline;
    }
  }
}
