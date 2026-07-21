import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/features/library/providers/library_insights_provider.dart';
import 'package:takion/src/presentation/features/library/widgets/streak_calendar_widget.dart';
import 'package:takion/src/presentation/features/library/widgets/reading_goal_card.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/features/library/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/library/widgets/library_charts.dart';
import 'package:takion/src/presentation/features/library/widgets/insight_row.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';

@RoutePage()
class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Comics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BROWSE'),
            Tab(text: 'ACTIVITY'),
            Tab(text: 'STATS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReadBrowseTab(),
          const ActivityLogView(typeFilter: ActivityEventType.read),
          _ReadStatsTab(),
        ],
      ),
    );
  }
}

class _ReadBrowseTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(readSeriesProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.libraryRead),
    );

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load read series'),
      data: (seriesList) {
        final sortedResults = sortSeries(
          seriesList
              .map(
                (s) => SeriesList(
                  id: s.seriesId,
                  name: s.seriesName,
                  volume: s.volume,
                  yearBegan: s.yearBegan,
                  issueCount: s.categoryCount,
                ),
              )
              .toList(),
          sortOption,
        );
        if (sortedResults.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(readSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.bookmark_added,
                    message: 'No read comics in your collection yet.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(readSeriesProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: sortedResults.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListHeader(
                    count: sortedResults.length,
                    unit: 'series',
                    pluralUnit: 'series',
                    enabled: true,
                    sortLabel: seriesSortLabel(sortOption),
                    onSortTap: () => showSortBottomSheet(
                      context,
                      ref,
                      SortPreferenceContext.libraryRead,
                      seriesSortLabel,
                    ),
                  ),
                );
              }
              final summary = sortedResults[index - 1];
              return SeriesListTile(
                series: summary,
                categoryCount: summary.issueCount,
                categoryLabel: 'read',
                isFirst: index == 1,
                isLast: index == sortedResults.length,
                onTap: () => context.pushRoute(
                  LibrarySeriesRoute(
                    seriesId: summary.id,
                    category: 'read',
                    seriesName: summary.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReadStatsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReadStatsTab> createState() => _ReadStatsTabState();
}

class _ReadStatsTabState extends ConsumerState<_ReadStatsTab> {
  LibraryFilter _filter = LibraryFilter.month;
  LibraryInsights? _cachedInsights;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(libraryInsightsProvider(_filter));

    if (insightsAsync.hasValue) {
      _cachedInsights = insightsAsync.value;
    }

    final theme = Theme.of(context);
    final insights = insightsAsync.asData?.value ?? _cachedInsights;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(libraryInsightsProvider(_filter)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: LibraryFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        f == LibraryFilter.allTime
                            ? 'All-Time'
                            : f.name[0].toUpperCase() + f.name.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: _filter == f,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _filter = f);
                        }
                      },
                      shape: const StadiumBorder(),
                      showCheckmark: true,
                    ),
                  );
                }).toList(),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_filter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (insightsAsync.hasError)
                      AsyncStatePanel.error(
                        errorMessage: 'Failed to load stats',
                      )
                    else if (insightsAsync.isLoading && _cachedInsights == null)
                      const AsyncStatePanel.loading()
                    else if (insights != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.menu_book,
                                    value: '${insights.readsInPeriod}',
                                    label: 'Read',
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.percent,
                                    value:
                                        '${insights.readPercent.toStringAsFixed(0)}%',
                                    label: 'Read %',
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.star_half,
                                    value: insights.averageRating > 0
                                        ? insights.averageRating
                                              .toStringAsFixed(1)
                                        : '--',
                                    label: 'Rating',
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            if (insights.readingTrends.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(title: 'READING TRENDS'),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ReadingTrendChart(
                                  data: insights.readingTrends,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            const StreakCalendarWidget(),
                            const SizedBox(height: 24),
                            ReadingGoalCard(filter: _filter),
                            const SizedBox(height: 24),
                            SectionHeader(title: 'READING INSIGHTS'),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InsightRow(
                                  label: 'Current Streak',
                                  value: '${insights.streakDays} Days',
                                  icon: Icons.local_fire_department,
                                  iconColor: Colors.orange,
                                ),
                                if (insights.averageRating > 0) ...[
                                  const SizedBox(height: 16),
                                  InsightRow(
                                    label: 'Avg Rating',
                                    value: insights.averageRating
                                        .toStringAsFixed(2),
                                    icon: Icons.star,
                                    iconColor: Colors.amber,
                                  ),
                                ],
                                if (insights.mostReadSeries != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.collections_bookmark_outlined,
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Most-Read Series',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 180,
                                        ),
                                        child: Text(
                                          insights.mostReadSeriesYear != null &&
                                                  insights.mostReadSeriesYear! >
                                                      0
                                              ? '${insights.mostReadSeries} (${insights.mostReadSeriesYear})'
                                              : insights.mostReadSeries!,
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            if (insights.recentlyFinished.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SectionHeader(title: 'RECENTLY FINISHED'),
                              const SizedBox(height: 8),
                              ...insights.recentlyFinished.map(
                                (item) => IssueListTile(
                                  issue: IssueList(
                                    id: item.issue?.id ?? 0,
                                    name:
                                        item.issue?.series?.name ??
                                        item.issue?.number ??
                                        '',
                                    number: item.issue?.number ?? '',
                                    series: item.issue?.series != null
                                        ? Series(
                                            id: 0,
                                            name: item.issue!.series!.name,
                                            volume: item.issue!.series!.volume,
                                            yearBegan:
                                                item.issue!.series!.yearBegan,
                                          )
                                        : null,
                                    image: item.issue?.image,
                                    coverDate: item.issue?.coverDate,
                                    storeDate: item.issue?.storeDate,
                                    modified: null,
                                  ),
                                  isCollected: item.quantity > 0,
                                  isRead: item.isRead,
                                  rating: item.rating,
                                  onTap: item.issue?.id != null
                                      ? () => context.pushRoute(
                                          IssueDetailsRoute(
                                            issueId: item.issue!.id,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
