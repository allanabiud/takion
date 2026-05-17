import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';

class ReadingListCover extends ConsumerWidget {
  final ReadingList list;
  final double width;
  final double height;

  const ReadingListCover({
    super.key,
    required this.list,
    this.width = 60,
    this.height = 85,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Get up to 3 items for the trio covers
    final items = list.items.take(3).toList();
    
    // Horizontal offset for the peeking side covers
    const horizontalOffset = 14.0;
    // Total width including peeking areas
    final totalWidth = width + (horizontalOffset * 2);

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Left Peeking Cover (2nd or 3rd item)
          Positioned(
            left: 0,
            child: items.length >= 2
                ? _buildSideCover(context, ref, items[items.length >= 3 ? 2 : 1], opacity: 0.5)
                : _buildPlaceholder(context, opacity: 0.2),
          ),

          // Right Peeking Cover (2nd item if 3 items exist)
          Positioned(
            right: 0,
            child: items.length >= 3
                ? _buildSideCover(context, ref, items[1], opacity: 0.5)
                : items.length == 2
                    ? const SizedBox.shrink() // Already showing on left
                    : _buildPlaceholder(context, opacity: 0.2),
          ),

          // Primary Centered Cover (1st item)
          Positioned(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: items.isNotEmpty
                  ? _buildCoverImage(context, ref, items[0], primaryColor)
                  : _buildItemIcon(list.contentType == ListContentType.series, primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideCover(BuildContext context, WidgetRef ref, ReadingListItem item, {required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width * 0.85,
        height: height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: _buildCoverImage(context, ref, item, Theme.of(context).disabledColor),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, WidgetRef ref, ReadingListItem item, Color fallbackColor) {
    if (item.isSeries) {
      final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      final coverAsync = ref.watch(seriesCoverImageProvider((seriesId: id, allowRemoteFetch: true)));
      
      return coverAsync.when(
        data: (imageUrl) {
          if (imageUrl != null) {
            return _buildCachedImage(imageUrl, item.isSeries, fallbackColor);
          }
          return _buildItemIcon(item.isSeries, fallbackColor);
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, stack) => _buildItemIcon(item.isSeries, fallbackColor),
      );
    }

    final metadataAsync = ref.watch(readingListItemMetadataProvider((targetId: item.targetId, isSeries: item.isSeries)));

    return metadataAsync.when(
      data: (metadata) {
        String? imageUrl;
        if (metadata is IssueDetails) {
          imageUrl = metadata.image;
        }

        if (imageUrl != null) {
          return _buildCachedImage(imageUrl, item.isSeries, fallbackColor);
        }
        return _buildItemIcon(item.isSeries, fallbackColor);
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, stack) => _buildItemIcon(item.isSeries, fallbackColor),
    );
  }

  Widget _buildCachedImage(String imageUrl, bool isSeries, Color fallbackColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => _buildItemIcon(isSeries, fallbackColor),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {required double opacity}) {
    return Container(
      width: width * 0.85,
      height: height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: opacity), width: 1),
      ),
    );
  }

  Widget _buildItemIcon(bool isSeries, Color color) {
    return Center(
      child: Icon(
        isSeries ? Icons.collections : Icons.image,
        size: width * 0.4,
        color: color,
      ),
    );
  }
}
