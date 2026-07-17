import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/components/image_error_placeholder.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

class ImprintCard extends ConsumerWidget {
  const ImprintCard({
    super.key,
    required this.imprintId,
    required this.name,
    this.imageUrl,
    this.publisherName,
    this.width = 240,
    this.height = 80,
  });

  final int imprintId;
  final String name;
  final String? imageUrl;
  final String? publisherName;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedImage = cache.getCached('imprint', imprintId);
    final effectiveImageUrl = imageUrl ?? cachedImage;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushRoute(ImprintDetailsRoute(imprintId: imprintId)),
          child: Row(
            children: [
              Container(
                width: height,
                height: height,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                child: effectiveImageUrl != null && effectiveImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: effectiveImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => imageErrorPlaceholder(
                          context,
                          url,
                          error,
                          label: initials(name),
                          iconSize: 20,
                        ),
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _buildInitials(theme),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (publisherName != null && publisherName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          publisherName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeData theme) {
    return Center(
      child: Text(
        initials(name),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
