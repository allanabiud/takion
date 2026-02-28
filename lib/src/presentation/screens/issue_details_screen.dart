import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/widgets/issue_details/about_tab_content.dart';
import 'package:takion/src/presentation/widgets/issue_details/my_details_tab_content.dart';
import 'package:url_launcher/url_launcher.dart';

enum _IssueDetailsMenuAction { share, openInBrowser }

@RoutePage()
class IssueDetailsScreen extends ConsumerWidget {
  const IssueDetailsScreen({
    super.key,
    @pathParam required this.issueId,
    this.initialImageUrl,
  });

  final int issueId;
  final String? initialImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(issueDetailsProvider(issueId));
    final issueStatus = ref.watch(issueCollectionStatusProvider(issueId));

    String _issueTitle(IssueDetails issue) {
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

    final sheetTitle = issueAsync.maybeWhen(
      data: _issueTitle,
      orElse: () => 'Issue',
    );

    void showScrobbleSheet() {
      var addToCollection = issueStatus?.isCollected ?? false;
      var markAsRead = issueStatus?.isRead ?? false;
      var selectedRating = (issueStatus?.rating ?? 0).clamp(0, 5);
      ref.read(scrobbleIssueProvider(issueId).notifier).reset();

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return Consumer(
            builder: (context, ref, _) {
              final scrobbleState = ref.watch(scrobbleIssueProvider(issueId));
              final isSubmitting = scrobbleState.isLoading;
              final submitError = scrobbleState.whenOrNull(
                error: (error, _) => '$error',
              );

              return StatefulBuilder(
                builder: (context, setModalState) {
                  Color toggleColor(bool enabled) => enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline;

                  return SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sheetTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Add to Collection',
                                    iconSize: 40,
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            setModalState(() {
                                              addToCollection =
                                                  !addToCollection;
                                            });
                                          },
                                    icon: Icon(
                                      addToCollection
                                          ? Icons.inventory_2
                                          : Icons.inventory_2_outlined,
                                      color: toggleColor(addToCollection),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Collected',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Mark as Read',
                                    iconSize: 40,
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
                                    icon: Icon(
                                      markAsRead
                                          ? Icons.bookmark_added
                                          : Icons.bookmark_added_outlined,
                                      color: toggleColor(markAsRead),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Read',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rating',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starValue = index + 1;
                              return IconButton(
                                iconSize: 36,
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedRating = starValue;
                                          markAsRead = true;
                                        });
                                      },
                                icon: Icon(
                                  starValue <= selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: starValue <= selectedRating
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              );
                            }),
                          ),
                          if (selectedRating > 0) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          selectedRating = 0;
                                        });
                                      },
                                child: const Text('Reset rating'),
                              ),
                            ),
                          ],
                          if (submitError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              submitError,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.of(sheetContext).pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        final hadCollection =
                                            issueStatus?.isCollected ?? false;
                                        final hadRead =
                                            issueStatus?.isRead ?? false;

                                        await ref
                                            .read(
                                              scrobbleIssueProvider(
                                                issueId,
                                              ).notifier,
                                            )
                                            .scrobble(
                                              markAsRead:
                                                  markAsRead ||
                                                  selectedRating > 0,
                                              addToCollection: addToCollection,
                                              dateRead: markAsRead
                                                  ? DateTime.now().toUtc()
                                                  : null,
                                              rating:
                                                  markAsRead &&
                                                      selectedRating > 0
                                                  ? selectedRating
                                                  : null,
                                              refreshReadingSuggestion: true,
                                              refreshRateSuggestion: true,
                                            );

                                        final latestState = ref.read(
                                          scrobbleIssueProvider(issueId),
                                        );
                                        if (latestState.hasError) return;

                                        if (sheetContext.mounted) {
                                          Navigator.of(sheetContext).pop();
                                        }
                                        if (context.mounted) {
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
                                            TakionAlerts.libraryMarkedAsRead(
                                              context,
                                            );
                                          }
                                          if (!addedNow && !markedReadNow) {
                                            TakionAlerts.libraryUpdated(
                                              context,
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
                                    : const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showScrobbleSheet,
        child: const Icon(Icons.add),
      ),
      body: issueAsync.when(
        data: (issue) => _IssueDetailsBody(
          issue: issue,
          issueId: issueId,
          collectionStatus: issueStatus,
        ),
        loading: () =>
            _IssueDetailsLoading(issueId: issueId, imageUrl: initialImageUrl),
        error: (error, stack) => AsyncStatePanel.error(
          title: 'Failed to load issue details',
          errorMessage: '$error',
          onRetry: () {
            ref.read(issueDetailsProvider(issueId).notifier).refresh();
          },
        ),
      ),
    );
  }
}

