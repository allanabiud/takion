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

class UniverseCard extends ConsumerWidget {
  const UniverseCard({
    super.key,
    required this.universeId,
    required this.name,
    this.subtitle,
    this.width,
    this.onTap,
  });

  final int universeId;
  final String name;
  final String? subtitle;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final details = ref.watch(universeDetailsProvider(universeId));
    final imageUrl = details.whenOrNull(data: (d) => d.image);

    final effectiveOnTap =
        onTap ?? () => context.pushRoute(
          UniverseDetailsRoute(universeId: universeId),
        );

    Widget card = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: effectiveOnTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: width ?? 140,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                ),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Text(
                            _initials(name),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            _initials(name),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _initials(name),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
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
