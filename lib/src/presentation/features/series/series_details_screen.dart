import "package:auto_route/auto_route.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/issue_card.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";
import "package:takion/src/presentation/features/series/providers/series_cover_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart";
import "package:takion/src/presentation/features/series/widgets/series_associated_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_genres_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_info_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_more_options_sheet.dart";
import "package:takion/src/presentation/features/series/widgets/series_progress_cards.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/favorite_toggle_actions.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";

@RoutePage()
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({
    super.key,
    @pathParam required this.seriesId,
    this.initialImageUrl,
  });

  final int seriesId;
  final String? initialImageUrl;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen>
    with
        ResourceUrlActions<SeriesDetails>,
        FavoriteToggleActions,
        DetailRefreshActions<SeriesDetails> {
  @override
  String? resourceUrlOf(SeriesDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "series";

  @override
  String shareSubjectOf(SeriesDetails details) => details.name;

  @override
  String get entityLabel => "Series";

  @override
  Future<SeriesDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getSeriesDetails(widget.seriesId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(seriesDetailsProvider(widget.seriesId));
    ref.invalidate(seriesFullDetailsProvider(widget.seriesId));
    ref.invalidate(seriesIssueListProvider);
  }

  bool _isUpdatingSubscription = false;

  Future<void> _setSeriesSubscription(bool enabled) async {
    if (_isUpdatingSubscription) return;
    setState(() {
      _isUpdatingSubscription = true;
    });
    try {
      final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
      if (enabled) {
        await subscriptionRepository.subscribe(metronSeriesId: widget.seriesId);
      } else {
        await subscriptionRepository.unsubscribe(widget.seriesId);
        await ref
            .read(pullListRepositoryProvider)
            .deleteEntriesBySeriesId(widget.seriesId);
      }
      // Subscription activity events intentionally not recorded
      if (enabled) {
        await ref
            .read(subscriptionPullReconcilerProvider)
            .reconcile(force: true, onlySeriesId: widget.seriesId);
      }
      if (mounted) {
        (enabled ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          enabled ? "Subscribed" : "Unsubscribed",
          icon: Icons.notifications,
          actionLabel: "Undo",
          onUndo: () async {
            if (enabled) {
              await subscriptionRepository.unsubscribe(widget.seriesId);
              await ref
                  .read(pullListRepositoryProvider)
                  .deleteEntriesBySeriesId(widget.seriesId);
            } else {
              await subscriptionRepository.subscribe(
                metronSeriesId: widget.seriesId,
              );
            }
          },
        );
      }
    } catch (error) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to update subscription");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSubscription = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() {
    return toggleFavoriteWithUndo(
      context,
      isFavorite: ref.read(isSeriesFavoriteProvider(widget.seriesId).future),
      toggle: () async {
        final repository = ref.read(favoritesRepositoryProvider);
        await repository.toggleSeriesFavorite(widget.seriesId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesFullDetailsProvider(widget.seriesId));
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider(widget.seriesId),
    );
    final issuesPreviewAsync = ref.watch(
      seriesDetailsIssuesProvider(widget.seriesId),
    );
    final subscriptionAsync = ref.watch(
      seriesSubscriptionProvider(widget.seriesId),
    );
    final isFavoriteAsync = ref.watch(
      isSeriesFavoriteProvider(widget.seriesId),
    );

    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final isSubscriptionLoading =
        subscriptionAsync.isLoading || _isUpdatingSubscription;
    final isFavorite = isFavoriteAsync.asData?.value ?? false;
    final isIssuesLoading = issuesPreviewAsync.isLoading;
    final issuesPreview = issuesPreviewAsync.asData != null
        ? sortIssues(
            issuesPreviewAsync.asData!.value.results,
            ContentSortOption.dateNewest,
          ).take(10).toList()
        : <IssueList>[];
    final totalIssueCount = issuesPreviewAsync.asData?.value.count ?? 0;

    return DetailScreenShell<SeriesDetails>(
      asyncValue: detailsAsync,
      loadingImageUrl: widget.initialImageUrl,
      entityType: "series",
      initialChildSize: 0.60,
      headerHeight: 350,
      showHero: false,
      toImageUrl: (d) => null,
      toHeroTag: (d) => "series-${d.id}",
      toTitle: (d) => '${d.name.toUpperCase()} (${d.yearBegan ?? ''})',
      toHeaderExtra: (d) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.publisher != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.pushRoute(
                    PublisherDetailsRoute(publisherId: d.publisher!.id),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.publisher!.name,
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
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    style: isSubscribed
                        ? FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: theme.textTheme.titleMedium,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                        : FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: theme.textTheme.titleMedium,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                    onPressed: isSubscriptionLoading
                        ? null
                        : () => _setSeriesSubscription(!isSubscribed),
                    child: isSubscriptionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSubscribed
                                    ? Icons.notifications_active
                                    : Icons.notifications_outlined,
                                size: 26,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isSubscribed ? "Unsubscribe" : "Subscribe",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 1,
                  child: isFavorite
                      ? FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            iconSize: 28,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _toggleFavorite,
                          child: const Icon(Icons.favorite),
                        )
                      : FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            iconSize: 28,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _toggleFavorite,
                          child: const Icon(Icons.favorite_border),
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 1,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      iconSize: 28,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => showSeriesMoreOptionsSheet(
                      context,
                      ref,
                      widget.seriesId,
                      seriesName: d.name,
                      seriesYear: d.yearBegan,
                    ),
                    child: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
            if (d.issueCount != null && d.issueCount! > 0) ...[
              const SizedBox(height: 12),
              const SectionHeader(title: "PROGRESS"),
              const SizedBox(height: 8),
              SeriesProgressCards(seriesId: d.id, total: d.issueCount!),
            ],
          ],
        );
      },
      onRefresh: (_) => refreshDetails(context),
      onRetry: () => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      headerBackground: (context, d) => [
        coverImageAsync.when(
          data: (imageUrl) => imageUrl != null
              ? Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Theme.of(context).colorScheme.surface),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Icon(Icons.image_outlined, size: 40),
                ),
          loading: () =>
              Container(color: Theme.of(context).colorScheme.surface),
          error: (_, _) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Icon(Icons.error_outline),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                  Colors.transparent,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
      sheetContentBuilder: (context, d, ref) {
        final description = d.description?.trim();
        final showDescription = description != null && description.isNotEmpty;
        final associated = d.associated
            .where((entry) => entry.series.trim().isNotEmpty)
            .toList();
        final showAssociated = associated.isNotEmpty;

        return [
          if (showDescription) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpandableDescription(description: description),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: (isIssuesLoading || issuesPreviewAsync.hasError)
                        ? "Issues"
                        : '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
                    onViewAll: (isIssuesLoading || issuesPreviewAsync.hasError)
                        ? null
                        : () => context.pushRoute(
                            SeriesIssuesRoute(seriesId: widget.seriesId),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (isIssuesLoading)
                    SizedBox(
                      height: 256,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: 6,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, _) =>
                            const ShimmerWidget(child: IssueCardSkeleton()),
                      ),
                    )
                  else if (issuesPreviewAsync.hasError)
                    SizedBox(
                      height: 220,
                      child: AsyncStatePanel.error(
                        errorMessage: "Failed to load issues",
                        onRetry: () => ref.invalidate(
                          seriesDetailsIssuesProvider(widget.seriesId),
                        ),
                      ),
                    )
                  else
                    HorizontalPreviewSection(
                      title: "",
                      onViewAll: null,
                      itemCount: issuesPreview.length,
                      height: 256,
                      emptyText: "No issues available.",
                      itemBuilder: (context, index) {
                        final issue = issuesPreview[index];
                        final issueId = issue.id;
                        return IssueCard(
                          issueId: issueId,
                          imageUrl: issue.image,
                          title:
                              "${issue.series?.name ?? issue.name} #${issue.number}",
                          seriesId: issue.series?.id,
                          seriesName: issue.series?.name,
                          issueNumber: issue.number,
                          onTap: issueId == null
                              ? null
                              : () {
                                  context.pushRoute(
                                    IssueDetailsRoute(
                                      issueId: issueId,
                                      initialImageUrl: issue.image,
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SeriesInfoCard(details: d),
            ),
          ),
          if (showAssociated) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SeriesAssociatedCard(associated: associated),
              ),
            ),
          ],
          if (d.genres.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SeriesGenresCard(genres: d.genres),
              ),
            ),
          ],
          ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DatabaseIdsSection(
                  metronId: d.id,
                  comicVineId: d.cvId,
                  gcdId: d.gcdId,
                  modifiedAt: d.modified,
                ),
              ),
            ),
          ],
        ];
      },
    );
  }
}
