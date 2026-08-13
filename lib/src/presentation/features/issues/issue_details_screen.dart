import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';
import 'package:takion/src/presentation/features/issues/scrobble_sheet.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/issues/issue_details/issue_details_sheet.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/issues/issue_details/issue_details_skeleton.dart';
import 'package:takion/src/presentation/features/issues/issue_details/providers/issue_series_navigation_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_share_util.dart';
import 'package:takion/src/presentation/features/issues/series_subscription_toggle.dart';
import 'package:takion/src/presentation/shared/resource_url_actions.dart';
import 'package:takion/src/presentation/shared/favorite_toggle_actions.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

@RoutePage()
class IssueDetailsScreen extends ConsumerStatefulWidget {
  const IssueDetailsScreen({
    super.key,
    @pathParam required this.issueId,
    this.initialImageUrl,
  });

  final int issueId;
  final String? initialImageUrl;

  @override
  ConsumerState<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends ConsumerState<IssueDetailsScreen>
    with ResourceUrlActions<IssueDetails>, FavoriteToggleActions {
  @override
  String? resourceUrlOf(IssueDetails issue) => issue.resourceUrl;

  @override
  String get resourceLabel => 'issue';

  @override
  String shareSubjectOf(IssueDetails issue) => issueDisplayTitle(issue);

  late int _currentIssueId;

  Future<void> _refreshIssueData() async {
    try {
      await ref
          .read(catalogRepositoryProvider)
          .getIssueDetails(_currentIssueId, forceRefresh: true);
      ref.invalidate(issueDetailsProvider(_currentIssueId));
      if (mounted) {
        TakionAlerts.success(context, 'Issue details refreshed');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to refresh issue details');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIssueId = widget.issueId;
  }

  String _displayTitle(IssueDetails issue) {
    final seriesName = issue.series?.name.trim();
    final issueNumber = issue.number.trim();
    final storyTitle = issue.title?.trim();

    String baseName;
    if (seriesName != null && seriesName.isNotEmpty && issueNumber.isNotEmpty) {
      baseName = '$seriesName #$issueNumber';
    } else if (issue.names.isNotEmpty && issue.names.first.trim().isNotEmpty) {
      baseName = issue.names.first.trim();
    } else {
      baseName = issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
    }

    if (storyTitle != null && storyTitle.isNotEmpty) {
      return '$baseName: $storyTitle';
    }

    return baseName;
  }

  List<String> _coverImages(IssueDetails issue) {
    final images = <String>[];
    final mainImage = issue.image?.trim();
    if (mainImage != null && mainImage.isNotEmpty) {
      images.add(mainImage);
    }

    for (final variant in issue.variants) {
      final image = variant.image?.trim();
      if (image != null && image.isNotEmpty && !images.contains(image)) {
        images.add(image);
      }
    }

    return images;
  }

  List<String> _coverLabels(IssueDetails issue, List<String> images) {
    final labels = <String>[];
    final mainImage = issue.image?.trim();

    for (final image in images) {
      if (mainImage != null && mainImage.isNotEmpty && image == mainImage) {
        labels.add('Main Cover');
        continue;
      }

      final variant = issue.variants.firstWhere(
        (item) => (item.image?.trim() ?? '') == image,
        orElse: () => const IssueDetailsVariant(),
      );
      final variantName = variant.name?.trim();
      labels.add(
        variantName != null && variantName.isNotEmpty ? variantName : 'Variant',
      );
    }

    return labels;
  }

  List<String> _coverCaptions(IssueDetails issue, List<String> images) {
    final captions = <String>[];
    final mainImage = issue.image?.trim();

    for (final image in images) {
      if (mainImage != null && mainImage.isNotEmpty && image == mainImage) {
        final mainPrice = issue.price?.trim();
        captions.add(
          mainPrice != null && mainPrice.isNotEmpty
              ? 'Main Cover • \$$mainPrice'
              : 'Main Cover',
        );
        continue;
      }

      final variant = issue.variants.firstWhere(
        (item) => (item.image?.trim() ?? '') == image,
        orElse: () => const IssueDetailsVariant(),
      );
      final variantName = variant.name?.trim();
      final variantPrice = variant.price?.trim();

      final hasName = variantName != null && variantName.isNotEmpty;
      final hasPrice = variantPrice != null && variantPrice.isNotEmpty;

      if (hasName && hasPrice) {
        captions.add('$variantName • \$$variantPrice');
      } else if (hasName) {
        captions.add(variantName);
      } else if (hasPrice) {
        captions.add('Variant • \$$variantPrice');
      } else {
        captions.add('Variant');
      }
    }

    return captions;
  }

  void _openCoverGallery(IssueDetails issue) {
    final images = _coverImages(issue);
    if (images.isEmpty) return;
    final labels = _coverLabels(issue, images);
    final captions = _coverCaptions(issue, images);

    context.pushRoute(
      IssueCoverGalleryRoute(
        imageUrls: images,
        imageLabels: labels,
        imageCaptions: captions,
        initialIndex: 0,
        title: _displayTitle(issue),
        heroTag: 'issue-cover-$_currentIssueId',
      ),
    );
  }

  void _navigateToSeries(IssueDetails issue) {
    final series = issue.series;
    final seriesName = series?.name.trim();
    if (series == null || seriesName == null || seriesName.isEmpty) {
      TakionAlerts.noLinkedSeriesForIssue(context);
      return;
    }

    context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
  }

  void scrobbleCurrentIssue() {
    final issue = ref.read(issueDetailsProvider(_currentIssueId)).asData?.value;
    final seriesId = issue?.series?.id;
    final subscriptionAsync = seriesId != null
        ? ref.read(seriesSubscriptionProvider(seriesId)).asData?.value
        : null;
    final isSubscribed = subscriptionAsync?.isActive ?? false;

    final title = issue != null ? _displayTitle(issue) : null;
    showScrobbleSheet(
      context: context,
      ref: ref,
      issueId: _currentIssueId,
      sheetTitle: title,
      seriesId: seriesId,
      isSubscribed: isSubscribed,
      releaseDate: issue?.storeDate ?? issue?.coverDate,
      seriesName: issue?.series?.name,
      issueNumber: issue?.number,
      imageUrl: issue?.image,
    );
  }

  Future<void> toggleFavorite() {
    return toggleFavoriteWithUndo(
      context,
      isFavorite: ref.read(isIssueFavoriteProvider(_currentIssueId).future),
      toggle: () async {
        final repository = ref.read(favoritesRepositoryProvider);
        await repository.toggleIssueFavorite(_currentIssueId);
      },
    );
  }

  Future<void> _setSeriesSubscription(bool enabled, int seriesId) async {
    await toggleSeriesSubscription(
      context: context,
      container: ref.container,
      enabled: enabled,
      seriesId: seriesId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issueAsync = ref.watch(issueDetailsProvider(_currentIssueId));
    final issueStatus = ref.watch(
      issueCollectionStatusProvider(_currentIssueId),
    );
    final pullEntryAsync = ref.watch(
      issuePullListEntryProvider(_currentIssueId),
    );
    final isInPullList = pullEntryAsync.asData?.value != null;
    final isFavoriteAsync = ref.watch(isIssueFavoriteProvider(_currentIssueId));

    final issue = issueAsync.asData?.value;
    final seriesId = issue?.series?.id;

    final subscriptionAsync = seriesId != null
        ? ref.watch(seriesSubscriptionProvider(seriesId))
        : const AsyncValue.data(null);
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;

    final navAsync = seriesId == null
        ? const AsyncValue<IssueSeriesNavResult>.data(IssueSeriesNavResult())
        : ref.watch(
            issueSeriesNavigationProvider(
              IssueSeriesNavArgs(seriesId: seriesId, issueId: _currentIssueId),
            ),
          );
    final previousIssueId = navAsync.asData?.value.previousIssueId;
    final nextIssueId = navAsync.asData?.value.nextIssueId;

    if (seriesId != null) {
      ref.listen(
        issueSeriesNavigationProvider(
          IssueSeriesNavArgs(seriesId: seriesId, issueId: _currentIssueId),
        ),
        (previous, next) {
          final navResult = next.asData?.value;
          if (navResult != null) {
            if (navResult.previousIssueId != null) {
              ref.read(issueDetailsProvider(navResult.previousIssueId!).future);
            }
            if (navResult.nextIssueId != null) {
              ref.read(issueDetailsProvider(navResult.nextIssueId!).future);
            }
          }
        },
      );
    }

    if (issue == null) {
      return Scaffold(
        body: issueAsync.when(
          loading: () => IssueDetailsSkeleton(imageUrl: widget.initialImageUrl),
          error: (error, stack) => Scaffold(
            appBar: AppBar(),
            body: AsyncStatePanel.error(
              title: 'Failed to load issue details',
              errorMessage: TakionAlerts.cleanError(
                error,
                fallback: 'Something went wrong',
              ),
              onRetry: () {
                ref.invalidate(issueDetailsProvider(_currentIssueId));
              },
            ),
          ),
          data: (_) => const SizedBox.shrink(),
        ),
      );
    }

    final isCurrentData = issue.id == _currentIssueId;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_currentIssueId),
          child: Stack(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isCurrentData && issue.image != null)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: CachedNetworkImage(
                          imageUrl: issue.image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.surface.withValues(alpha: 0.75),
                            Colors.transparent,
                            theme.colorScheme.surface.withValues(alpha: 0.75),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            style: IconButton.styleFrom(
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.85),
                              foregroundColor:
                                  theme.colorScheme.onSurfaceVariant,
                              shape: const CircleBorder(),
                              fixedSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: previousIssueId == null
                                ? null
                                : () => setState(
                                    () => _currentIssueId = previousIssueId,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isCurrentData
                                ? () => _openCoverGallery(issue)
                                : null,
                            child: Hero(
                              tag: 'issue-cover-$_currentIssueId',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 180,
                                  height: 270,
                                  child: isCurrentData && issue.image != null
                                      ? CachedNetworkImage(
                                          imageUrl: issue.image!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          child: const Icon(
                                            Icons.image,
                                            size: 48,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            style: IconButton.styleFrom(
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.85),
                              foregroundColor:
                                  theme.colorScheme.onSurfaceVariant,
                              shape: const CircleBorder(),
                              fixedSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: nextIssueId == null
                                ? null
                                : () => setState(
                                    () => _currentIssueId = nextIssueId,
                                  ),
                          ),
                        ],
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
                          EntityDetailActions(
                            onRefresh: isCurrentData ? _refreshIssueData : null,
                            onShare: isCurrentData
                                ? () => shareResourceUrl(context, issue)
                                : null,
                            onOpenInBrowser: isCurrentData
                                ? () => openResourceUrlInBrowser(context, issue)
                                : null,
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
                  return IssueDetailsSheet(
                    scrollController: scrollController,
                    issue: issue,
                    issueId: _currentIssueId,
                    collectionStatus: isCurrentData ? issueStatus : null,
                    isInPullList: isCurrentData ? isInPullList : false,
                    isFavorite: isCurrentData
                        ? (isFavoriteAsync.asData?.value ?? false)
                        : false,
                    displayTitle: isCurrentData ? _displayTitle(issue) : '',
                    onShowScrobbleSheet: isCurrentData
                        ? scrobbleCurrentIssue
                        : () {},
                    onToggleFavorite: isCurrentData ? toggleFavorite : () {},
                    onNavigateToSeries: isCurrentData
                        ? () => _navigateToSeries(issue)
                        : () {},
                    seriesId: isCurrentData ? seriesId : null,
                    isSubscribed: isCurrentData ? isSubscribed : false,
                    onToggleSeriesSubscription:
                        (isCurrentData && seriesId != null)
                        ? () => _setSeriesSubscription(!isSubscribed, seriesId)
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
