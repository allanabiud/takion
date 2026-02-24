import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/providers/series_details_provider.dart';
import 'package:takion/src/presentation/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

enum _SeriesDetailsMenuAction { share, openInBrowser }

@RoutePage()
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({
    super.key,
    @pathParam required this.seriesId,
  });

  final int seriesId;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  static const _expandedHeight = 268.0;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0;
  int _issuesPage = 1;

  Uri? _resourceUri(SeriesDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No share URL available for this series.')),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No browser URL available for this series.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this series in browser.')),
      );
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

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));

    return detailsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load series details: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (details) => DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add action coming soon.')),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context).colorScheme.surface,
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
                  title: Opacity(
                    opacity: _titleOpacity,
                    child: Text(
                      details.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _SeriesHeader(
                      details: details,
                      seriesId: widget.seriesId,
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SeriesTabBarDelegate(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: const TabBar(
                        tabs: [
                          Tab(text: 'About'),
                          Tab(text: 'Issues'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _SeriesAboutTab(details: details),
                _SeriesIssuesTab(
                  seriesId: widget.seriesId,
                  page: _issuesPage,
                  onPrevious: () {
                    if (_issuesPage <= 1) return;
                    setState(() {
                      _issuesPage = _issuesPage - 1;
                    });
                  },
                  onNext: () {
                    setState(() {
                      _issuesPage = _issuesPage + 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeriesHeader extends ConsumerWidget {
  const _SeriesHeader({required this.details, required this.seriesId});

  final SeriesDetails details;
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final publisher = details.publisher?.name?.trim();
    final hasPublisher = publisher != null && publisher.isNotEmpty;
    final firstPageIssuesAsync = ref.watch(
      seriesIssueListProvider(SeriesIssueListArgs(seriesId: seriesId, page: 1)),
    );
    final firstPageIssues = firstPageIssuesAsync.asData?.value;
    final firstIssueImage =
        firstPageIssues != null && firstPageIssues.results.isNotEmpty
        ? firstPageIssues.results.first.image
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'series-cover-$seriesId',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 132,
                        height: 198,
                        color: colorScheme.surfaceContainerHighest,
                        child: firstIssueImage != null
                            ? CachedNetworkImage(
                                imageUrl: firstIssueImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.name.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hasPublisher)
                            Text(
                              publisher.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          Text(
                            _yearRange(details).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _yearRange(SeriesDetails details) {
    return details.yearEnd != null
        ? '${details.yearBegan ?? '—'}-${details.yearEnd}'
        : '${details.yearBegan ?? '—'}-Present';
  }
}

class _SeriesAboutTab extends StatelessWidget {
  const _SeriesAboutTab({required this.details});

  final SeriesDetails details;

  String _yearRange() {
    final start = details.yearBegan;
    final end = details.yearEnd;

    if (start == null && end == null) return 'Unknown';
    if (start != null && end != null) return '$start - $end';
    if (start != null) return '$start - Present';
    return 'Until $end';
  }

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

  List<({String label, String value})> _gridItems() {
    final items = <({String label, String value})>[];

    void addString(String label, String? value) {
      final text = value?.trim();
      if (text == null || text.isEmpty) return;
      items.add((label: label, value: text));
    }

    void addInt(String label, int? value) {
      if (value == null) return;
      items.add((label: label, value: '$value'));
    }

    addString('STATUS', details.status);
    addInt('VOLUME', details.volume);
    if (details.yearBegan != null || details.yearEnd != null) {
      items.add((label: 'YEARS', value: _yearRange()));
    }
    addString('TYPE', details.seriesType?.name);
    addInt('ISSUES', details.issueCount);
    addString('PUBLISHER', details.publisher?.name);
    addString('IMPRINT', details.imprint?.name);
    items.add((label: 'METRON ID', value: '${details.id}'));
    addInt('CV ID', details.cvId);
    addInt('GCD ID', details.gcdId);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final description = details.description?.trim();
    final associated = details.associated
        .where((entry) => entry.series.trim().isNotEmpty)
        .toList();
    final gridItems = _gridItems();
    final modifiedValue = _modifiedValue();
    final hasDescription = description != null && description.isNotEmpty;
    final hasGrid = gridItems.isNotEmpty;
    final hasGenres = details.genres.isNotEmpty;
    final hasAssociated = associated.isNotEmpty;
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (hasDescription) ...[
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(description),
        ],
        if (hasDescription && (hasGrid || hasGenres || hasAssociated || hasModified))
          const SizedBox(height: 16),
        if (hasGrid)
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: gridItems
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.value,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        if (hasGrid && (hasGenres || hasAssociated || hasModified))
          const SizedBox(height: 14),
        if (hasGenres) ...[
          Text(
            'Genres',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.genres
                .map((genre) => Chip(label: Text(genre.name)))
                .toList(),
          ),
        ],
        if (hasGenres && (hasAssociated || hasModified)) const SizedBox(height: 14),
        if (hasAssociated) ...[
          Text(
            'Associated Series',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: associated
                .map(
                  (entry) => ActionChip(
                    label: Text(entry.series),
                    onPressed: entry.id == details.id
                        ? null
                        : () {
                            context.pushRoute(
                              SeriesDetailsRoute(seriesId: entry.id),
                            );
                          },
                  ),
                )
                .toList(),
          )
        ],
        if (hasAssociated && hasModified) const SizedBox(height: 14),
        if (hasModified)
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        if (!hasDescription && !hasGrid && !hasGenres && !hasAssociated && !hasModified)
          Text(
            'No about information available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _SeriesIssuesTab extends ConsumerWidget {
  const _SeriesIssuesTab({
    required this.seriesId,
    required this.page,
    required this.onPrevious,
    required this.onNext,
  });

  final int seriesId;
  final int page;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = SeriesIssueListArgs(seriesId: seriesId, page: page);
    final issuesAsync = ref.watch(seriesIssueListProvider(args));

    return issuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to load series issues: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (issuePage) {
        final totalPages = ((issuePage.count /
                    (issuePage.results.isEmpty ? 100 : issuePage.results.length))
                .ceil())
            .clamp(1, 9999);

        return Column(
          children: [
            Expanded(
              child: issuePage.results.isEmpty
                  ? const Center(child: Text('No issues available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: issuePage.results.length,
                      itemBuilder: (context, index) {
                        final issue = issuePage.results[index];
                        return IssueListTile(
                          issue: issue,
                          isFirst: index == 0,
                          isLast: index == issuePage.results.length - 1,
                        );
                      },
                    ),
            ),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: issuePage.hasPrevious ? onPrevious : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                    ),
                    const Spacer(),
                    Text('Page $page of $totalPages'),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: issuePage.hasNext ? onNext : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SeriesTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SeriesTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SeriesTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
