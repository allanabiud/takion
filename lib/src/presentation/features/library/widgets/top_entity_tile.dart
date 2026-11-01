import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/shared/widgets/animated_counter_text.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

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

    final cachedImage = isCharacter
        ? ref.watch(characterImageStreamProvider(entity.id)).asData?.value
        : ref.watch(creatorImageStreamProvider(entity.id)).asData?.value;

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
                      "${index + 1}.",
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
                      child: EntityCover(
                        imageUrl: cachedImage,
                        placeholderLabel: initials(entity.name),
                        width: 44,
                        height: 44,
                        borderRadius: 0,
                        aspectRatio: 1,
                        iconSize: 16,
                        circular: true,
                        alignment: Alignment.topCenter,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                      ),
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
                        AnimatedCounterText(
                          value: entity.count,
                          suffix: entity.count == 1 ? " issue" : " issues",
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
}
