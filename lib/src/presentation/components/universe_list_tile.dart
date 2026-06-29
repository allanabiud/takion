import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_details_provider.dart';

String _initials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'[\s\-\/]+'));
  final valid = parts.where((p) => p.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(p)).toList();
  if (valid.isEmpty) return '?';
  if (valid.length >= 2) {
    return '${valid[0][0]}${valid[1][0]}'.toUpperCase();
  }
  return valid[0][0].toUpperCase();
}

class UniverseListTile extends ConsumerWidget {
  final int universeId;
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final double horizontalPadding;

  const UniverseListTile({
    super.key,
    required this.universeId,
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
    final theme = Theme.of(context);
    final details = ref.watch(universeDetailsProvider(universeId));
    final detailsImage = details.whenOrNull(data: (d) => d.image);
    final effectiveImageUrl = imageUrl ?? detailsImage;

    final effectiveOnTap =
        onTap ??
        () => context.pushRoute(UniverseDetailsRoute(universeId: universeId));

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: isFirst ? 12 : 2,
        bottom: isLast ? 12 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: effectiveOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                    ),
                    child: effectiveImageUrl != null &&
                            effectiveImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: effectiveImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _initialsAvatar(theme),
                            errorWidget: (context, url, error) =>
                                _initialsAvatar(theme),
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
    );
  }

  Widget _initialsAvatar(ThemeData theme) {
    return Container(
      width: 80,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
