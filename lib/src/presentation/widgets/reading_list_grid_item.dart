import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/widgets/reading_list_issue_card.dart';
import 'package:takion/src/presentation/widgets/series_card.dart';

import 'package:takion/src/presentation/providers/reading_list_item_status_provider.dart';

import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';

class ReadingListGridItem extends ConsumerWidget {
  final ReadingListItem item;
  final VoidCallback onTap;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback? onRemove;

  const ReadingListGridItem({
    super.key, 
    required this.item, 
    required this.onTap,
    this.isEditing = false,
    this.isSelected = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metadataAsync = ref.watch(readingListItemMetadataProvider((targetId: item.targetId, isSeries: item.isSeries)));
    final isReadAsync = ref.watch(readingListItemEffectiveReadStatusProvider(item));
    final effectiveIsRead = isReadAsync.value ?? item.isRead;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              metadataAsync.when(
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
                    return SeriesCard(
                      series: series,
                      onTap: onTap,
                      width: double.infinity,
                      isRead: effectiveIsRead,
                      role: item.role,
                    );
                  } else if (metadata is IssueDetails) {
                    final status = ref.watch(issueCollectionStatusProvider(metadata.id));
                    final pullEntryAsync = ref.watch(issuePullListEntryProvider(metadata.id));
                    
                    return ReadingListIssueCard(
                      issueId: metadata.id,
                      imageUrl: metadata.image,
                      title: '${metadata.series?.name ?? ''} #${metadata.number}',
                      onTap: onTap,
                      isRead: effectiveIsRead,
                      isCollected: status?.isCollected ?? false,
                      isWishlisted: status?.isWishlisted ?? false,
                      isPulled: pullEntryAsync.asData?.value != null,
                      role: item.role,
                    );
                  }
                  return const Center(child: Icon(Icons.error));
                },
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (error, stack) => const Center(child: Icon(Icons.error, size: 20)),
              ),
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary, width: 3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isSelected)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
        if (isEditing)
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
