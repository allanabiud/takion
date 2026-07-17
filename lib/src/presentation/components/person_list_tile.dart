import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/components/image_error_placeholder.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

class PersonListTile extends ConsumerWidget {
  final int? characterId;
  final int? creatorId;
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final double horizontalPadding;

  const PersonListTile({
    super.key,
    this.characterId,
    this.creatorId,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCharacterId = characterId != null;
    final hasCreatorId = creatorId != null;
    final theme = Theme.of(context);

    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedCharImage = characterId != null
        ? cache.getCached('character', characterId!)
        : null;
    final cachedCreatorImage = creatorId != null
        ? cache.getCached('creator', creatorId!)
        : null;
    final effectiveImageUrl = imageUrl ?? cachedCharImage ?? cachedCreatorImage;

    final isFav = hasCharacterId
        ? ref.watch(isCharacterFavoriteProvider(characterId!)).asData?.value ??
            false
        : hasCreatorId
            ? ref.watch(isCreatorFavoriteProvider(creatorId!)).asData?.value ??
                false
            : false;

    final effectiveOnTap =
        onTap ??
        (hasCharacterId
            ? () => context.pushRoute(
                  CharacterDetailsRoute(characterId: characterId!),
                )
            : hasCreatorId
                ? () => context.pushRoute(
                      CreatorDetailsRoute(creatorId: creatorId!),
                    )
                : null);

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: isFirst ? 12 : 2,
        bottom: isLast ? 12 : 0,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: effectiveOnTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: effectiveImageUrl != null &&
                                    effectiveImageUrl.isNotEmpty
                                 ? CachedNetworkImage(
                                     imageUrl: effectiveImageUrl,
                                     fit: BoxFit.cover,
                                     placeholder: (context, url) =>
                                         _initialsAvatar(theme),
                                     errorWidget: (context, url, error) =>
                                         imageErrorPlaceholder(
                                           context,
                                           url,
                                           error,
                                           label: initials(name),
                                           iconSize: 22,
                                         ),
                                   )
                                : _initialsAvatar(theme),
                          ),
                        ),
                        if (isFav)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null &&
                              subtitle!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials(name),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