class _IssueDetailsBody extends StatefulWidget {
  const _IssueDetailsBody({
    required this.issue,
    required this.issueId,
    this.collectionStatus,
  });

  final IssueDetails issue;
  final int issueId;
  final IssueCollectionStatus? collectionStatus;

  @override
  State<_IssueDetailsBody> createState() => _IssueDetailsBodyState();
}

class _IssueDetailsBodyState extends State<_IssueDetailsBody> {
  static const _expandedHeight = 340.0;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final fadeStart = _expandedHeight * 0.58;
    final fadeEnd = _expandedHeight - kToolbarHeight;
    final next = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);

    if ((next - _titleOpacity).abs() > 0.01) {
      setState(() {
        _titleOpacity = next;
      });
    }
  }

  String _displayTitle() {
    final seriesName = widget.issue.series?.name.trim();
    final issueNumber = widget.issue.number.trim();
    final storyTitle = widget.issue.title?.trim();

    String baseName;
    if (seriesName != null && seriesName.isNotEmpty && issueNumber.isNotEmpty) {
      baseName = '$seriesName #$issueNumber';
    } else if (widget.issue.names.isNotEmpty &&
        widget.issue.names.first.trim().isNotEmpty) {
      baseName = widget.issue.names.first.trim();
    } else {
      baseName = issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
    }

    if (storyTitle != null && storyTitle.isNotEmpty) {
      return '$baseName: $storyTitle';
    }

    return baseName;
  }

  String _subtitle() {
    final publisher = widget.issue.publisher?.name;
    final year =
        widget.issue.coverDate?.year ??
        widget.issue.storeDate?.year ??
        widget.issue.focDate?.year;

    if (publisher != null && year != null) return '$publisher • $year';
    if (publisher != null) return publisher;
    if (year != null) return '$year';
    return 'Unknown publisher';
  }

  List<String> _coverImages() {
    final images = <String>[];
    final mainImage = widget.issue.image?.trim();
    if (mainImage != null && mainImage.isNotEmpty) {
      images.add(mainImage);
    }

    for (final variant in widget.issue.variants) {
      final image = variant.image?.trim();
      if (image != null && image.isNotEmpty && !images.contains(image)) {
        images.add(image);
      }
    }

    return images;
  }

  List<String> _coverLabels(List<String> images) {
    final labels = <String>[];
    final mainImage = widget.issue.image?.trim();

    for (final image in images) {
      if (mainImage != null && mainImage.isNotEmpty && image == mainImage) {
        labels.add('Main Cover');
        continue;
      }

      final variant = widget.issue.variants.firstWhere(
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

  List<String> _coverCaptions(List<String> images) {
    final captions = <String>[];
    final mainImage = widget.issue.image?.trim();

    for (final image in images) {
      if (mainImage != null && mainImage.isNotEmpty && image == mainImage) {
        final mainPrice = widget.issue.price?.trim();
        captions.add(
          mainPrice != null && mainPrice.isNotEmpty
              ? 'Main Cover • \$$mainPrice'
              : 'Main Cover',
        );
        continue;
      }

      final variant = widget.issue.variants.firstWhere(
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

  void _openCoverGallery() {
    final images = _coverImages();
    if (images.isEmpty) return;
    final labels = _coverLabels(images);
    final captions = _coverCaptions(images);

    context.pushRoute(
      IssueCoverGalleryRoute(
        imageUrls: images,
        imageLabels: labels,
        imageCaptions: captions,
        initialIndex: 0,
        title: _displayTitle(),
        heroTag: 'issue-cover-${widget.issueId}',
      ),
    );
  }

  Uri? _resourceUri() {
    final resourceUrl = widget.issue.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl() async {
    final uri = _resourceUri();
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'issue');
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: _displayTitle()),
    );
  }

  Future<void> _openResourceUrlInBrowser() async {
    final uri = _resourceUri();
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'issue');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'issue');
    }
  }

  void _navigateToSeries() {
    final series = widget.issue.series;
    final seriesName = series?.name.trim();
    if (series == null || seriesName == null || seriesName.isEmpty) {
      TakionAlerts.noLinkedSeriesForIssue(context);
      return;
    }

    context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
  }

  Future<void> _handleMoreAction(_IssueDetailsMenuAction action) async {
    switch (action) {
      case _IssueDetailsMenuAction.share:
        await _shareResourceUrl();
        break;
      case _IssueDetailsMenuAction.openInBrowser:
        await _openResourceUrlInBrowser();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundTint = Theme.of(context).scaffoldBackgroundColor;
    final imageUrl = widget.issue.image;
    final heroTag = 'issue-cover-${widget.issueId}';

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                backgroundColor: colorScheme.surface,
                actions: [
                  IconButton(
                    tooltip: 'Go to series',
                    onPressed: _navigateToSeries,
                    icon: const Icon(Icons.view_agenda_outlined),
                  ),
                  PopupMenuButton<_IssueDetailsMenuAction>(
                    tooltip: 'More options',
                    onSelected: (action) {
                      _handleMoreAction(action);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _IssueDetailsMenuAction.share,
                        child: Text('Share'),
                      ),
                      PopupMenuItem(
                        value: _IssueDetailsMenuAction.openInBrowser,
                        child: Text('Open in browser'),
                      ),
                    ],
                  ),
                ],
                title: Opacity(
                  opacity: _titleOpacity,
                  child: Text(
                    _displayTitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        ColoredBox(color: colorScheme.surfaceContainerHighest),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: backgroundTint.withValues(alpha: 0.44),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.55, 1],
                            colors: [
                              Colors.black.withValues(alpha: 0.56),
                              Colors.black.withValues(alpha: 0.30),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxHeight = constraints.maxHeight;
                          if (maxHeight < 180) {
                            return const SizedBox.shrink();
                          }

                          final topPadding = (maxHeight * 0.18)
                              .clamp(20.0, 72.0)
                              .toDouble();
                          final bottomPadding = (maxHeight * 0.05)
                              .clamp(10.0, 20.0)
                              .toDouble();
                          final titleGap = maxHeight < 320 ? 6.0 : 10.0;
                          final subtitleGap = maxHeight < 320 ? 2.0 : 4.0;
                          final horizontalGap = maxHeight < 320 ? 14.0 : 18.0;
                          final title = _displayTitle();
                          final baseTitleLargeStyle = Theme.of(
                            context,
                          ).textTheme.titleLarge;
                          final baseTitleMediumStyle = Theme.of(
                            context,
                          ).textTheme.titleMedium;
                          final titleLargeStyle = baseTitleLargeStyle?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          );
                          final titleMediumStyle =
                              (baseTitleMediumStyle ?? baseTitleLargeStyle)
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  );
                          final coverHeight =
                              (maxHeight - topPadding - bottomPadding - 6.0)
                                  .clamp(130.0, 230.0)
                                  .toDouble();
                          final coverWidth = (coverHeight * (2 / 3)).toDouble();
                          final useTitleMedium = maxHeight < 320;
                          final ratingValue =
                              (widget.collectionStatus?.rating ?? 0).clamp(
                                0,
                                5,
                              );

                          return Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                topPadding,
                                20,
                                bottomPadding,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Hero(
                                    tag: heroTag,
                                    child: GestureDetector(
                                      onTap: _openCoverGallery,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: imageUrl != null
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.28,
                                                          ),
                                                      blurRadius: 22,
                                                      offset: const Offset(
                                                        0,
                                                        10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  width: coverWidth,
                                                  height: coverHeight,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                width: coverWidth,
                                                height: coverHeight,
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 40,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: horizontalGap),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          textAlign: TextAlign.left,
                                          softWrap: true,
                                          style: useTitleMedium
                                              ? titleMediumStyle
                                              : titleLargeStyle,
                                        ),
                                        SizedBox(height: subtitleGap),
                                        Text(
                                          _subtitle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                shadows: const [
                                                  Shadow(
                                                    color: Colors.black45,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                        ),
                                        SizedBox(height: titleGap),
                                        Row(
                                          children: [
                                            Icon(
                                              (widget
                                                          .collectionStatus
                                                          ?.isCollected ??
                                                      false)
                                                  ? Icons.inventory_2
                                                  : Icons.inventory_2_outlined,
                                              size: 20,
                                              color:
                                                  (widget
                                                          .collectionStatus
                                                          ?.isCollected ??
                                                      false)
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Colors.white70,
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              (widget
                                                          .collectionStatus
                                                          ?.isRead ??
                                                      false)
                                                  ? Icons.bookmark_added
                                                  : Icons
                                                        .bookmark_added_outlined,
                                              size: 20,
                                              color:
                                                  (widget
                                                          .collectionStatus
                                                          ?.isRead ??
                                                      false)
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Colors.white70,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: List.generate(5, (index) {
                                            final isFilled =
                                                index < ratingValue;
                                            return Icon(
                                              isFilled
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 18,
                                              color: isFilled
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Colors.white70,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                child: Material(
                  color: colorScheme.surface,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'About'),
                      Tab(text: 'My Details'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            Builder(
              builder: (context) => CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey('issue-about-tab'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                    sliver: SliverList.list(
                      children: [
                        IssueAboutTabContent(
                          issue: widget.issue,
                          issueId: widget.issueId,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) => CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                key: const PageStorageKey('issue-my-details-tab'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                    sliver: SliverList.list(
                      children: [
                        IssueMyDetailsTabContent(
                          issueId: widget.issueId,
                          collectionStatus: widget.collectionStatus,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabBarHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _IssueDetailsLoading extends StatelessWidget {
  const _IssueDetailsLoading({required this.issueId, required this.imageUrl});

  final int issueId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundTint = Theme.of(context).scaffoldBackgroundColor;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: _IssueDetailsBodyState._expandedHeight,
          backgroundColor: colorScheme.surface,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  ColoredBox(color: colorScheme.surfaceContainerHighest),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundTint.withValues(alpha: 0.44),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.55, 1],
                      colors: [
                        Colors.black.withValues(alpha: 0.56),
                        Colors.black.withValues(alpha: 0.30),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxHeight = constraints.maxHeight;
                    if (maxHeight < 180) {
                      return const SizedBox.shrink();
                    }

                    final topPadding = (maxHeight * 0.18)
                        .clamp(20.0, 72.0)
                        .toDouble();
                    final bottomPadding = (maxHeight * 0.05)
                        .clamp(10.0, 20.0)
                        .toDouble();
                    final horizontalGap = maxHeight < 320 ? 14.0 : 18.0;
                    final coverHeight =
                        (maxHeight - topPadding - bottomPadding - 6.0)
                            .clamp(130.0, 230.0)
                            .toDouble();
                    final coverWidth = (coverHeight * (2 / 3)).toDouble();

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          topPadding,
                          20,
                          bottomPadding,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'issue-cover-$issueId',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl!,
                                        width: coverWidth,
                                        height: coverHeight,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: coverWidth,
                                        height: coverHeight,
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: horizontalGap),
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
