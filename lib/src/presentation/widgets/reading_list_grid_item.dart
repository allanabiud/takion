import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/widgets/reading_list_issue_card.dart';
import 'package:takion/src/presentation/widgets/series_card.dart';

class ReadingListGridItem extends ConsumerWidget {
  final ReadingListItem item;
  final VoidCallback onTap;

  const ReadingListGridItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(readingListItemMetadataProvider((targetId: item.targetId, isSeries: item.isSeries)));

    return GestureDetector(
      onTap: onTap,
      child: metadataAsync.when(
        data: (metadata) {
          if (metadata is SeriesDetails) {
            final series = SeriesList(
              id: metadata.id,
              name: metadata.name,
              yearBegan: metadata.yearBegan,
              volume: metadata.volume,
              issueCount: metadata.issueCount,
              seriesType: metadata.seriesType?.name,
            );
            return SeriesCard(series: series, onTap: onTap, width: double.infinity);
          } else if (metadata is IssueDetails) {
            return ReadingListIssueCard(
              issueId: metadata.id,
              imageUrl: metadata.image,
              title: '${metadata.series?.name ?? ''} #${metadata.number}',
              onTap: onTap,
              isRead: item.isRead,
            );
          }
          return const Center(child: Icon(Icons.error));
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Center(child: Icon(Icons.error, size: 20)),
      ),
    );
  }
}
