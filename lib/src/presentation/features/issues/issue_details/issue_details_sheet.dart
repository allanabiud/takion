import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: (collectionStatus?.isCollected == true)
                              ? _StateActionButton(
                                  label: "Remove",
                                  icon: Icons.delete_outline,
                                  backgroundColor:
                                      theme.colorScheme.errorContainer,
                                  foregroundColor:
                                      theme.colorScheme.onErrorContainer,
                                  onPressed: onShowScrobbleSheet,
                                )
                              : (collectionStatus?.isWishlisted == true)
                              ? _StateActionButton(
                                  label: "Wishlisted",
                                  icon: Icons.turned_in,
                                  backgroundColor:
                                      theme.colorScheme.tertiaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onTertiaryContainer,
                                  onPressed: onShowScrobbleSheet,
                                )
                              : isInPullList
                              ? _StateActionButton(
                                  label: "Pulled",
                                  icon: Icons.shopping_bag,
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onSecondaryContainer,
                                  onPressed: onShowScrobbleSheet,
                                )
                              : _StateActionButton(
                                  label: "Add",
                                  icon: Icons.add,
                                  onPressed: onShowScrobbleSheet,
                                ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 1,
                          child: isFavorite
                              ? FilledButton(
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
                                      borderRadius: BorderRadius.circular(12),
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
                                      borderRadius: BorderRadius.circular(12),
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
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
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
                              child: const Icon(Icons.view_agenda_outlined),
                            ),
                          ),
                        ),
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

class _StateActionButton extends StatelessWidget {
  const _StateActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        minimumSize: const Size(0, 56),
        textStyle: theme.textTheme.titleMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}
