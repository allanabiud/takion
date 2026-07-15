import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_cached_metadata_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/features/series/series_card.dart';

import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart';

import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';

class ReadingListGridItem extends ConsumerWidget {
  final ReadingListItem item;
  final VoidCallback onTap;
  final bool isEditing;
  final bool isSelected;
  final bool allowRemoteHydration;
  final VoidCallback? onRemove;

  const ReadingListGridItem({
    super.key,
    required this.item,
    required this.onTap,
    this.isEditing = false,
    this.isSelected = false,
    this.allowRemoteHydration = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metadataAsync = allowRemoteHydration
        ? ref.watch(
            readingListItemMetadataProvider((
              targetId: item.targetId,
              isSeries: item.isSeries,
            )),
          ) as AsyncValue<Object?>
        : ref.watch(
            readingListItemCachedMetadataProvider((
              targetId: item.targetId,
              isSeries: item.isSeries,
            )),
          );
    final isReadAsync = ref.watch(
      readingListItemEffectiveReadStatusProvider(item),
    );
    final effectiveIsRead = isReadAsync.value ?? item.isRead;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedScale(
          scale: isSelected ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  metadataAsync.when(
                    data: (metadata) {
                      final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
                      if (item.isSeries) {
                        SeriesList series;
                        String? imageUrl;
                        if (metadata is SeriesDetails) {
                          series = SeriesList(
                            id: metadata.id,
                            name: metadata.name,
                            yearBegan: metadata.yearBegan,
                            volume: metadata.volume,
                            issueCount: metadata.issueCount,
                            seriesType: metadata.seriesType?.name,
                          );
                          imageUrl = metadata.image;
                        } else {
                          series = SeriesList(
                            id: id,
                            name: id > 0 ? 'Series #$id' : 'Series',
                            yearBegan: null,
                            volume: null,
                          );
                        }
                        return SeriesCard(
                          series: series,
                          imageUrl: imageUrl,
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          role: item.role,
                        );
                      } else {
                        final status = ref.watch(
                          issueCollectionStatusProvider(id),
                        );
                        final pullEntryAsync = ref.watch(
                          issuePullListEntryProvider(id),
                        );

                        String title = id > 0 ? 'Issue #$id' : 'Issue';
                        String? imageUrl;

                        if (metadata is IssueDetails) {
                          final seriesName = metadata.series?.name ?? '';
                          title = seriesName.isNotEmpty ? '$seriesName #${metadata.number}' : 'Issue #${metadata.number}';
                          imageUrl = metadata.image;
                        } else {
                          ref.watch(entityImageVersionProvider);
                          final cache = ref.read(entityImageCacheProvider);
                          final cachedImage = cache.getCached('issue', id);
                          imageUrl = cachedImage;
                        }

                        return IssueCard(
                          issueId: id > 0 ? id : null,
                          imageUrl: imageUrl,
                          title: title,
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          isCollected: status?.isCollected ?? false,
                          isWishlisted: status?.isWishlisted ?? false,
                          isPulled: pullEntryAsync.asData?.value != null,
                          role: item.role,
                          compact: true,
                        );
                      }
                    },
                    loading: () {
                      final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
                      if (item.isSeries) {
                        return SeriesCard(
                          series: SeriesList(
                            id: id,
                            name: id > 0 ? 'Series #$id' : 'Series',
                            yearBegan: null,
                            volume: null,
                          ),
                          imageUrl: null,
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          role: item.role,
                        );
                      } else {
                        return IssueCard(
                          issueId: id > 0 ? id : null,
                          imageUrl: null,
                          title: id > 0 ? 'Issue #$id' : 'Issue',
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          compact: true,
                        );
                      }
                    },
                    error: (error, stack) {
                      final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
                      if (item.isSeries) {
                        return SeriesCard(
                          series: SeriesList(
                            id: id,
                            name: id > 0 ? 'Series #$id' : 'Series',
                            yearBegan: null,
                            volume: null,
                          ),
                          imageUrl: null,
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          role: item.role,
                        );
                      } else {
                        return IssueCard(
                          issueId: id > 0 ? id : null,
                          imageUrl: null,
                          title: id > 0 ? 'Issue #$id' : 'Issue',
                          onTap: onTap,
                          width: double.infinity,
                          isRead: effectiveIsRead,
                          compact: true,
                        );
                      }
                    },
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isEditing)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
