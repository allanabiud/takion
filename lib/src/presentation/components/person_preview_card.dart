import 'package:flutter/material.dart';

class PersonPreviewCard extends StatelessWidget {
  const PersonPreviewCard({
    super.key,
    required this.name,
    this.subtitle,
    this.placeholderIcon = Icons.person_outline,
    this.imageUrl,
    this.onTap,
    this.width,
  });

  final String name;
  final String? subtitle;
  final IconData placeholderIcon;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    Widget card = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          placeholderIcon,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    )
                  : Icon(
                      placeholderIcon,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
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
                textAlign: TextAlign.start,
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
              textAlign: TextAlign.start,
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
