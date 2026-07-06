import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_cached_metadata_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_list_item_metadata_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

class ReadingListCover extends ConsumerWidget {
  final ReadingList list;
  final double width;
  final double height;
  final double peekOffset;
  final bool allowRemoteCoverFetch;

  const ReadingListCover({
    super.key,
    required this.list,
    this.width = 60,
    this.height = 85,
    this.peekOffset = 14,
    this.allowRemoteCoverFetch = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final listInitials = initials(list.title);

    ref.watch(entityImageVersionProvider);

    final items = list.items.take(3).toList();
    final horizontalOffset = peekOffset;
    final totalWidth = width + (horizontalOffset * 2);

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: items.length >= 2
                ? _buildSideCover(
                    context, ref, items[items.length >= 3 ? 2 : 1], listInitials)
                : _buildPlaceholder(context, listInitials),
          ),
          Positioned(
            right: 0,
            child: items.length >= 3
                ? _buildSideCover(context, ref, items[1], listInitials)
                : items.length == 2
                ? const SizedBox.shrink()
                : _buildPlaceholder(context, listInitials),
          ),
          Positioned(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: items.isNotEmpty
                  ? _buildCoverImage(context, ref, items[0], listInitials)
                  : _buildItemIcon(context, listInitials),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideCover(
    BuildContext context,
    WidgetRef ref,
    ReadingListItem item,
    String listInitials,
  ) {
    return Container(
      width: width * 0.85,
      height: height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: _buildCoverImage(context, ref, item, listInitials),
    );
  }

  String? _coverImageFromCache(WidgetRef ref, ReadingListItem item) {
    final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (id <= 0) return null;
    final cache = ref.read(entityImageCacheProvider);
    final type = item.isSeries ? 'series' : 'issue';
    return cache.getCached(type, id);
  }

  String? _cachedItemImageUrl(WidgetRef ref, ReadingListItem item) {
    final cachedAsync = ref.watch(
      readingListItemCachedMetadataProvider((
        targetId: item.targetId,
        isSeries: item.isSeries,
      )),
    );
    final cached = cachedAsync.asData?.value;
    if (cached is IssueDetails) {
      final image = cached.image?.trim();
      if (image != null && image.isNotEmpty) return image;
    }
    if (cached is SeriesDetails) {
      final image = cached.image?.trim();
      if (image != null && image.isNotEmpty) return image;
    }
    return null;
  }

  Widget _buildCoverImage(
    BuildContext context,
    WidgetRef ref,
    ReadingListItem item,
    String listInitials,
  ) {
    final cachedImage = _coverImageFromCache(ref, item);
    if (cachedImage != null && cachedImage.isNotEmpty) {
      return _buildCachedImage(context, cachedImage);
    }

    final cachedImageUrl = _cachedItemImageUrl(ref, item);
    if (cachedImageUrl != null) {
      return _buildCachedImage(context, cachedImageUrl);
    }

    if (item.isSeries) {
      final id = int.tryParse(item.targetId.replaceAll(RegExp(r'\D'), '')) ?? 0;
      final coverAsync = ref.watch(
        seriesCoverImageProvider((
          seriesId: id,
          allowRemoteFetch: allowRemoteCoverFetch,
        )),
      );

      return coverAsync.when(
        data: (imageUrl) {
          if (imageUrl != null) {
            return _buildCachedImage(context, imageUrl);
          }
          return _buildItemIcon(context, listInitials);
        },
        loading: () =>
            _buildItemIcon(context, listInitials),
        error: (_, _) =>
            _buildItemIcon(context, listInitials),
      );
    }

    if (!allowRemoteCoverFetch) {
      return _buildItemIcon(context, listInitials);
    }

    final metadataAsync = ref.watch(
      readingListItemMetadataProvider((
        targetId: item.targetId,
        isSeries: item.isSeries,
      )),
    );

    return metadataAsync.when(
      data: (metadata) {
        String? imageUrl;
        if (metadata is IssueDetails) {
          imageUrl = metadata.image;
        }
        if (imageUrl != null) {
          return _buildCachedImage(context, imageUrl);
        }
        return _buildItemIcon(context, listInitials);
      },
      loading: () =>
          _buildItemIcon(context, listInitials),
      error: (_, _) =>
          _buildItemIcon(context, listInitials),
    );
  }

  Widget _buildCachedImage(BuildContext context, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) =>
            _buildItemIcon(context, ''),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String listInitials) {
    return Container(
      width: width * 0.85,
      height: height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Center(
        child: Text(
          listInitials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: width * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemIcon(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
      child: Center(
        child: label.isNotEmpty
            ? Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: width * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.image,
                size: width * 0.4,
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }
}
