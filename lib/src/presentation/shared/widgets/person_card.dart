import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/shared/widgets/smart_entity_image.dart';

class PersonCard extends ConsumerWidget {
  const PersonCard({
    super.key,
    this.characterId,
    this.creatorId,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.width,
    this.isFavorite = false,
  });

  final int? characterId;
  final int? creatorId;
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double? width;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    final hasCharacterId = characterId != null;
    final hasCreatorId = creatorId != null;
    final entityType = hasCharacterId ? 'character' : (hasCreatorId ? 'creator' : null);
    final entityId = characterId ?? creatorId;

    final isFav =
        isFavorite ||
        (hasCharacterId
            ? ref
                      .watch(isCharacterFavoriteProvider(characterId!))
                      .asData
                      ?.value ??
                  false
            : hasCreatorId
            ? ref.watch(isCreatorFavoriteProvider(creatorId!)).asData?.value ??
                  false
            : false);

    final effectiveOnTap =
        onTap ??
        (hasCharacterId
            ? () => context.pushRoute(
                CharacterDetailsRoute(characterId: characterId!),
              )
            : hasCreatorId
            ? () =>
                  context.pushRoute(CreatorDetailsRoute(creatorId: creatorId!))
            : null);

    Widget card = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: effectiveOnTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                SmartEntityImage(
                  entityType: entityType,
                  entityId: entityId,
                  name: name,
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  isCircle: true,
                ),
                if (isFav)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 13,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (hasSubtitle) ...[
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
            ],
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      card = SizedBox(width: width, child: card);
    }

    return card;
  }
}
