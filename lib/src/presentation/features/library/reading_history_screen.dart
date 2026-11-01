import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/catalog/entities/issue_list.dart";
import "package:takion/src/domain/catalog/entities/series.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/providers/reading_history_provider.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

enum HistoryFilter { day, week, month, year }

@RoutePage()
class ReadingHistoryScreen extends ConsumerStatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  ConsumerState<ReadingHistoryScreen> createState() =>
      _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends ConsumerState<ReadingHistoryScreen> {
  HistoryFilter _filter = HistoryFilter.month;
  final Set<String> _expandedKeys = <String>{};
  bool _hasInitializedExpandedKeys = false;

  Map<String, List<ReadingHistoryEntry>> _groupEntries(
    List<ReadingHistoryEntry> entries,
  ) {
    final Map<String, List<ReadingHistoryEntry>> grouped = {};
    for (final entry in entries) {
      final date = entry.readAt;
      final String key = switch (_filter) {
        HistoryFilter.day => DateFormatter.comicDate(date),
        HistoryFilter.week => () {
          final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
          return "Week of ${DateFormatter.comicDate(startOfWeek)}";
        }(),
        HistoryFilter.month => DateFormat.yMMMM().format(date),
        HistoryFilter.year => DateFormatter.isoDateTime(date).split("-").first,
      };
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  void _onFilterChanged(HistoryFilter newFilter) {
    if (_filter == newFilter) return;
    setState(() {
      _filter = newFilter;
      _expandedKeys.clear();
      _hasInitializedExpandedKeys = false;
    });
  }

  void _toggleGroup(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) {
        _expandedKeys.remove(key);
      } else {
        _expandedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading History"),
        actions: [
          historyAsync.maybeWhen(
            data: (entries) {
              if (entries.isEmpty) return const SizedBox.shrink();
              final grouped = _groupEntries(entries);
              final allKeys = grouped.keys.toSet();
              final isAllExpanded = _expandedKeys.containsAll(allKeys);

              return IconButton(
                icon: Icon(
                  isAllExpanded ? Icons.unfold_less : Icons.unfold_more,
                ),
                tooltip: isAllExpanded ? "Collapse all" : "Expand all",
                onPressed: () => setState(() {
                  if (isAllExpanded) {
                    _expandedKeys.clear();
                  } else {
                    _expandedKeys.addAll(allKeys);
                  }
                }),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: TakionAlerts.cleanError(
            error,
            fallback: "Failed to load reading history",
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyContentState(
              icon: Icons.history_outlined,
              message: "No reading history recorded yet.",
            );
          }

          final grouped = _groupEntries(entries);
          final keys = grouped.keys.toList();

          // By default expand the newest group on first load of a filter
          if (!_hasInitializedExpandedKeys && keys.isNotEmpty) {
            _expandedKeys.add(keys.first);
            _hasInitializedExpandedKeys = true;
          }

          return CustomScrollView(
            slivers: [
              // Filter Chips Header
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: HistoryFilter.values
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                f.name[0].toUpperCase() + f.name.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: _filter == f,
                              onSelected: (_) => _onFilterChanged(f),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              // Smooth Expandable Date Groups List
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 32),
                sliver: SliverList.builder(
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final groupEntries = grouped[key]!;
                    final isExpanded = _expandedKeys.contains(key);

                    return _ReadingHistoryGroupSection(
                      key: ValueKey(key),
                      groupKey: key,
                      entries: groupEntries,
                      isExpanded: isExpanded,
                      onToggle: () => _toggleGroup(key),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadingHistoryGroupSection extends StatelessWidget {
  const _ReadingHistoryGroupSection({
    super.key,
    required this.groupKey,
    required this.entries,
    required this.isExpanded,
    required this.onToggle,
  });

  final String groupKey;
  final List<ReadingHistoryEntry> entries;
  final bool isExpanded;
  final VoidCallback onToggle;

  Widget _buildIssueTile(
    BuildContext context,
    ReadingHistoryEntry entry, {
    required bool isFirst,
    required bool isLast,
  }) {
    final issueList = IssueList(
      id: entry.issueId > 0 ? entry.issueId : null,
      name: entry.seriesName,
      number: entry.issueNumber,
      series: Series(
        id: entry.seriesId,
        name: entry.seriesName,
        volume: entry.seriesVolume,
        yearBegan: entry.seriesYearBegan,
      ),
      coverDate: entry.coverDate,
      storeDate: entry.storeDate,
      image: entry.imageUrl,
      modified: entry.readAt,
    );

    return IssueListTile(
      issue: issueList,
      horizontalPadding: 16,
      isFirst: isFirst,
      isLast: isLast,
      useCardBackground: false,
      isCollected: entry.issueId > 0,
      isRead: true,
      allowRemoteHydration: false,
      rating: entry.rating,
      trailing: Text(
        DateFormatter.comicDate(entry.readAt),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      onTap: entry.issueId > 0
          ? () => context.pushRoute(IssueDetailsRoute(issueId: entry.issueId))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: SectionHeader(
            title: groupKey,
            count: entries.length,
            isExpanded: isExpanded,
            onViewAll: onToggle,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < entries.length; i++)
                      _buildIssueTile(
                        context,
                        entries[i],
                        isFirst: i == 0,
                        isLast: i == entries.length - 1,
                      ),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
