import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/widgets/issue_details/about_tab_content.dart';
import 'package:takion/src/presentation/widgets/issue_details/people_tab_content.dart';
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add action coming soon.')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: issueAsync.when(
        data: (issue) => _IssueDetailsBody(issue: issue, issueId: issueId),
        loading: () =>
            _IssueDetailsLoading(issueId: issueId, imageUrl: initialImageUrl),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Failed to load issue details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(issueDetailsProvider(issueId).notifier).refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IssueDetailsBody extends StatefulWidget {
  const _IssueDetailsBody({required this.issue, required this.issueId});

  final IssueDetails issue;
  final int issueId;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No share URL available for this issue.')),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: _displayTitle()),
    );
  }

  Future<void> _openResourceUrlInBrowser() async {
    final uri = _resourceUri();
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No browser URL available for this issue.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this issue in browser.')),
      );
    }
  }

  void _navigateToSeries() {
    final series = widget.issue.series;
    final seriesName = series?.name.trim();
    if (series == null || seriesName == null || seriesName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No series is linked to this issue.')),
      );
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
      length: 3,
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
                          color: backgroundTint.withValues(alpha: 0.26),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.55, 1],
                            colors: [
                              Colors.black.withValues(alpha: 0.34),
                              Colors.black.withValues(alpha: 0.12),
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
                          final titleMaxLines = maxHeight < 320 ? 1 : 2;
                          final titleGap = maxHeight < 320 ? 8.0 : 12.0;
                          final subtitleGap = maxHeight < 320 ? 2.0 : 6.0;
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
                          final titleMaxWidth =
                              (constraints.maxWidth - 40).clamp(
                                0.0,
                                double.infinity,
                              );
                          final titlePainter = TextPainter(
                            text: TextSpan(text: title, style: titleLargeStyle),
                            maxLines: titleMaxLines,
                            textDirection: Directionality.of(context),
                          )..layout(maxWidth: titleMaxWidth);
                          final useTitleMedium = titlePainter.didExceedMaxLines;
                          final estimatedTitleHeight = titleMaxLines == 2
                              ? 54.0
                              : 34.0;
                          const estimatedSubtitleHeight = 20.0;

                          final coverHeight =
                              (maxHeight -
                                      topPadding -
                                      bottomPadding -
                                      titleGap -
                                      subtitleGap -
                                      estimatedTitleHeight -
                                      estimatedSubtitleHeight -
                                      6.0)
                                  .clamp(96.0, 192.0)
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                  SizedBox(height: titleGap),
                                  Text(
                                    title,
                                    maxLines: titleMaxLines,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: useTitleMedium
                                        ? titleMediumStyle
                                        : titleLargeStyle,
                                  ),
                                  SizedBox(height: subtitleGap),
                                  Text(
                                    _subtitle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
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
                      Tab(text: 'Creators'),
                      Tab(text: 'Characters'),
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
                key: const PageStorageKey('issue-about-tab'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
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
                key: const PageStorageKey('issue-creators-tab'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.list(
                      children: [IssueCreatorsTabContent(issue: widget.issue)],
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) => CustomScrollView(
                key: const PageStorageKey('issue-characters-tab'),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.list(
                      children: [
                        IssueCharactersTabContent(issue: widget.issue),
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
                    color: backgroundTint.withValues(alpha: 0.26),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.55, 1],
                      colors: [
                        Colors.black.withValues(alpha: 0.34),
                        Colors.black.withValues(alpha: 0.12),
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
                    final indicatorGap = maxHeight < 320 ? 10.0 : 14.0;
                    const indicatorHeight = 36.0;
                    final coverHeight =
                        (maxHeight -
                                topPadding -
                                bottomPadding -
                                indicatorGap -
                                indicatorHeight -
                                6.0)
                            .clamp(96.0, 192.0)
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                            SizedBox(height: indicatorGap),
                            const CircularProgressIndicator(),
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
