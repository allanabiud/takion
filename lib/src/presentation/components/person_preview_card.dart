import 'package:flutter/material.dart';

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

class PersonPreviewCard extends StatelessWidget {
  const PersonPreviewCard({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.width,
  });

  final String name;
  final String? subtitle;
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
                        errorBuilder: (_, _, _) => Center(
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
