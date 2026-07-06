import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/metron_reading_list_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:timelines_plus/timelines_plus.dart';

class MetronReadingListTimelineTile extends ConsumerWidget {
  const MetronReadingListTimelineTile({
    super.key,
    required this.item,
    required this.index,
    required this.isFirst,
    required this.isLast,
    this.previousIssueId,
  });

  final MetronReadingListItem item;
  final int index;
  final bool isFirst;
  final bool isLast;
  final int? previousIssueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isRead =
        ref.watch(issueCollectionStatusProvider(item.issueId))?.isRead ?? false;

    final previousStatus = previousIssueId == null
        ? null
        : ref.watch(issueCollectionStatusProvider(previousIssueId));
    final prevIsRead = previousStatus?.isRead ?? false;

    final seriesName = item.seriesName?.trim();
    final issueNumber = item.issueNumber?.trim();
    final issue = IssueList(
      id: item.issueId,
      name: seriesName != null && seriesName.isNotEmpty ? seriesName : 'Issue',
      number: issueNumber ?? '',
      series:
          item.seriesId != null && seriesName != null && seriesName.isNotEmpty
          ? Series(
              id: item.seriesId!,
              name: seriesName,
              volume: item.seriesVolume,
              yearBegan: null,
            )
          : null,
      coverDate: item.coverDate,
      storeDate: item.storeDate,
      image: null,
      modified: null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TimelineTile(
        nodeAlign: TimelineNodeAlign.start,
        node: TimelineNode(
          indicator: DotIndicator(
            size: 28,
            color: isRead ? theme.colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: isRead
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 2,
            ),
            child: isRead
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          startConnector: isFirst
              ? null
              : (prevIsRead
                    ? SolidLineConnector(
                        color: theme.colorScheme.primary,
                        thickness: 3,
                      )
                    : DashedLineConnector(
                        color: theme.colorScheme.outline,
                        thickness: 3,
                        dash: 2,
                        gap: 2,
                      )),
          endConnector: isLast
              ? null
              : (isRead
                    ? SolidLineConnector(
                        color: theme.colorScheme.primary,
                        thickness: 3,
                      )
                    : DashedLineConnector(
                        color: theme.colorScheme.outline,
                        thickness: 3,
                        dash: 2,
                        gap: 2,
                      )),
        ),
        contents: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 6),
          child: IssueListTile(
            issue: issue,
            horizontalPadding: 0,
            allowRemoteHydration: index <= 3,
          ),
        ),
      ),
    );
  }
}
