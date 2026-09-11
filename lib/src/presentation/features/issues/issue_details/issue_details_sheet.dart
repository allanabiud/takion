import "dart:ui";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart";
import "package:takion/src/presentation/features/issues/issue_details/issue_about_content.dart";

class IssueDetailsSheet extends StatelessWidget {
  const IssueDetailsSheet({
    super.key,
    required this.scrollController,
    required this.issue,
    required this.issueId,
    required this.collectionStatus,
    required this.isInPullList,
    required this.isFavorite,
    required this.displayTitle,
    required this.onShowScrobbleSheet,
    required this.onToggleFavorite,
    required this.onNavigateToSeries,
    this.seriesId,
    this.isSubscribed,
    this.onToggleSeriesSubscription,
    this.onAcquire,
  });

  final ScrollController scrollController;
  final IssueDetails issue;
  final int issueId;
  final IssueCollectionStatus? collectionStatus;
  final bool isInPullList;
  final bool isFavorite;
  final String displayTitle;
  final VoidCallback onShowScrobbleSheet;
  final VoidCallback onToggleFavorite;
  final VoidCallback onNavigateToSeries;
  final int? seriesId;
  final bool? isSubscribed;
  final VoidCallback? onToggleSeriesSubscription;
  final VoidCallback? onAcquire;

  Widget _buildTitleSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final publisher = issue.publisher;
    final dateToShow = issue.storeDate ?? issue.coverDate;
    final formattedDate = dateToShow != null
        ? DateFormatter.comicDate(dateToShow)
        : null;

    return Row(
      children: [
        if (publisher != null)
          GestureDetector(
            onTap: () => context.pushRoute(
              PublisherDetailsRoute(publisherId: publisher.id),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  publisher.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        const Spacer(),
        if (formattedDate != null)
          Text(
            formattedDate,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingValue = (collectionStatus?.rating ?? 0).clamp(0, 5);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTitleSubtitle(context),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          (collectionStatus?.isCollected ?? false)
                              ? Icons.inventory_2
                              : Icons.inventory_2_outlined,
                          size: 22,
                          color: (collectionStatus?.isCollected ?? false)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          (collectionStatus?.isRead ?? false)
                              ? Icons.bookmark_added
                              : Icons.bookmark_added_outlined,
                          size: 22,
                          color: (collectionStatus?.isRead ?? false)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          isInPullList
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          size: 22,
                          color: isInPullList
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          (collectionStatus?.isWishlisted ?? false)
                              ? Icons.turned_in
                              : Icons.turned_in_not,
                          size: 22,
                          color: (collectionStatus?.isWishlisted ?? false)
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const Spacer(),
                        ...List.generate(5, (index) {
                          final isFilled = index < ratingValue;
                          return Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Icon(
                              isFilled ? Icons.star : Icons.star_border,
                              size: 22,
                              color: isFilled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _SpringMorphingStateButton(
                                isCollected:
                                    collectionStatus?.isCollected ?? false,
                                isWishlisted:
                                    collectionStatus?.isWishlisted ?? false,
                                isInPullList: isInPullList,
                                onPressed: onShowScrobbleSheet,
                              ),
                            ),
                            if (onAcquire != null &&
                                (collectionStatus?.isWishlisted ?? false) &&
                                !(collectionStatus?.isCollected ?? false)) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 1,
                                child: Tooltip(
                                  message: "Acquire to collection",
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      iconSize: 28,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: onAcquire,
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: isFavorite
                                  ? FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primaryContainer,
                                        foregroundColor: theme
                                            .colorScheme.onPrimaryContainer,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        iconSize: 28,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: onToggleFavorite,
                                      child: const Icon(Icons.favorite),
                                    )
                                  : FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        iconSize: 28,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: onToggleFavorite,
                                      child: const Icon(Icons.favorite_border),
                                    ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                message: "Go to series",
                                child: FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHigh,
                                    foregroundColor:
                                        theme.colorScheme.onSurfaceVariant,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    iconSize: 28,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: seriesId != null
                                      ? onNavigateToSeries
                                      : null,
                                  child: const Icon(
                                    Icons.view_agenda_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IssueAboutContent(issue: issue, issueId: issueId),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpringMorphingStateButton extends StatelessWidget {
  const _SpringMorphingStateButton({
    required this.isCollected,
    required this.isWishlisted,
    required this.isInPullList,
    required this.onPressed,
  });

  final bool isCollected;
  final bool isWishlisted;
  final bool isInPullList;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, icon, bgColor, fgColor) = isCollected
        ? (
            "Remove",
            Icons.delete_outline,
            theme.colorScheme.errorContainer,
            theme.colorScheme.onErrorContainer,
          )
        : isWishlisted
        ? (
            "Wishlisted",
            Icons.turned_in,
            theme.colorScheme.tertiaryContainer,
            theme.colorScheme.onTertiaryContainer,
          )
        : isInPullList
        ? (
            "Pulled",
            Icons.shopping_bag,
            theme.colorScheme.secondaryContainer,
            theme.colorScheme.onSecondaryContainer,
          )
        : (
            "Add",
            Icons.add,
            null,
            null,
          );

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: theme.colorScheme.surfaceContainerHighest,
        end: bgColor ?? theme.colorScheme.primaryContainer,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      builder: (context, animatedBg, child) {
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: theme.colorScheme.onSurface,
            end: fgColor ?? theme.colorScheme.onPrimaryContainer,
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          builder: (context, animatedFg, child) {
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: animatedBg,
                foregroundColor: animatedFg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                minimumSize: const Size(0, 56),
                textStyle: theme.textTheme.titleMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                onPressed?.call();
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Row(
                  key: ValueKey("$label-$icon"),
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
