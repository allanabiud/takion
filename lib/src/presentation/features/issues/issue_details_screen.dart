import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issues_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/components/rating_picker.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/issues/issue_details/issue_about_content.dart';
import 'package:takion/src/presentation/features/issues/issue_details/issue_library_sheets.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_reading_list_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

enum _IssueDetailsMenuAction { share, openInBrowser }

class _IssueSeriesNavArgs {
  const _IssueSeriesNavArgs({required this.seriesId, required this.issueId});

  final int seriesId;
  final int issueId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _IssueSeriesNavArgs &&
        other.seriesId == seriesId &&
        other.issueId == issueId;
  }

  @override
  int get hashCode => Object.hash(seriesId, issueId);
}

class _IssueSeriesNavResult {
  const _IssueSeriesNavResult({this.previousIssueId, this.nextIssueId});

  final int? previousIssueId;
  final int? nextIssueId;
}

double? _issueNumberValue(String input) {
  final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(input);
  if (match == null) return null;
  return double.tryParse(match.group(0)!);
}

int _compareSeriesIssueNumbers(IssueList a, IssueList b) {
  final aValue = _issueNumberValue(a.number);
  final bValue = _issueNumberValue(b.number);

  if (aValue != null && bValue != null) {
    final valueCompare = aValue.compareTo(bValue);
    if (valueCompare != 0) return valueCompare;
  } else if (aValue != null || bValue != null) {
    return aValue == null ? 1 : -1;
  }

  return a.number.toLowerCase().compareTo(b.number.toLowerCase());
}

final _seriesIssuesCacheProvider = FutureProvider.autoDispose
    .family<List<IssueList>, int>((ref, seriesId) async {
      ref.keepAlive();
      final repository = ref.watch(catalogRepositoryProvider);
      final issues = <IssueList>[];
      var page = 1;
      var scannedPages = 0;
      var hasNext = true;

      while (hasNext && scannedPages < 50) {
        final result = await repository.getSeriesIssueList(
          seriesId,
          page: page,
        );
        issues.addAll(result.results);
        hasNext = result.hasNext;
        page = result.nextPage ?? (page + 1);
        scannedPages++;
      }
      return issues;
    });

final _issueSeriesNavigationProvider = FutureProvider.autoDispose
    .family<_IssueSeriesNavResult, _IssueSeriesNavArgs>((ref, args) async {
      final issues = await ref.watch(_seriesIssuesCacheProvider(args.seriesId).future);

      final dedupedById = <int, IssueList>{};
      for (final issue in issues) {
        final id = issue.id;
        if (id == null) continue;
        dedupedById[id] = issue;
      }

      final ordered = dedupedById.values.toList()
        ..sort(_compareSeriesIssueNumbers);
      if (ordered.isEmpty) return const _IssueSeriesNavResult();

      final currentIndex = ordered.indexWhere(
        (issue) => issue.id == args.issueId,
      );
      if (currentIndex < 0) return const _IssueSeriesNavResult();

      final previous =
          currentIndex > 0 ? ordered[currentIndex - 1].id : null;
      final next = currentIndex < ordered.length - 1
          ? ordered[currentIndex + 1].id
          : null;

      return _IssueSeriesNavResult(
        previousIssueId: previous,
        nextIssueId: next,
      );
    });

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

