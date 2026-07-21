import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/components/components.dart';

@RoutePage()
class LibrarySeriesScreen extends ConsumerWidget {
  const LibrarySeriesScreen({
    super.key,
    @pathParam required this.seriesId,
    @pathParam required this.category,
    @pathParam this.seriesName,
  });

  final int seriesId;
  final String category;
  final String? seriesName;

  String get _categoryLabel {
    switch (category) {
      case 'collected':
        return 'Collected';
      case 'read':
        return 'Read';
      case 'wishlist':
        return 'Wishlisted';
      case 'unread':
        return 'Unread';
      case 'unrated':
        return 'Unrated';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(seriesDetailsProvider(seriesId));
    final categorySeriesAsync = ref.watch(seriesByCategoryProvider(category));
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider((
        seriesId: seriesId,
        allowRemoteFetch: true,
      )),
    );

    return DetailScreenShell<SeriesDetails>(
      asyncValue: detailsAsync,
      entityType: 'series',
      initialChildSize: 0.60,
      headerHeight: 350,
      showHero: false,
      toImageUrl: (d) => null,
      toHeroTag: (d) => 'library-series-${d.id}',
      toTitle: (d) =>
          '${d.name.toUpperCase()} (${d.yearBegan ?? ''})',
      appBarTrailingAction: (d) => IconButton(
        icon: const Icon(Icons.open_in_new),
        tooltip: 'View full series details',
        onPressed: () => context.pushRoute(
          SeriesDetailsRoute(seriesId: seriesId),
        ),
      ),
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
            if (d.issueCount != null && d.issueCount! > 0)
              _CategoryProgressBar(
                categoryLabel: _categoryLabel,
                seriesId: seriesId,
                total: d.issueCount!,
              ),
          ],
        );
      },
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
                ),
          loading: () =>
              Container(color: Theme.of(context).colorScheme.surface),
          error: (_, _) => Container(
            color: Theme.of(context).colorScheme.surface,
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
        return [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CategoryIssueList(
                seriesId: seriesId,
                category: category,
                categoryLabel: _categoryLabel,
                categorySeriesAsync: categorySeriesAsync,
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _CategoryProgressBar extends ConsumerWidget {
  const _CategoryProgressBar({
    required this.categoryLabel,
    required this.seriesId,
    required this.total,
  });

  final String categoryLabel;
  final int seriesId;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySeriesAsync = ref.watch(
      seriesByCategoryProvider('collected'),
    );

    return categorySeriesAsync.when(
      loading: () => const SizedBox(height: 24),
      error: (_, _) => const SizedBox(height: 24),
      data: (seriesList) {
        final match = seriesList.where((s) => s.seriesId == seriesId).firstOrNull;
        final count = match?.categoryCount ?? 0;
        final percent = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${categoryLabel.toUpperCase()}: $count / $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryIssueList extends ConsumerWidget {
  const _CategoryIssueList({
    required this.seriesId,
    required this.category,
    required this.categoryLabel,
    required this.categorySeriesAsync,
  });

  final int seriesId;
  final String category;
  final String categoryLabel;
  final AsyncValue<List<CategorySeriesSummary>> categorySeriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categorySeriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Failed to load issues'),
      data: (seriesList) {
        final match = seriesList.where((s) => s.seriesId == seriesId).firstOrNull;
        if (match == null || match.items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Text(
                'No $categoryLabel issues in this series.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'ISSUES',
              badge: '(${match.items.length})',
            ),
            const SizedBox(height: 8),
            ...match.items.map((item) {
              final index = match.items.indexOf(item);
              return IssueListTile(
                issue: item.toIssueList(),
                isFirst: index == 0,
                isLast: index == match.items.length - 1,
                isCollected: item.quantity > 0,
                isRead: item.isRead,
                rating: item.rating,
              );
            }),
          ],
        );
      },
    );
  }
}

extension _CollectionItemToIssueList on CollectionItem {
  IssueList toIssueList() {
    return IssueList(
      id: issue?.id ?? 0,
      name: issue?.series?.name ?? issue?.number ?? '',
      number: issue?.number ?? '',
      image: issue?.image,
      coverDate: issue?.coverDate,
      storeDate: issue?.storeDate,
      series: issue?.series != null
          ? Series(
              id: 0,
              name: issue!.series!.name,
              volume: issue!.series!.volume,
              yearBegan: issue!.series!.yearBegan,
            )
          : null,
      modified: null,
    );
  }
}
