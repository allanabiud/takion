import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_completion_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_local_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/features/series/series_issues_screen.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
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
          enabled ? 'Subscribed' : 'Unsubscribed',
          icon: Icons.notifications,
          actionLabel: 'Undo',
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
        TakionAlerts.error(context, 'Failed to update subscription');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSubscription = false;
        });
      }
    }
  }

  Uri? _resourceUri(SeriesDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'series');
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'series');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'series');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isSeriesFavoriteProvider(widget.seriesId).future,
      );

      await repository.toggleSeriesFavorite(widget.seriesId);

      if (mounted) {
        final added = !isFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await repository.toggleSeriesFavorite(widget.seriesId);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favourites');
      }
    }
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
      entityType: 'series',
      initialChildSize: 0.60,
      headerHeight: 350,
      showHero: false,
      toImageUrl: (d) => null,
      toHeroTag: (d) => 'series-${d.id}',
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
                                  isSubscribed ? 'Unsubscribe' : 'Subscribe',
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
                    onPressed: () => _showSeriesMoreOptionsSheet(
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
              const SectionHeader(title: 'PROGRESS'),
              const SizedBox(height: 8),
              _SeriesProgressCards(seriesId: d.id, total: d.issueCount!),
            ],
          ],
        );
      },
      onRefresh: (d) async {
        try {
          final newSeries = await ref
              .read(catalogRepositoryProvider)
              .getSeriesDetails(d.id, forceRefresh: true);
          final currentSeries = ref
              .read(seriesDetailsProvider(d.id))
              .asData
              ?.value;
          if (currentSeries != newSeries) {
            ref.invalidate(seriesDetailsProvider(d.id));
            ref.invalidate(seriesFullDetailsProvider(d.id));
          }
          if (context.mounted) {
            TakionAlerts.success(context, 'Series details refreshed');
          }
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.error(context, 'Failed to refresh series details');
          }
        }
      },
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
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

        Widget buildIdsSection(BuildContext context) {
          final theme = Theme.of(context);
          final entries = <Widget>[];
          void addEntry(String label, String value) {
            entries.add(
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '$label $value',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          addEntry('Metron', '${d.id}');
          if (d.cvId != null) addEntry('CV', '${d.cvId}');
          if (d.gcdId != null) addEntry('GCD', '${d.gcdId}');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'DATABASE IDS'),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: entries),
            ],
          );
        }

        String? modifiedValue(DateTime? modified) {
          if (modified == null) return null;
          return DateFormatter.isoDateTime(modified);
        }

        return [
          if (showDescription) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpandableDescription(description: description),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: isIssuesLoading
                        ? 'Issues'
                        : '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
                    onViewAll: isIssuesLoading
                        ? null
                        : () => context.pushRoute(
                            SeriesIssuesRoute(seriesId: widget.seriesId),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (isIssuesLoading)
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: 6,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, _) =>
                            const ShimmerWidget(child: IssueCardSkeleton()),
                      ),
                    )
                  else
                    HorizontalPreviewSection(
                      title: '',
                      onViewAll: null,
                      itemCount: issuesPreview.length,
                      height: 250,
                      emptyText: 'No issues available.',
                      itemBuilder: (context, index) {
                        final issue = issuesPreview[index];
                        final issueId = issue.id;
                        return IssueCard(
                          issueId: issueId,
                          imageUrl: issue.image,
                          title:
                              '${issue.series?.name ?? issue.name} #${issue.number}',
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
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SeriesInfoCard(details: d),
            ),
          ),
          if (showAssociated) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SeriesAssociatedCard(associated: associated),
              ),
            ),
          ],
          if (d.genres.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SeriesGenresCard(genres: d.genres),
              ),
            ),
          ],
          ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buildIdsSection(context),
              ),
            ),
          ],
          if (modifiedValue(d.modified) != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Last modified: ${modifiedValue(d.modified)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ];
      },
    );
  }
}

class _SeriesAssociatedCard extends StatelessWidget {
  const _SeriesAssociatedCard({required this.associated});

  final List<SeriesDetailsAssociated> associated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ASSOCIATED SERIES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: associated.map((entry) {
            final chipWidth = MediaQuery.of(context).size.width - 48;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: chipWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.pushRoute(SeriesDetailsRoute(seriesId: entry.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              entry.series,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SeriesGenresCard extends StatelessWidget {
  const _SeriesGenresCard({required this.genres});

  final List<dynamic> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GENRES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(
                    genre.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SeriesInfoCard extends StatelessWidget {
  const _SeriesInfoCard({required this.details});

  final SeriesDetails details;

  @override
  Widget build(BuildContext context) {
    final start = details.yearBegan;
    final end = details.yearEnd;
    final years = (start == null && end == null)
        ? null
        : (start != null && end != null)
        ? '$start - $end'
        : (start != null)
        ? '$start - Present'
        : 'Until $end';

    final contentItems = <InfoGridItem>[
      if (details.seriesType?.name != null)
        InfoGridItem(label: 'Type', value: details.seriesType!.name),
      if (details.status != null)
        InfoGridItem(label: 'Status', value: details.status!),
      if (details.volume != null)
        InfoGridItem(label: 'Volume', value: '${details.volume}'),
      if (years != null) InfoGridItem(label: 'Years', value: years),
      if (details.issueCount != null)
        InfoGridItem(label: 'Issues', value: '${details.issueCount}'),
      if (details.imprint?.name != null &&
          details.imprint!.name.trim().isNotEmpty)
        InfoGridItem(label: 'Imprint', value: details.imprint!.name.trim()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DETAILS'),
        const SizedBox(height: 12),
        InfoGrid(items: contentItems),
      ],
    );
  }
}

void _showSeriesMoreOptionsSheet(
  BuildContext context,
  WidgetRef ref,
  int seriesId, {
  String seriesName = '',
  int? seriesYear,
}) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'More Options',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to Reading List'),
          onTap: () {
            Navigator.of(context).pop();
            AddToLocalReadingListBottomSheet.show(
              context: context,
              targetId: 'series-$seriesId',
              isSeries: true,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add_check_rounded),
          title: const Text('Bulk Series Actions'),
          onTap: () {
            Navigator.of(context).pop();
            showSeriesIssueBulkActionsSheet(
              context: context,
              ref: ref,
              seriesId: seriesId,
              seriesName: seriesName,
              seriesYear: seriesYear,
            );
          },
        ),
      ],
    ),
  );
}

class _SeriesProgressCards extends ConsumerWidget {
  final int seriesId;
  final int total;

  const _SeriesProgressCards({required this.seriesId, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedAsync = ref.watch(seriesOwnedCountProvider(seriesId));
    final readAsync = ref.watch(seriesReadCountProvider(seriesId));

    final owned = ownedAsync.value;
    final read = readAsync.value;
    if (owned == null || read == null) {
      if (ownedAsync.hasError || readAsync.hasError) {
        return const SizedBox.shrink();
      }
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ShimmerWidget(
          child: Row(
            children: [
              Expanded(child: SkeletonBox(height: 64, borderRadius: 12)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 64, borderRadius: 12)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _ProgressStatCard(
              value: owned,
              total: total,
              label: 'COLLECTED',
              icon: Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProgressStatCard(
              value: read,
              total: total,
              label: 'READ',
              icon: Icons.bookmark_added,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final int value;
  final int total;
  final String label;
  final IconData icon;

  const _ProgressStatCard({
    required this.value,
    required this.total,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final percent = (fraction * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$value/$total',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: ' · $percent%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
