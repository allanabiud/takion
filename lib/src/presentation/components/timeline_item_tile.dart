import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';

import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';

class TimelineIssueTile extends ConsumerWidget {
  final ReadingListItem item;
  final double horizontalPadding;

  const TimelineIssueTile({
    super.key,
    required this.item,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(
      readingListItemMetadataProvider((
        targetId: item.targetId,
        isSeries: item.isSeries,
      )),
    );

    final isReadAsync = ref.watch(
      readingListItemEffectiveReadStatusProvider(item),
    );
    final effectiveIsRead = isReadAsync.value ?? item.isRead;

    return metadataAsync.when(
      data: (metadata) {
        if (metadata is IssueDetails) {
          final issue = IssueList(
            id: metadata.id,
            name:
                '${metadata.series?.name != null ? metadata.series!.name : 'Unknown'} #${metadata.number}',
            number: metadata.number,
            series: metadata.series != null
                ? Series(
                    id: metadata.series!.id,
                    name: metadata.series!.name,
                    volume: metadata.series!.volume,
                    yearBegan: metadata.series!.yearBegan,
                  )
                : null,
            image: metadata.image,
            coverDate: metadata.coverDate,
            storeDate: metadata.storeDate,
            modified: metadata.modified,
          );
          return IssueListTile(
            issue: issue,
            isRead: effectiveIsRead,
            showDivider: false,
            horizontalPadding: horizontalPadding,
          );
        }
        return const ListTile(title: Text('Loading...'));
      },
      loading: () => const ListTile(title: LinearProgressIndicator()),
      error: (error, stack) => const ListTile(title: Text('Error')),
    );
  }
}

class TimelineSeriesTile extends ConsumerWidget {
  final ReadingListItem item;
  final double horizontalPadding;

  const TimelineSeriesTile({
    super.key,
    required this.item,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(
      readingListItemMetadataProvider((
        targetId: item.targetId,
        isSeries: item.isSeries,
      )),
    );

    final isReadAsync = ref.watch(
      readingListItemEffectiveReadStatusProvider(item),
    );
    final effectiveIsRead = isReadAsync.value ?? item.isRead;

    return metadataAsync.when(
      data: (metadata) {
        if (metadata is SeriesDetails) {
          final series = SeriesList(
            id: metadata.id,
            name: metadata.name,
            yearBegan: metadata.yearBegan ?? 0,
            volume: metadata.volume ?? 0,
            issueCount: metadata.issueCount,
            seriesType: metadata.seriesType?.name,
          );
          return SeriesListTile(
            series: series,
            showDivider: false,
            isRead: effectiveIsRead,
            horizontalPadding: horizontalPadding,
          );
        }

        return const ListTile(title: Text('Loading...'));
      },
      loading: () => const ListTile(title: LinearProgressIndicator()),
      error: (error, stack) => const ListTile(title: Text('Error')),
    );
  }
}
