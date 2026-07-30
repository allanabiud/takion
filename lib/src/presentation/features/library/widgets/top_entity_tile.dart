import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/shared/widgets/image_error_placeholder.dart';
import 'package:takion/src/presentation/features/library/providers/library_stats_models.dart';
import 'package:takion/src/domain/common/string_extensions.dart';

class _TopEntityImageArgs {
  const _TopEntityImageArgs({required this.entityType, required this.id});
  final String entityType;
  final int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TopEntityImageArgs &&
          entityType == other.entityType &&
          id == other.id;

  @override
  int get hashCode => entityType.hashCode ^ id.hashCode;
}

final _topEntityImageProvider = FutureProvider.autoDispose
    .family<String?, _TopEntityImageArgs>((ref, args) async {
      ref.watch(entityImageVersionProvider);
      final cache = ref.read(entityImageCacheProvider);
      final syncResult = cache.getCached(args.entityType, args.id);
      if (syncResult != null) return syncResult;
      final result = await cache.get(args.entityType, args.id);
      return result;
    });

class TopEntityTile extends ConsumerWidget {
  final int index;
  final EntityStat entity;
  final bool isCharacter;
  final bool isLast;

  const TopEntityTile({
    super.key,
    required this.index,
    required this.entity,
    required this.isCharacter,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final cacheKey = isCharacter ? 'character' : 'creator';
    final imageAsync = ref.watch(
      _topEntityImageProvider(
        _TopEntityImageArgs(entityType: cacheKey, id: entity.id),
      ),
    );
    final cachedImage = imageAsync.asData?.value;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (isCharacter) {
                context.pushRoute(
                  CharacterDetailsRoute(characterId: entity.id),
                );
              } else {
                context.pushRoute(CreatorDetailsRoute(creatorId: entity.id));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${index + 1}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: cachedImage != null
                          ? CachedNetworkImage(
                              imageUrl: cachedImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) =>
                                  _initialsAvatar(theme),
                              errorWidget: (context, url, error) =>
                                  imageErrorPlaceholder(
                                    context,
                                    url,
                                    error,
                                    label: initials(entity.name),
                                    iconSize: 16,
                                  ),
                            )
                          : _initialsAvatar(theme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${entity.count} ${entity.count == 1 ? 'issue' : 'issues'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  Widget _initialsAvatar(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials(entity.name),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
