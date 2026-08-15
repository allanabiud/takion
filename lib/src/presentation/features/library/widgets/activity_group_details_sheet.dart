import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/activity_log_group.dart";
import "package:takion/src/presentation/shared/widgets/entity_cover.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";

Future<void> showActivityGroupDetailsSheet(
  BuildContext context,
  ActivityLogGroup group,
) {
  return TakionBottomSheet.show(
    context: context,
    title: _titleForSheet(group),
    titleHeader: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleForSheet(group),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.comicTimeDate(group.latestTimestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
    child: ListView.separated(
      shrinkWrap: true,
      itemCount: group.events.length,
      separatorBuilder: (context, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final event = group.events[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: SizedBox(
            width: 40,
            child: EntityCover(
              imageUrl: event.imageUrl,
              aspectRatio: 2 / 3,
              borderRadius: 4,
              iconSize: 12,
            ),
          ),
          title: Text(
            event.issueNumber?.trim().isNotEmpty == true && event.seriesName?.trim().isNotEmpty == true
                ? "${event.seriesName!.trim()} #${event.issueNumber!.trim()}"
                : event.issueNumber?.trim().isNotEmpty == true
                    ? "#${event.issueNumber!.trim()}"
                    : "Issue #${event.issueId}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () {
            Navigator.of(context).pop();
            context.pushRoute(
              IssueDetailsRoute(
                issueId: event.issueId,
                initialImageUrl: event.imageUrl,
              ),
            );
          },
        );
      },
    ),
  );
}

String _titleForSheet(ActivityLogGroup group) {
  final count = group.count;
  final seriesName = group.seriesName?.trim().isNotEmpty == true
      ? group.seriesName!.trim()
      : null;

  switch (group.type) {
    case ActivityEventType.collected:
      return seriesName != null
          ? 'Added $count ${count == 1 ? 'issue' : 'issues'} of $seriesName'
          : 'Added $count ${count == 1 ? 'issue' : 'issues'}';
    case ActivityEventType.uncollected:
      return seriesName != null
          ? 'Removed $count ${count == 1 ? 'issue' : 'issues'} of $seriesName'
          : 'Removed $count ${count == 1 ? 'issue' : 'issues'}';
    case ActivityEventType.read:
      return seriesName != null
          ? 'Read $count ${count == 1 ? 'issue' : 'issues'} of $seriesName'
          : 'Read $count ${count == 1 ? 'issue' : 'issues'}';
    case ActivityEventType.unread:
      return seriesName != null
          ? 'Marked $count ${count == 1 ? 'issue' : 'issues'} of $seriesName as unread'
          : 'Marked $count ${count == 1 ? 'issue' : 'issues'} as unread';
    case ActivityEventType.wishlisted:
      return seriesName != null
          ? 'Added $count ${count == 1 ? 'issue' : 'issues'} of $seriesName to wishlist'
          : 'Added $count ${count == 1 ? 'issue' : 'issues'} to wishlist';
    case ActivityEventType.unwishlisted:
      return seriesName != null
          ? 'Removed $count ${count == 1 ? 'issue' : 'issues'} of $seriesName from wishlist'
          : 'Removed $count ${count == 1 ? 'issue' : 'issues'} from wishlist';
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
      return seriesName != null
          ? 'Added $count ${count == 1 ? 'issue' : 'issues'} of $seriesName to pull list'
          : 'Added $count ${count == 1 ? 'issue' : 'issues'} to pull list';
    case ActivityEventType.unpulled:
      return seriesName != null
          ? 'Removed $count ${count == 1 ? 'issue' : 'issues'} of $seriesName from pull list'
          : 'Removed $count ${count == 1 ? 'issue' : 'issues'} from pull list';
  }
}
