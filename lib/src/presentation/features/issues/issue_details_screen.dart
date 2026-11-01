import "dart:ui";

import "package:auto_route/auto_route.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:takion/src/core/errors/error_mapper.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_details_provider.dart";
import "package:takion/src/presentation/features/issues/scrobble_sheet.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/features/issues/issue_details/issue_details_sheet.dart";
import "package:takion/src/presentation/features/issues/issue_details/issue_details_skeleton.dart";
import "package:takion/src/presentation/features/issues/issue_details/providers/issue_series_navigation_provider.dart";
import "package:takion/src/presentation/features/issues/issue_details/widgets/issue_cover_carousel.dart";
import "package:takion/src/presentation/features/issues/issue_share_util.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/issues/series_subscription_toggle.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/favorite_toggle_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

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
    with
        ResourceUrlActions<IssueDetails>,
        FavoriteToggleActions,
        DetailRefreshActions<IssueDetails> {
  @override
  String? resourceUrlOf(IssueDetails issue) => issue.resourceUrl;

  @override
  String get resourceLabel => "issue";

  @override
  String shareSubjectOf(IssueDetails issue) => issueDisplayTitle(issue);

  @override
  String get entityLabel => "Issue";

  @override
  Future<IssueDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getIssueDetails(_currentIssueId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(issueDetailsProvider(_currentIssueId));
  }

  late int _currentIssueId;
  int _slideDirection = 0;
  String? _currentCoverUrl;
  IssueDetails? _lastLoadedIssue;

  @override
  void initState() {
    super.initState();
    _currentIssueId = widget.issueId;
    _currentCoverUrl = widget.initialImageUrl;
  }

  void _navigateToIssue(
    int newIssueId, {
    required int direction,
    String? targetCoverUrl,
  }) {
    if (_currentIssueId == newIssueId) return;
    setState(() {
      _slideDirection = direction;
      _currentIssueId = newIssueId;
      if (targetCoverUrl != null && targetCoverUrl.isNotEmpty) {
        _currentCoverUrl = targetCoverUrl;
      }
    });
  }

  String _displayTitle(IssueDetails issue) {
    final seriesName = issue.series?.name.trim();
    final issueNumber = issue.number.trim();
    final storyTitle = issue.title?.trim();

    String baseName;
    if (seriesName != null && seriesName.isNotEmpty && issueNumber.isNotEmpty) {
      baseName = "$seriesName #$issueNumber";
    } else if (issue.names.isNotEmpty && issue.names.first.trim().isNotEmpty) {
      baseName = issue.names.first.trim();
    } else {
      baseName = issueNumber.isNotEmpty ? "Issue #$issueNumber" : "Issue";
    }

    if (storyTitle != null && storyTitle.isNotEmpty) {
      return "$baseName: $storyTitle";
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
        labels.add("Main Cover");
        continue;
      }

      final variant = issue.variants.firstWhere(
        (item) => (item.image?.trim() ?? "") == image,
        orElse: () => const IssueDetailsVariant(),
      );
      final variantName = variant.name?.trim();
      labels.add(
        variantName != null && variantName.isNotEmpty ? variantName : "Variant",
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
              ? "Main Cover • \$$mainPrice"
              : "Main Cover",
        );
        continue;
      }

      final variant = issue.variants.firstWhere(
        (item) => (item.image?.trim() ?? "") == image,
        orElse: () => const IssueDetailsVariant(),
      );
      final variantName = variant.name?.trim();
      final variantPrice = variant.price?.trim();

      final hasName = variantName != null && variantName.isNotEmpty;
      final hasPrice = variantPrice != null && variantPrice.isNotEmpty;

      if (hasName && hasPrice) {
        captions.add("$variantName • \$$variantPrice");
      } else if (hasName) {
        captions.add(variantName);
      } else if (hasPrice) {
        captions.add("Variant • \$$variantPrice");
      } else {
        captions.add("Variant");
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
        heroTag: "issue-cover-$_currentIssueId",
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
    final isCurrentData = issue != null && issue.id == _currentIssueId;
    if (isCurrentData) {
      _lastLoadedIssue = issue;
      if (issue.image != null && issue.image!.trim().isNotEmpty) {
        _currentCoverUrl = issue.image;
      }
    }

    final displayIssue = isCurrentData ? issue : _lastLoadedIssue;
    final seriesId = displayIssue?.series?.id ?? issue?.series?.id;

    final subscriptionAsync = seriesId != null
        ? ref.watch(seriesSubscriptionProvider(seriesId))
        : const AsyncValue.data(null);
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final effectiveIsPulled = isInPullList || isSubscribed;

    final navAsync = seriesId == null
        ? const AsyncValue<IssueSeriesNavResult>.data(IssueSeriesNavResult())
        : ref.watch(
            issueSeriesNavigationProvider(
              IssueSeriesNavArgs(seriesId: seriesId, issueId: _currentIssueId),
            ),
          );
    final navResult = navAsync.asData?.value;
    final previousIssueId = navResult?.previousIssueId;
    final nextIssueId = navResult?.nextIssueId;
    final previousImageUrl = navResult?.previousImageUrl;
    final nextImageUrl = navResult?.nextImageUrl;

    if (seriesId != null) {
      ref.listen(
        issueSeriesNavigationProvider(
          IssueSeriesNavArgs(seriesId: seriesId, issueId: _currentIssueId),
        ),
        (previous, next) {
          final res = next.asData?.value;
          if (res != null) {
            if (res.previousIssueId != null) {
              ref.read(issueDetailsProvider(res.previousIssueId!).future);
            }
            if (res.nextIssueId != null) {
              ref.read(issueDetailsProvider(res.nextIssueId!).future);
            }
          }
        },
      );
    }

    if (displayIssue == null) {
      return Scaffold(
        body: issueAsync.when(
          loading: () => IssueDetailsSkeleton(
            imageUrl: _currentCoverUrl ?? widget.initialImageUrl,
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(),
            body: AsyncStatePanel.fromFailure(
              failure: ErrorMapper.fromException(error, stack),
              onRetry: () {
                ref.invalidate(issueDetailsProvider(_currentIssueId));
              },
            ),
          ),
          data: (_) => const SizedBox.shrink(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: KeyedSubtree(
                    key: ValueKey(_currentCoverUrl ?? _currentIssueId),
                    child: SizedBox.expand(
                      child:
                          (_currentCoverUrl != null &&
                              _currentCoverUrl!.trim().isNotEmpty)
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 8,
                                sigmaY: 8,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: _currentCoverUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 720,
                              ),
                            )
                          : ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                    ),
                  ),
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
                  child: IssueCoverCarousel(
                    currentIssueId: _currentIssueId,
                    currentImageUrl:
                        _currentCoverUrl ??
                        (isCurrentData ? issue.image : null),
                    slideDirection: _slideDirection,
                    previousIssueId: previousIssueId,
                    nextIssueId: nextIssueId,
                    onPrevious: previousIssueId == null
                        ? null
                        : () => _navigateToIssue(
                            previousIssueId,
                            direction: -1,
                            targetCoverUrl: previousImageUrl,
                          ),
                    onNext: nextIssueId == null
                        ? null
                        : () => _navigateToIssue(
                            nextIssueId,
                            direction: 1,
                            targetCoverUrl: nextImageUrl,
                          ),
                    onTapCover: isCurrentData
                        ? () => _openCoverGallery(displayIssue)
                        : null,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Center(
                      child: BackButton(
                        style: detailHeaderIconButtonStyle(theme),
                      ),
                    ),
                    actions: [
                      if (issueAsync.isRefreshing ||
                          (issueAsync.isLoading && issueAsync.hasValue))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Updating...",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (issueAsync.hasError)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    size: 12,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Cached",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Center(
                          child: EntityDetailActions(
                            style: detailHeaderIconButtonStyle(theme),
                            onRefresh: isCurrentData
                                ? () => refreshDetails(context)
                                : null,
                            onShare: () =>
                                shareResourceUrl(context, displayIssue),
                            onOpenInBrowser: () =>
                                openResourceUrlInBrowser(context, displayIssue),
                          ),
                        ),
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
            snapSizes: const [0.60, 0.9],
            builder: (context, scrollController) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey(_currentIssueId),
                  child: IssueDetailsSheet(
                    scrollController: scrollController,
                    issue: displayIssue,
                    issueId: _currentIssueId,
                    collectionStatus: isCurrentData ? issueStatus : null,
                    isInPullList: isCurrentData ? effectiveIsPulled : false,
                    isFavorite: isCurrentData
                        ? (isFavoriteAsync.asData?.value ?? false)
                        : false,
                    displayTitle: _displayTitle(displayIssue),
                    onShowScrobbleSheet: isCurrentData
                        ? scrobbleCurrentIssue
                        : () {},
                    onToggleFavorite: isCurrentData ? toggleFavorite : () {},
                    onNavigateToSeries: isCurrentData
                        ? () => _navigateToSeries(displayIssue)
                        : () {},
                    seriesId: isCurrentData ? seriesId : null,
                    isSubscribed: isCurrentData ? isSubscribed : false,
                    onToggleSeriesSubscription:
                        (isCurrentData && seriesId != null)
                        ? () => _setSeriesSubscription(!isSubscribed, seriesId)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
