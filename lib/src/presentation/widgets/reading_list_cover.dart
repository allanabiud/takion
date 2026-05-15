import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/providers/reading_list_item_metadata_provider.dart';

class ReadingListCover extends ConsumerWidget {
  final ReadingList list;
  final double width;
  final double height;

  const ReadingListCover({
    super.key,
    required this.list,
    this.width = 60,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // We always try to get the first item for the primary cover
    final firstItem = list.items.isNotEmpty ? list.items.first : null;
    final metadataAsync = firstItem != null 
        ? ref.watch(readingListItemMetadataProvider((targetId: firstItem.targetId, isSeries: firstItem.isSeries)))
        : null;

    return SizedBox(
      width: width + 20, 
      height: height + 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Left
          Positioned(
            left: 0,
            child: _buildPlaceholder(context, opacity: 0.3, rotation: -0.2),
          ),
          // Background Right
          Positioned(
            right: 0,
            child: _buildPlaceholder(context, opacity: 0.3, rotation: 0.2),
          ),
          // Primary Centered
          Positioned(
            child: Container(
              width: width,
              height: height + 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
              ),
              child: firstItem != null && metadataAsync != null
                  ? metadataAsync.when(
                      data: (metadata) {
                        String? imageUrl;
                        if (metadata is SeriesDetails) imageUrl = metadata.image;
                        else if (metadata is IssueDetails) imageUrl = metadata.image;

                        if (imageUrl != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
                          );
                        }
                        return _buildItemIcon(firstItem.isSeries, primaryColor);
                      },
                      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => _buildItemIcon(firstItem.isSeries, primaryColor),
                    )
                  : _buildItemIcon(list.contentType == ListContentType.series, primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {required double opacity, required double rotation}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width * 0.8,
        height: (height + 10) * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(6),
        ),
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
