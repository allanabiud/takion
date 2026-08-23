import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class SeriesSubscriptionCard extends ConsumerWidget {
  final SeriesList series;
  final VoidCallback? onTap;

  const SeriesSubscriptionCard({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardDataAsync = ref.watch(subscriptionSeriesCardProvider(series.id));
    final mostRecentImage = cardDataAsync.value?.mostRecentIssueImage;
    final nextIssueDate = cardDataAsync.value?.nextIssueDate;
    final displayName =
        (cardDataAsync.value?.seriesName?.trim().isNotEmpty ?? false)
        ? cardDataAsync.value!.seriesName!
        : series.name;

    final effectiveOnTap =
        onTap ??
        () => context.pushRoute(SeriesDetailsRoute(seriesId: series.id));

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: effectiveOnTap,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rawWidth =
                constraints.maxWidth * MediaQuery.of(context).devicePixelRatio;
            final cacheWidth = rawWidth > 0
                ? ((rawWidth / 50).ceil() * 50)
                : null;
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(theme, mostRecentImage, cacheWidth, displayName),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                if (nextIssueDate != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _NextReleaseBadge(date: nextIssueDate),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCover(
    ThemeData theme,
    String? mostRecentImage,
    int? cacheWidth,
    String displayName,
  ) {
    final hasImage = mostRecentImage != null && mostRecentImage.isNotEmpty;
    final validCacheWidth = (cacheWidth != null && cacheWidth > 0)
        ? cacheWidth
        : null;
    return Positioned.fill(
      child: EntityCover(
        imageUrl: hasImage ? mostRecentImage : null,
        placeholderLabel: initials(displayName),
        alignment: Alignment.topCenter,
        cacheWidth: validCacheWidth,
        borderRadius: 0,
        iconSize: 28,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }
}

class _NextReleaseBadge extends StatelessWidget {
  final DateTime date;

  const _NextReleaseBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: Text(
              "NEXT",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 8,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.monthAbbrev(date).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
                Text(
                  "${date.day}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
