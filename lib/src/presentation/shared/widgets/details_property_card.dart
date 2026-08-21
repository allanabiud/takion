import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

/// A single property item inside a [DetailsPropertyCard].
class DetailPropertyItem {
  const DetailPropertyItem({
    required this.label,
    this.value,
    this.badge,
    this.icon,
    this.onTap,
    this.trailing,
    this.copyableValue,
  });

  final String label;
  final String? value;
  final Widget? badge;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? copyableValue;
}

/// A structured 2-column key-value card with visual dividers and clean hierarchy.
class DetailsPropertyCard extends StatelessWidget {
  const DetailsPropertyCard({
    super.key,
    this.title = "DETAILS",
    required this.items,
    this.headerAction,
  });

  final String? title;
  final List<DetailPropertyItem> items;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final validItems = items
        .where(
          (item) =>
              item.badge != null ||
              (item.value != null && item.value!.trim().isNotEmpty),
        )
        .toList();

    if (validItems.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          if (headerAction != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionHeader(title: title!),
                headerAction!,
              ],
            )
          else
            SectionHeader(title: title!),
          const SizedBox(height: 4),
        ],
        for (int i = 0; i < validItems.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          _PropertyRow(item: validItems[i]),
        ],
      ],
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({required this.item});

  final DetailPropertyItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: item.badge ??
                  Text(
                    item.value ?? "",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
          if (item.trailing != null) ...[
            const SizedBox(width: 6),
            item.trailing!,
          ] else if (item.onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ] else if (item.copyableValue != null) ...[
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.copyableValue!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Copied ${item.label} to clipboard"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.copy_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (item.onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: item.onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Visual status badge with a color-coded dot indicator.
class PublicationStatusBadge extends StatelessWidget {
  const PublicationStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.trim().toLowerCase();
    Color dotColor;
    Color bgColor;

    if (lower.contains("ongoing") || lower.contains("active")) {
      dotColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.12);
    } else if (lower.contains("completed") || lower.contains("ended")) {
      dotColor = const Color(0xFF1565C0);
      bgColor = const Color(0xFF1565C0).withValues(alpha: 0.12);
    } else if (lower.contains("cancelled") || lower.contains("canceled")) {
      dotColor = const Color(0xFFC62828);
      bgColor = const Color(0xFFC62828).withValues(alpha: 0.12);
    } else if (lower.contains("one-shot") || lower.contains("oneshot") || lower.contains("limited")) {
      dotColor = const Color(0xFF6A1B9A);
      bgColor = const Color(0xFF6A1B9A).withValues(alpha: 0.12);
    } else {
      dotColor = Theme.of(context).colorScheme.primary;
      bgColor = dotColor.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual age rating badge.
class ContentRatingBadge extends StatelessWidget {
  const ContentRatingBadge({super.key, required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lower = rating.toLowerCase();

    Color color;
    if (lower.contains("mature") || lower.contains("18+") || lower.contains("explicit")) {
      color = const Color(0xFFD32F2F);
    } else if (lower.contains("teen") || lower.contains("13+") || lower.contains("12+")) {
      color = const Color(0xFFE65100);
    } else if (lower.contains("all") || lower.contains("everyone") || lower.contains("kids")) {
      color = const Color(0xFF2E7D32);
    } else {
      color = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        rating,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Visual format / tag badge.
class FormatBadge extends StatelessWidget {
  const FormatBadge({super.key, required this.format});

  final String format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        format,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
