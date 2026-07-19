import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_completion_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/features/series/series_issues_screen.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
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
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday % 7));
      await ref
          .read(pullListRepositoryProvider)
          .regenerateFromSubscriptions(fromDate: startOfWeek);
      if (enabled) {
        await ref
            .read(subscriptionPullReconcilerProvider)
            .reconcile(force: true, onlySeriesId: widget.seriesId);
      }
      final selectedWeek = ref.read(selectedWeekProvider);
      invalidateOnSubscriptionToggle(
        ref,
        seriesId: widget.seriesId,
        selectedWeek: selectedWeek,
      );
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
            invalidateOnSubscriptionToggle(
              ref,
              seriesId: widget.seriesId,
              selectedWeek: selectedWeek,
            );
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

      ref.invalidate(isSeriesFavoriteProvider(widget.seriesId));
      ref.invalidate(favoriteSeriesListProvider);

      if (mounted) {
        final added = !isFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await repository.toggleSeriesFavorite(widget.seriesId);
            ref.invalidate(isSeriesFavoriteProvider(widget.seriesId));
            ref.invalidate(favoriteSeriesListProvider);
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
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider((
        seriesId: widget.seriesId,
        allowRemoteFetch: true,
      )),
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
    final ownedCountAsync = ref.watch(
      seriesOwnedCountProvider(widget.seriesId),
    );

    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final isSubscriptionLoading =
        subscriptionAsync.isLoading || _isUpdatingSubscription;
    final isFavorite = isFavoriteAsync.asData?.value ?? false;
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
              SectionHeader(
                title: 'COLLECTION PROGRESS',
                badge: ownedCountAsync.asData?.value != null
                    ? '(${((ownedCountAsync.asData!.value / d.issueCount!) * 100).clamp(0, 100).toStringAsFixed(0)}%)'
                    : null,
              ),
              const SizedBox(height: 8),
              _SeriesCompletionCompact(seriesId: d.id, total: d.issueCount!),
            ],
          ],
        );
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
              child: _SeriesInfoCard(details: d),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title:
                        '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
                    onViewAll: () => context.pushRoute(
                      SeriesIssuesRoute(seriesId: widget.seriesId),
                    ),
                  ),
                  const SizedBox(height: 12),
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
            AddToReadingListBottomSheet.show(
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

class _SeriesCompletionCompact extends ConsumerWidget {
  final int seriesId;
  final int total;

  const _SeriesCompletionCompact({required this.seriesId, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedAsync = ref.watch(seriesOwnedCountProvider(seriesId));
    final theme = Theme.of(context);

    return ownedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (owned) {
        final percent = (owned / total).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$owned/$total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