class _IssueDetailsScreenState extends ConsumerState<IssueDetailsScreen> {
  late int _currentIssueId;

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
    } else if (issue.names.isNotEmpty &&
        issue.names.first.trim().isNotEmpty) {
      baseName = issue.names.first.trim();
    } else {
      baseName = issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
    }

    if (storyTitle != null && storyTitle.isNotEmpty) {
      return '$baseName: $storyTitle';
    }

    return baseName;
  }

  String _subtitle(IssueDetails issue) {
    final publisher = issue.publisher?.name.trim();
    final storeDate = issue.storeDate;
    final dateStr = storeDate != null
        ? DateFormat.yMMMd().format(storeDate.toLocal())
        : null;

    final parts = <String>[
      ?publisher,
      ?dateStr,
    ];

    if (parts.isNotEmpty) return parts.join(' • ');
    return '';
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
        heroTag: 'issue-cover-${_currentIssueId}',
      ),
    );
  }

  Uri? _resourceUri(IssueDetails issue) {
    final resourceUrl = issue.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(IssueDetails issue) async {
    final uri = _resourceUri(issue);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'issue');
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: _displayTitle(issue)),
    );
  }

  Future<void> _openResourceUrlInBrowser(IssueDetails issue) async {
    final uri = _resourceUri(issue);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'issue');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'issue');
    }
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

  Future<void> _handleMoreAction(
    _IssueDetailsMenuAction action,
    IssueDetails issue,
  ) async {
    switch (action) {
      case _IssueDetailsMenuAction.share:
        await _shareResourceUrl(issue);
        break;
      case _IssueDetailsMenuAction.openInBrowser:
        await _openResourceUrlInBrowser(issue);
        break;
    }
  }

  void showScrobbleSheet(
    IssueDetails issue,
    IssueCollectionStatus? issueStatus,
    bool isInPullList,
  ) {
    var addToCollection = issueStatus?.isCollected ?? false;
    var markAsRead = issueStatus?.isRead ?? false;
    var pullIssue = isInPullList;
    var addToWishlist = issueStatus?.isWishlisted ?? false;
    var selectedRating = (issueStatus?.rating ?? 0).clamp(0, 5);
    ref.read(scrobbleIssueProvider(_currentIssueId).notifier).reset();

    final hadCollection = issueStatus?.isCollected ?? false;
    final hadRead = issueStatus?.isRead ?? false;
    final hadPull = isInPullList;

    String issueTitle(IssueDetails issue) {
      final seriesName = issue.series?.name.trim();
      final issueNumber = issue.number.trim();

      if (seriesName != null &&
          seriesName.isNotEmpty &&
          issueNumber.isNotEmpty) {
        return '$seriesName #$issueNumber';
      }
      if (issue.names.isNotEmpty && issue.names.first.trim().isNotEmpty) {
        return issue.names.first.trim();
      }
      return issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
    }

    final sheetTitle = issueTitle(issue);

    TakionBottomSheet.show<void>(
      context: context,
      title: sheetTitle,
      child: Consumer(
        builder: (context, ref, _) {
          final scrobbleState =
              ref.watch(scrobbleIssueProvider(_currentIssueId));
          final isSubmitting = scrobbleState.isLoading;
          final submitError = scrobbleState.whenOrNull(
            error: (error, _) => '$error',
          );

          return StatefulBuilder(
            builder: (context, setModalState) {
              Color toggleColor(bool enabled) => enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ScrobbleActionIcon(
                        icon: addToCollection
                            ? Icons.inventory_2
                            : Icons.inventory_2_outlined,
                        label: 'Collected',
                        color: toggleColor(addToCollection),
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() {
                                  addToCollection = !addToCollection;
                                  if (addToCollection) {
                                    addToWishlist = false;
                                  }
                                });
                              },
                      ),
                      const SizedBox(width: 24),
                      _ScrobbleActionIcon(
                        icon: markAsRead
                            ? Icons.bookmark_added
                            : Icons.bookmark_added_outlined,
                        label: 'Read',
                        color: toggleColor(markAsRead),
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() {
                                  markAsRead = !markAsRead;
                                  if (!markAsRead) {
                                    selectedRating = 0;
                                  }
                                });
                              },
                      ),
                      const SizedBox(width: 24),
                      _ScrobbleActionIcon(
                        icon: pullIssue
                            ? Icons.shopping_bag
                            : Icons.shopping_bag_outlined,
                        label: 'Pull',
                        color: toggleColor(pullIssue),
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() {
                                  pullIssue = !pullIssue;
                                });
                              },
                      ),
                      const SizedBox(width: 24),
                      _ScrobbleActionIcon(
                        icon: addToWishlist
                            ? Icons.turned_in
                            : Icons.turned_in_not,
                        label: 'Wishlist',
                        color: toggleColor(addToWishlist),
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() {
                                  addToWishlist = !addToWishlist;
                                  if (addToWishlist) {
                                    addToCollection = false;
                                  }
                                });
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Rating',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  RatingPicker(
                    selectedRating: selectedRating,
                    enabled: !isSubmitting,
                    onChanged: (value) {
                      setModalState(() {
                        selectedRating = value;
                        markAsRead = true;
                      });
                    },
                    onReset: () {
                      setModalState(() {
                        selectedRating = 0;
                      });
                    },
                  ),
                  if (submitError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      submitError,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                await ref
                                    .read(
                                      scrobbleIssueProvider(_currentIssueId)
                                          .notifier,
                                    )
                                    .scrobble(
                                      markAsRead:
                                          markAsRead || selectedRating > 0,
                                      addToCollection: addToCollection,
                                      addToWishlist: addToWishlist,
                                      dateRead: markAsRead
                                          ? DateTime.now().toUtc()
                                          : null,
                                      rating:
                                          markAsRead && selectedRating > 0
                                              ? selectedRating
                                              : null,
                                      refreshReadingSuggestion: true,
                                      refreshRateSuggestion: true,
                                    );

                                final latestState = ref.read(
                                  scrobbleIssueProvider(_currentIssueId),
                                );
                                if (latestState.hasError) return;

                                if (pullIssue != hadPull) {
                                  final series = issue.series;
                                  if (!pullIssue) {
                                    await ref
                                        .read(pullListRepositoryProvider)
                                        .deleteEntryByIssueId(
                                            _currentIssueId);
                                  } else {
                                    if (series == null) {
                                      if (context.mounted) {
                                        TakionAlerts
                                            .noLinkedSeriesForIssue(context);
                                      }
                                      return;
                                    }
                                    await ref
                                        .read(pullListRepositoryProvider)
                                        .upsertManualEntry(
                                          metronSeriesId: series.id,
                                          metronIssueId: _currentIssueId,
                                          releaseDate:
                                              issue.storeDate ??
                                              issue.coverDate,
                                        );
                                  }
                                }

                                ref.invalidate(
                                  issuePullListEntryProvider(
                                      _currentIssueId),
                                );
                                ref.invalidate(
                                  pullsIssuesForWeekProvider(
                                    ref.read(selectedWeekProvider),
                                  ),
                                );
                                ref.invalidate(currentWeekPullsProvider);

                                if (context.mounted) {
                                  Navigator.of(context).pop();

                                  final addedNow =
                                      !hadCollection && addToCollection;
                                  final markedReadNow =
                                      !hadRead && markAsRead;

                                  if (addedNow) {
                                    TakionAlerts.libraryAddedToCollection(
                                      context,
                                    );
                                  }
                                  if (markedReadNow) {
                                    TakionAlerts.libraryMarkedAsRead(context);
                                  }
                                  if (!addedNow && !markedReadNow) {
                                    TakionAlerts.libraryUpdated(context);
                                  }
                                  if (pullIssue && !hadPull) {
                                    TakionAlerts.success(
                                      context,
                                      'Added to pull list.',
                                    );
                                  } else if (!pullIssue && hadPull) {
                                    TakionAlerts.info(
                                      context,
                                      'Removed from pull list.',
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Update Status'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isIssueFavoriteProvider(_currentIssueId).future,
      );

      await repository.toggleIssueFavorite(_currentIssueId);

      ref.invalidate(isIssueFavoriteProvider(_currentIssueId));
      ref.invalidate(favoriteIssuesListProvider);

      if (context.mounted) {
        TakionAlerts.success(
          context,
          !isFavorite
              ? 'Issue added to favorites'
              : 'Issue removed from favorites',
        );
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issueAsync = ref.watch(issueDetailsProvider(_currentIssueId));
    final issueStatus = ref.watch(issueCollectionStatusProvider(_currentIssueId));
    final pullEntryAsync =
        ref.watch(issuePullListEntryProvider(_currentIssueId));
    final isInPullList = pullEntryAsync.asData?.value != null;
    final isFavoriteAsync = ref.watch(
      isIssueFavoriteProvider(_currentIssueId),
    );

    final issue = issueAsync.asData?.value;
    final seriesId = issue?.series?.id;

    final navAsync = seriesId == null
        ? const AsyncValue<_IssueSeriesNavResult>.data(
            _IssueSeriesNavResult())
        : ref.watch(
            _issueSeriesNavigationProvider(
              _IssueSeriesNavArgs(
                seriesId: seriesId,
                issueId: _currentIssueId,
              ),
            ),
          );
    final previousIssueId = navAsync.asData?.value.previousIssueId;
    final nextIssueId = navAsync.asData?.value.nextIssueId;

    if (seriesId != null) {
      ref.listen(
        _issueSeriesNavigationProvider(
          _IssueSeriesNavArgs(
            seriesId: seriesId,
            issueId: _currentIssueId,
          ),
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
          loading: () => _IssueDetailsSkeleton(imageUrl: widget.initialImageUrl),
          error: (error, stack) => Scaffold(
            appBar: AppBar(),
            body: AsyncStatePanel.error(
              title: 'Failed to load issue details',
              errorMessage: '$error',
              onRetry: () {
                ref
                    .read(issueDetailsProvider(_currentIssueId).notifier)
                    .refresh();
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
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
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
                        imageFilter: ImageFilter.blur(
                          sigmaX: 8,
                          sigmaY: 8,
                        ),
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
                            theme.colorScheme.surface
                                .withValues(alpha: 0.75),
                            Colors.transparent,
                            theme.colorScheme.surface
                                .withValues(alpha: 0.75),
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
                                  .colorScheme.surfaceContainerHighest
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
                                    () =>
                                        _currentIssueId = previousIssueId),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isCurrentData
                                ? () => _openCoverGallery(issue)
                                : null,
                            child: Hero(
                              tag:
                                  'issue-cover-${_currentIssueId}',
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 180,
                                  height: 270,
                                  child: isCurrentData &&
                                          issue.image != null
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
                                  .colorScheme.surfaceContainerHighest
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
                                    () => _currentIssueId = nextIssueId),
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
                          PopupMenuButton<_IssueDetailsMenuAction>(
                            tooltip: 'More options',
                            onSelected: isCurrentData
                                ? (action) =>
                                    _handleMoreAction(action, issue)
                                : null,
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value:
                                    _IssueDetailsMenuAction.share,
                                child: Text('Share'),
                              ),
                              PopupMenuItem(
                                value: _IssueDetailsMenuAction
                                    .openInBrowser,
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
                  return _IssueDetailsSheet(
                    scrollController: scrollController,
                    issue: issue,
                    issueId: _currentIssueId,
                    collectionStatus:
                        isCurrentData ? issueStatus : null,
                    isInPullList: isCurrentData ? isInPullList : false,
                    isFavorite: isCurrentData
                        ? (isFavoriteAsync.asData?.value ?? false)
                        : false,
                    displayTitle: isCurrentData
                        ? _displayTitle(issue)
                        : '',
                    subtitle:
                        isCurrentData ? _subtitle(issue) : '',
                    onShowScrobbleSheet: isCurrentData
                        ? () => showScrobbleSheet(
                              issue,
                              issueStatus,
                              isInPullList,
                            )
                        : () {},
                    onToggleFavorite:
                        isCurrentData ? toggleFavorite : () {},
                    onNavigateToSeries: isCurrentData
                        ? () => _navigateToSeries(issue)
                        : () {},
                    onAddToReadingList: isCurrentData
                        ? () {
                            AddToReadingListBottomSheet.show(
                              context: context,
                              targetId:
                                  'issue-${_currentIssueId}',
                              isSeries: false,
                            );
                          }
                        : () {},
                    onMyDetails: isCurrentData
                        ? () => showEditMyDetailsSheet(
                              context,
                              ref,
                              _currentIssueId,
                            )
                        : () {},
                    onReadingHistory: isCurrentData
                        ? () => showReadingHistorySheet(
                              context,
                              ref,
                              _currentIssueId,
                            )
                        : () {},
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

class _IssueDetailsSheet extends StatelessWidget {
  const _IssueDetailsSheet({
    required this.scrollController,
    required this.issue,
    required this.issueId,
    required this.collectionStatus,
    required this.isInPullList,
    required this.isFavorite,
    required this.displayTitle,
    required this.subtitle,
    required this.onShowScrobbleSheet,
    required this.onToggleFavorite,
    required this.onAddToReadingList,
    required this.onNavigateToSeries,
    required this.onMyDetails,
    required this.onReadingHistory,
  });

  final ScrollController scrollController;
  final IssueDetails issue;
  final int issueId;
  final IssueCollectionStatus? collectionStatus;
  final bool isInPullList;
  final bool isFavorite;
  final String displayTitle;
  final String subtitle;
  final VoidCallback onShowScrobbleSheet;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToReadingList;
  final VoidCallback onNavigateToSeries;
  final VoidCallback onMyDetails;
  final VoidCallback onReadingHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingValue = (collectionStatus?.rating ?? 0).clamp(0, 5);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
                      displayTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
                          flex: 3,
                        child: (collectionStatus?.isCollected == true)
                            ? FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.errorContainer,
                                  foregroundColor: theme.colorScheme.onErrorContainer,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: Theme.of(context).textTheme.titleMedium,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: onShowScrobbleSheet,
                                icon: const Icon(Icons.delete_outline, size: 22),
                                label: const Text('Remove'),
                              )
                            : (collectionStatus?.isWishlisted == true)
                                ? FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.tertiaryContainer,
                                      foregroundColor: theme.colorScheme.onTertiaryContainer,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      textStyle: Theme.of(context).textTheme.titleMedium,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: onShowScrobbleSheet,
                                    icon: const Icon(Icons.turned_in, size: 22),
                                    label: const Text('Wishlisted'),
                                  )
                                : isInPullList
                                    ? FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.colorScheme.secondaryContainer,
                                          foregroundColor: theme.colorScheme.onSecondaryContainer,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          textStyle: Theme.of(context).textTheme.titleMedium,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: onShowScrobbleSheet,
                                        icon: const Icon(Icons.shopping_bag, size: 22),
                                        label: const Text('Pulled'),
                                      )
                                    : FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          textStyle: Theme.of(context).textTheme.titleMedium,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: onShowScrobbleSheet,
                                        icon: const Icon(Icons.add, size: 22),
                                        label: const Text('Add'),
                                      ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 1,
                          child: isFavorite
                              ? FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                            onPressed: () => _showIssueMoreOptionsSheet(
                              context,
                              onNavigateToSeries,
                              onAddToReadingList,
                              onMyDetails,
                              onReadingHistory,
                            ),
                            child: const Icon(Icons.more_vert),
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
                child: IssueAboutContent(
                  issue: issue,
                  issueId: issueId,
                ),
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

class _IssueDetailsSkeleton extends StatelessWidget {
  const _IssueDetailsSkeleton({this.imageUrl});

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
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
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
                  child: Container(
                    width: 180,
                    height: 270,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 48,
                              ),
                            )
                          : const Icon(Icons.image, size: 48),
                    ),
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
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
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

class _ScrobbleActionIcon extends StatelessWidget {
  const _ScrobbleActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), iconSize: 32, color: color, onPressed: onPressed),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

void _showIssueMoreOptionsSheet(
  BuildContext context,
  VoidCallback onNavigateToSeries,
  VoidCallback onAddToReadingList,
  VoidCallback onMyDetails,
  VoidCallback onReadingHistory,
) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'More Options',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.view_agenda_outlined),
          title: const Text('Go to Series'),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateToSeries();
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to Reading List'),
          onTap: () {
            Navigator.of(context).pop();
            onAddToReadingList();
          },
        ),
        ListTile(
          leading: const Icon(Icons.library_books_outlined),
          title: const Text('My Details'),
          onTap: () {
            Navigator.of(context).pop();
            onMyDetails();
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Reading History'),
          onTap: () {
            Navigator.of(context).pop();
            onReadingHistory();
          },
        ),
      ],
    ),
  );
}
