import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/components/horizontal_preview_section.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum _SeriesDetailsMenuAction { share, openInBrowser }

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
        TakionAlerts.success(
          context,
          !isFavorite
              ? 'Series added to favorites'
              : 'Series removed from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

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
      ref.invalidate(seriesSubscriptionProvider(widget.seriesId));
      ref.invalidate(issuePullListEntryProvider);
      ref.invalidate(pullListEntriesForWeekProvider);
      ref.invalidate(pullsIssuesForWeekProvider);
      ref.invalidate(pullsIssuesForWeekProvider(selectedWeek));
      ref.invalidate(currentWeekPullsProvider);
      ref.invalidate(currentWeekPullsCountProvider);
      await invalidateSubscriptionsLocalCacheWithHive(
        ref.read(hiveServiceProvider),
      );
      ref.invalidate(activeSubscriptionsProvider);
      ref.invalidate(activeSubscriptionsCountProvider);
      ref.invalidate(subscribedSeriesListProvider);
      ref.invalidate(subscribedSeriesPageProvider);
      await ref.read(currentWeekPullsProvider.future);
      if (mounted) {
        TakionAlerts.success(
          context,
          enabled
              ? 'Subscribed and pull list updated.'
              : 'Unsubscribed and pull list updated.',
        );
      }
    } catch (error) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update subscription: $error');
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

  Future<void> _handleMoreAction(
    _SeriesDetailsMenuAction action,
    SeriesDetails details,
  ) async {
    switch (action) {
      case _SeriesDetailsMenuAction.share:
        await _shareResourceUrl(details);
        break;
      case _SeriesDetailsMenuAction.openInBrowser:
        await _openResourceUrlInBrowser(details);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));

    return detailsAsync.when(
      loading: () => _SeriesDetailsSkeleton(imageUrl: widget.initialImageUrl),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncStatePanel.error(
          errorMessage: 'Failed to load series details: $error',
        ),
      ),
      data: (details) {
        final coverImageAsync = ref.watch(
          seriesCoverImageProvider((
            seriesId: widget.seriesId,
            allowRemoteFetch: true,
          )),
        );
        final description = details.description?.trim();
        final associated = details.associated
            .where((entry) => entry.series.trim().isNotEmpty)
            .toList();
        final showDescription = description != null && description.isNotEmpty;
        final showAssociated = associated.isNotEmpty;
        final scaffoldBg = Theme.of(context).colorScheme.surface;
        final issuesPreviewAsync = ref.watch(
          seriesIssueListProvider(SeriesIssueListArgs(
            seriesId: widget.seriesId,
            page: 1,
          )),
        );
        final sortOption = ref.watch(
          sortPreferenceForContextProvider(
            SortPreferenceContext.seriesDetailsIssues,
          ),
        );
        final issuesPreview = issuesPreviewAsync.asData != null
            ? sortIssues(
                issuesPreviewAsync.asData!.value.results,
                sortOption,
              ).take(5).toList()
            : <IssueList>[];
        final totalIssueCount =
            issuesPreviewAsync.asData?.value.count ?? 0;

        final subscriptionAsync = ref.watch(seriesSubscriptionProvider(widget.seriesId));
        final isSubscribed =
            subscriptionAsync.asData?.value?.isActive ?? false;
        final isSubscriptionLoading =
            subscriptionAsync.isLoading || _isUpdatingSubscription;

        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    coverImageAsync.when(
                      data: (imageUrl) => imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: scaffoldBg,
                              ),
                              errorWidget: (context, url, error) =>
                                  Container(
                                color: scaffoldBg,
                                child:
                                    const Icon(Icons.broken_image_outlined),
                              ),
                            )
                          : Container(
                              color: scaffoldBg,
                              child:
                                  const Icon(Icons.image_outlined, size: 40),
                            ),
                      loading: () => Container(color: scaffoldBg),
                      error: (_, _) => Container(
                        color: scaffoldBg,
                        child: const Icon(Icons.error_outline),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scaffoldBg.withValues(alpha: 0.75),
                            Colors.transparent,
                            scaffoldBg.withValues(alpha: 0.75),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          PopupMenuButton<_SeriesDetailsMenuAction>(
                            tooltip: 'More options',
                            onSelected: (action) {
                              _handleMoreAction(action, details);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _SeriesDetailsMenuAction.share,
                                child: Text('Share'),
                              ),
                              PopupMenuItem(
                                value: _SeriesDetailsMenuAction.openInBrowser,
                                child: Text('Open in browser'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: [0.60, 0.9],
                builder: (context, scrollController) {
                  return _SeriesDetailsSheet(
                    scrollController: scrollController,
                    details: details,
                    showDescription: showDescription,
                    description: description,
                    showAssociated: showAssociated,
                    associated: associated,
                    seriesId: widget.seriesId,
                    issuesPreview: issuesPreview,
                    totalIssueCount: totalIssueCount,
                    isSubscribed: isSubscribed,
                    isSubscriptionLoading: isSubscriptionLoading,
                    onToggleSubscription: _setSeriesSubscription,
                    onToggleFavorite: _toggleFavorite,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeriesDetailsSheet extends ConsumerWidget {
  const _SeriesDetailsSheet({
    required this.scrollController,
    required this.details,
    required this.showDescription,
    required this.description,
    required this.showAssociated,
    required this.associated,
    required this.seriesId,
    required this.issuesPreview,
    required this.totalIssueCount,
    required this.isSubscribed,
    required this.isSubscriptionLoading,
    required this.onToggleSubscription,
    required this.onToggleFavorite,
  });

  final ScrollController scrollController;
  final SeriesDetails details;
  final bool showDescription;
  final String? description;
  final bool showAssociated;
  final List<SeriesDetailsAssociated> associated;
  final int seriesId;
  final List<IssueList> issuesPreview;
  final int totalIssueCount;
  final bool isSubscribed;
  final bool isSubscriptionLoading;
  final Future<void> Function(bool enabled) onToggleSubscription;
  final Future<void> Function() onToggleFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final publisher = details.publisher?.name.trim();
    final hasPublisher = publisher != null && publisher.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: theme.colorScheme.surface,
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
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${details.name.toUpperCase()} (${details.yearBegan ?? ''})',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (hasPublisher) publisher,
                        if (details.status != null) details.status,
                        if (details.seriesType?.name != null) details.seriesType!.name,
                      ].join(' • '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: FilledButton(
                            style: isSubscribed
                                ? FilledButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.errorContainer,
                                    foregroundColor:
                                        theme.colorScheme.onErrorContainer,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  )
                                : FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                            onPressed: isSubscriptionLoading
                                ? null
                                : () => onToggleSubscription(!isSubscribed),
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
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              iconSize: 28,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              AddToReadingListBottomSheet.show(
                                context: context,
                                targetId: 'series-$seriesId',
                                isSeries: true,
                              );
                            },
                            child: const Icon(Icons.playlist_add),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              iconSize: 28,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onToggleFavorite,
                            child: ref.watch(isSeriesFavoriteProvider(seriesId)).when(
                              data: (isFavorite) => Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              loading: () => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              error: (_, _) =>
                                  const Icon(Icons.favorite_border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (showDescription) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SeriesDescriptionCard(
                    description: description!,
                    seriesId: details.id,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HorizontalPreviewSection(
                  title: 'Issues',
                  count: totalIssueCount,
                  onViewAll: () => context.pushRoute(
                    SeriesIssuesRoute(seriesId: seriesId),
                  ),
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
              ),
            ),
            if (showAssociated) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SeriesAssociatedCard(
                    associated: associated,
                  ),
                ),
              ),
            ],
            if (details.genres.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SeriesGenresCard(genres: details.genres),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SeriesInfoCard(details: details),
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

class _SeriesDetailsSkeleton extends StatelessWidget {
  const _SeriesDetailsSkeleton({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.60,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.60, 0.9],
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle? _sectionTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.primary,
  );
}

class _SeriesDescriptionCard extends StatefulWidget {
  const _SeriesDescriptionCard({
    required this.description,
    required this.seriesId,
  });

  final String description;
  final int seriesId;

  @override
  State<_SeriesDescriptionCard> createState() => _SeriesDescriptionCardState();
}

class _SeriesDescriptionCardState extends State<_SeriesDescriptionCard> {
  static const _descriptionMaxLines = 4;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = Theme.of(context).textTheme.bodyMedium;
        final fullPainter = TextPainter(
          text: TextSpan(text: widget.description, style: textStyle),
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final collapsedPainter = TextPainter(
          text: TextSpan(text: widget.description, style: textStyle),
          maxLines: _descriptionMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = collapsedPainter.didExceedMaxLines;
        final collapsedHeight = isOverflowing
            ? collapsedPainter.height
            : fullPainter.height;
        final heightFactor = fullPainter.height > 0
            ? collapsedHeight / fullPainter.height
            : 1.0;

        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? 1.0 : heightFactor,
                  child: Text(widget.description, style: textStyle),
                ),
              ),
              if (isOverflowing) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topLeft,
                        child: child,
                      ),
                    ),
                    child: Text(
                      _isExpanded
                          ? 'Tap to read less'
                          : 'Tap to read more',
                      key: ValueKey(_isExpanded),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SeriesAssociatedCard extends StatelessWidget {
  const _SeriesAssociatedCard({
    required this.associated,
  });

  final List<SeriesDetailsAssociated> associated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Associated Series', style: _sectionTitleStyle(context)),
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
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
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
                      context.pushRoute(
                        SeriesDetailsRoute(seriesId: entry.id),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        Text('Genres', style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: genres.map(
            (genre) => Chip(
              label: Text(genre.name, style: Theme.of(context).textTheme.labelSmall),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ).toList(),
        ),
      ],
    );
  }
}

class _SeriesInfoCard extends StatelessWidget {
  const _SeriesInfoCard({required this.details});

  final SeriesDetails details;

  String? _modifiedValue() {
    final modified = details.modified;
    if (modified == null) return null;

    final year = modified.year.toString().padLeft(4, '0');
    final month = modified.month.toString().padLeft(2, '0');
    final day = modified.day.toString().padLeft(2, '0');
    final hour = modified.hour.toString().padLeft(2, '0');
    final minute = modified.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = details.yearBegan;
    final end = details.yearEnd;
    final years = (start == null && end == null)
        ? null
        : (start != null && end != null)
        ? '$start - $end'
        : (start != null)
        ? '$start - Present'
        : 'Until $end';

    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final infoItems = <({String label, String value})>[
      if (details.volume != null)
        (label: 'Volume', value: '${details.volume}'),
      if (years != null)
        (label: 'Years', value: years),
      if (details.issueCount != null)
        (label: 'Issues', value: '${details.issueCount}'),
      if (details.imprint?.name != null && details.imprint!.name.trim().isNotEmpty)
        (label: 'Imprint', value: details.imprint!.name.trim()),
      (label: 'Metron ID', value: '${details.id}'),
      if (details.cvId != null) (label: 'CV ID', value: '${details.cvId}'),
      if (details.gcdId != null) (label: 'GCD ID', value: '${details.gcdId}'),
    ];

    final hasAnyContent = infoItems.isNotEmpty || hasModified;

    if (!hasAnyContent && !hasModified) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information', style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        if (infoItems.isNotEmpty)
          ...infoItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      item.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (hasModified) ...[
          const SizedBox(height: 12),
          Text(
            'Last modified: $modifiedValue',
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
