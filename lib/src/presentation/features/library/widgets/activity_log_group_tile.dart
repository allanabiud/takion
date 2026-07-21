import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/components/entity_cover.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
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
            child: Icon(
              _iconForEvent(group.type),
              color: eventColor,
              size: 16,
            ),
          ),
          startConnector: isFirst
              ? null
              : SolidLineConnector(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  thickness: 2,
                ),
          endConnector: isLast
              ? null
              : SolidLineConnector(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showIssueSheet(context, ref),
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
                            DateFormat('h:mm a').format(group.latestTimestamp.toLocal()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (group.events.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tap for details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    _buildCoverStrip(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverStrip(BuildContext context) {
    final uniqueImages = <String?>[];
    final seen = <String>{};
    for (final url in group.imageUrls) {
      if (url != null && url.isNotEmpty && seen.add(url)) {
        uniqueImages.add(url);
      }
    }

    if (uniqueImages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: uniqueImages.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: EntityCover(
                  imageUrl: uniqueImages[index],
                  aspectRatio: 2 / 3,
                  borderRadius: 4,
                  iconSize: 14,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showIssueSheet(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: _titleForGroup(),
      isScrollControlled: true,
      child: Builder(
        builder: (sheetContext) {
          final sheetTheme = Theme.of(sheetContext);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.events.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final event = group.events[index];
              final issueStr = event.issueNumber != null ? '#${event.issueNumber}' : '';
              final seriesStr = event.seriesName ?? 'Unknown Series';

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 36,
                    height: 54,
                    child: EntityCover(
                      imageUrl: event.imageUrl,
                      aspectRatio: 2 / 3,
                      borderRadius: 4,
                      iconSize: 12,
                    ),
                  ),
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: seriesStr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (issueStr.isNotEmpty) TextSpan(
                        text: ' $issueStr',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  DateFormat('h:mm a').format(event.timestamp.toLocal()),
                  style: sheetTheme.textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.pushRoute(IssueDetailsRoute(issueId: event.issueId));
                },
              );
            },
          );
        },
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
    }
  }
}
