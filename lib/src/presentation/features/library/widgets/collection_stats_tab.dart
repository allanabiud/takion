import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/widgets/library_charts.dart";
import "package:takion/src/presentation/features/library/widgets/stat_card.dart";
import "package:takion/src/presentation/features/library/widgets/stats_skeleton.dart";
import "package:takion/src/presentation/features/library/widgets/top_entity_tile.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class CollectionStatsTab extends ConsumerStatefulWidget {
  const CollectionStatsTab({super.key});

  @override
  ConsumerState<CollectionStatsTab> createState() => _CollectionStatsTabState();
}

class _CollectionStatsTabState extends ConsumerState<CollectionStatsTab> {
  LibraryFilter _filter = LibraryFilter.allTime;

  void _showRecapCard(
    BuildContext context,
    LibraryBasicStats stats,
    CollectionStats? colStats,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Comic Recap",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _filter == LibraryFilter.week
                    ? "This Week in Comics"
                    : _filter == LibraryFilter.month
                    ? "This Month in Comics"
                    : _filter == LibraryFilter.year
                    ? "This Year in Comics"
                    : "All-Time Comic Journey",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _RecapStatBox(
                      label: "Read",
                      value: "${stats.readsInPeriod}",
                      icon: Icons.bookmark_added,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RecapStatBox(
                      label: "Streak",
                      value: "${stats.streakDays}d",
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RecapStatBox(
                      label: "Owned",
                      value: "${stats.totalOwned}",
                      icon: Icons.inventory_2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RecapStatBox(
                      label: "Rating",
                      value: stats.averageRating > 0
                          ? stats.averageRating.toStringAsFixed(1)
                          : "--",
                      icon: Icons.star,
                    ),
                  ),
                ],
              ),
              if (stats.mostReadSeries != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Series",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.mostReadSeries!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basicStatsAsync = ref.watch(libraryBasicStatsProvider(_filter));
    final collectionStatsAsync = ref.watch(collectionStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SegmentedButton<LibraryFilter>(
                  segments: const [
                    ButtonSegment(
                      value: LibraryFilter.week,
                      label: Text("Week"),
                    ),
                    ButtonSegment(
                      value: LibraryFilter.month,
                      label: Text("Month"),
                    ),
                    ButtonSegment(
                      value: LibraryFilter.year,
                      label: Text("Year"),
                    ),
                    ButtonSegment(
                      value: LibraryFilter.allTime,
                      label: Text("All"),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selected) {
                    if (selected.isNotEmpty) {
                      setState(() => _filter = selected.first);
                    }
                  },
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: "Comic Recap",
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  onPressed: () {
                    final stats =
                        basicStatsAsync.value ??
                        LibraryBasicStats.zero(_filter);
                    _showRecapCard(context, stats, collectionStatsAsync.value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StatsCards(filter: _filter),
          const SizedBox(height: 24),
          _ReadingTrendsSection(filter: _filter),
          const SizedBox(height: 24),
          _SpendingTrendsSection(filter: _filter),
          const SizedBox(height: 24),
          _TopPublishersSection(),
          const SizedBox(height: 24),
          _TopCreatorsSection(),
          const SizedBox(height: 24),
          _FormatBreakdownSection(),
        ],
      ),
    );
  }
}

class _RecapStatBox extends StatelessWidget {
  const _RecapStatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCards extends ConsumerWidget {
  const _StatsCards({required this.filter});
  final LibraryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basicStatsAsync = ref.watch(libraryBasicStatsProvider(filter));
    final collectionStatsAsync = ref.watch(collectionStatsProvider);
    final theme = Theme.of(context);

    final stats = basicStatsAsync.value ?? LibraryBasicStats.zero(filter);
    final totalVal = collectionStatsAsync.hasValue
        ? collectionStatsAsync.value!.totalValue
        : r"$0.00";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.inventory_2,
                  value: "${stats.totalOwned}",
                  label: "Comics",
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.bookmark_added,
                  value: "${stats.readsInPeriod}",
                  label: "Read",
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
                  icon: Icons.local_fire_department,
                  value: "${stats.streakDays}d",
                  label: "Streak",
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  value: totalVal,
                  label: "Value",
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingTrendsSection extends ConsumerWidget {
  const _ReadingTrendsSection({required this.filter});
  final LibraryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(libraryReadingTrendsProvider(filter));

    return trendsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 12),
              SizedBox(height: 140, child: Card(child: SizedBox.expand())),
            ],
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (trends) {
        if (trends.isEmpty || trends.every((t) => t.count == 0)) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "READING VELOCITY"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ReadingTrendChart(data: trends),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpendingTrendsSection extends ConsumerWidget {
  const _SpendingTrendsSection({required this.filter});
  final LibraryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(librarySpendingTrendsProvider(filter));

    return trendsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderSkeleton(),
              SizedBox(height: 12),
              SizedBox(height: 140, child: Card(child: SizedBox.expand())),
            ],
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (trends) {
        if (trends.isEmpty || trends.every((t) => t.amount == 0)) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "SPENDING"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SpendingTrendChart(data: trends),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopPublishersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityStatsAsync = ref.watch(libraryEntityStatsProvider);

    return entityStatsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entityStats) {
        if (entityStats.topPublishers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "TOP PUBLISHERS"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatBarTable(items: entityStats.topPublishers),
            ),
          ],
        );
      },
    );
  }
}

class _TopCreatorsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityStatsAsync = ref.watch(libraryEntityStatsProvider);

    return entityStatsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entityStats) {
        if (entityStats.topCreators.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "TOP CREATORS"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: entityStats.topCreators
                    .asMap()
                    .entries
                    .map(
                      (entry) => TopEntityTile(
                        index: entry.key + 1,
                        entity: entry.value,
                        isCharacter: false,
                        isLast: entry.key == entityStats.topCreators.length - 1,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FormatBreakdownSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(collectionStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.byFormat.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(title: "FORMATS"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatBarTable(
                items: stats.byFormat
                    .map((e) => MapEntry(e.bookFormat.toUpperCase(), e.count))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
