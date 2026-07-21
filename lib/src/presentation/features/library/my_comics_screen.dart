import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/category_series_providers.dart';
import 'package:takion/src/presentation/features/library/activity_log_view.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/features/profile/widgets/stat_card.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_charts.dart';
import 'package:takion/src/presentation/features/profile/widgets/top_entity_tile.dart';
import 'package:takion/src/presentation/features/profile/screens/top_characters_screen.dart';
import 'package:takion/src/presentation/features/profile/screens/top_creators_screen.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';

@RoutePage()
class MyComicsScreen extends ConsumerStatefulWidget {
  const MyComicsScreen({super.key});

  @override
  ConsumerState<MyComicsScreen> createState() => _MyComicsScreenState();
}

class _MyComicsScreenState extends ConsumerState<MyComicsScreen>
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
        title: const Text('My Comics'),
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
          _MyComicsBrowseTab(),
          const ActivityLogView(typeFilter: ActivityEventType.collected),
          _MyComicsStatsTab(),
        ],
      ),
    );
  }
}

class _MyComicsBrowseTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(collectedSeriesProvider);

    return seriesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load collected series',
      ),
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(collectedSeriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyContentState(
                    icon: Icons.library_books_outlined,
                    message: 'No comics in your collection yet.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collectedSeriesProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: seriesList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListHeader(
                    count: seriesList.length,
                    unit: 'series',
                    pluralUnit: 'series',
                    enabled: true,
                  ),
                );
              }
              final summary = seriesList[index - 1];
              return SeriesListTile(
                series: SeriesList(
                  id: summary.seriesId,
                  name: summary.seriesName,
                  volume: summary.volume,
                  yearBegan: summary.yearBegan,
                  issueCount: summary.categoryCount,
                ),
                categoryCount: summary.categoryCount,
                categoryLabel: 'collected',
                isFirst: index == 1,
                isLast: index == seriesList.length,
                onTap: () => context.pushRoute(
                  LibrarySeriesRoute(
                    seriesId: summary.seriesId,
                    category: 'collected',
                    seriesName: summary.seriesName,
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



class _MyComicsStatsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MyComicsStatsTab> createState() => _MyComicsStatsTabState();
}

class _MyComicsStatsTabState extends ConsumerState<_MyComicsStatsTab> {
  ProfileFilter _filter = ProfileFilter.month;
  ProfileInsights? _cachedInsights;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(profileInsightsProvider(_filter));
    final collectionStatsAsync = ref.watch(collectionStatsProvider);
    final theme = Theme.of(context);

    if (insightsAsync.hasValue) {
      _cachedInsights = insightsAsync.value;
    }

    final insights = insightsAsync.asData?.value ?? _cachedInsights;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileInsightsProvider(_filter));
        ref.invalidate(collectionStatsProvider);
      },
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
                children: ProfileFilter.values.map((f) {

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        f == ProfileFilter.allTime
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
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 16.0),
                          child: Text(
                            TakionAlerts.cleanError(insightsAsync.error!, fallback: 'Failed to load stats'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else if (insightsAsync.isLoading && _cachedInsights == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 64.0, horizontal: 16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
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
                                  icon: Icons.inventory_2,
                                  value: '${insights.totalOwned}',
                                  label: 'Comics',
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.shopping_bag_outlined,
                                  value: '${insights.pullsInPeriod}',
                                  label: 'Pulls',
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.notifications_outlined,
                                  value: '${insights.subscriptionsCount}',
                                  label: 'Subscriptions',
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.account_balance_wallet_outlined,
                                  value: collectionStatsAsync.asData?.value.totalValue ?? '\$0.00',
                                  label: 'Value',
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          if (insights.topPublishers.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            SectionHeader(title: 'TOP PUBLISHERS'),
                            const SizedBox(height: 12),
                            StatBarTable(items: insights.topPublishers),
                          ],
                          if (insights.topCharacters.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: 'TOP CHARACTERS',
                              onViewAll: insights.allCharacters.length > 5
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => TopCharactersScreen(
                                            characters: insights.allCharacters,
                                          ),
                                        ),
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            ...insights.topCharacters.asMap().entries.map((entry) =>
                              TopEntityTile(
                                index: entry.key,
                                entity: entry.value,
                                isCharacter: true,
                                isLast: entry.key == insights.topCharacters.length - 1 &&
                                    insights.allCharacters.length <= 5,
                              ),
                            ),
                          ],
                          if (insights.topCreators.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: 'TOP CREATORS',
                              onViewAll: insights.allCreators.length > 5
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => TopCreatorsScreen(
                                            creators: insights.allCreators,
                                          ),
                                        ),
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            ...insights.topCreators.asMap().entries.map((entry) =>
                              TopEntityTile(
                                index: entry.key,
                                entity: entry.value,
                                isCharacter: false,
                                isLast: entry.key == insights.topCreators.length - 1 &&
                                    insights.allCreators.length <= 5,
                              ),
                            ),
                          ],
                          if (insights.recentlyFinished.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            SectionHeader(title: 'RECENTLY FINISHED'),
                            const SizedBox(height: 8),
                            ...insights.recentlyFinished.map((item) => IssueListTile(
                              issue: IssueList(
                                id: item.issue?.id ?? 0,
                                name: item.issue?.series?.name ?? item.issue?.number ?? '',
                                number: item.issue?.number ?? '',
                                series: item.issue?.series != null
                                    ? Series(
                                        id: 0,
                                        name: item.issue!.series!.name,
                                        volume: item.issue!.series!.volume,
                                        yearBegan: item.issue!.series!.yearBegan,
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
                                        IssueDetailsRoute(issueId: item.issue!.id),
                                      )
                                  : null,
                            )),
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

