import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/reading_history_provider.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';

enum HistoryFilter { day, week, month, year }

@RoutePage()
class ReadingHistoryScreen extends ConsumerStatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  ConsumerState<ReadingHistoryScreen> createState() =>
      _ReadingHistoryScreenState();
}

class _AnimatedExpandable extends StatelessWidget {
  const _AnimatedExpandable({
    required this.expanded,
    required this.child,
  });

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

class _ReadingHistoryScreenState extends ConsumerState<ReadingHistoryScreen> {
  HistoryFilter _filter = HistoryFilter.month;
  final Set<String> _expandedKeys = {};
  bool _seededExpanded = false;

  Map<String, List<dynamic>> _groupEntries(List<dynamic> entries) {
    final Map<String, List<dynamic>> grouped = {};
    for (final entry in entries) {
      final date = entry.readAt ?? entry.item.modified ?? DateTime.now();
      String key;
      switch (_filter) {
        case HistoryFilter.day:
          key = DateFormatter.comicDate(date);
          break;
        case HistoryFilter.week:
          final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
          key = 'Week of ${DateFormatter.comicDate(startOfWeek)}';
          break;
        case HistoryFilter.month:
          key = DateFormat.yMMMM().format(date);
          break;
        case HistoryFilter.year:
          key = DateFormatter.isoDateTime(date).split('-').first;
          break;
      }
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(readingHistoryCollectionItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reading History')),
      body: historyAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: TakionAlerts.cleanError(
            error,
            fallback: 'Failed to load reading history',
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyContentState(
              icon: Icons.history_outlined,
              message: 'No history.',
            );
          }

          final grouped = _groupEntries(entries);
          final keys = grouped.keys.toList();

          if (!_seededExpanded) {
            _seededExpanded = true;
            _expandedKeys.addAll(keys);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                              onSelected: (_) => setState(() => _filter = f),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                ...keys.map((key) {
                  final items = grouped[key]!;
                  final isExpanded = _expandedKeys.contains(key);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SectionHeader(
                          title: key,
                          isExpanded: isExpanded,
                          onViewAll: () => setState(() {
                            if (isExpanded) {
                              _expandedKeys.remove(key);
                            } else {
                              _expandedKeys.add(key);
                            }
                          }),
                        ),
                      ),
                      _AnimatedExpandable(
                        expanded: isExpanded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final issue = item.item.issue;
                            final issueList = IssueList(
                              id: issue?.id,
                              name: issue?.series?.name ?? 'Unknown',
                              number: issue?.number ?? '',
                              series: issue?.series != null
                                  ? Series(
                                      id: issue!.series!.id ?? 0,
                                      name: issue!.series!.name,
                                      volume: issue!.series!.volume,
                                      yearBegan: issue!.series!.yearBegan,
                                    )
                                  : null,
                              coverDate: issue?.coverDate,
                              storeDate: issue?.storeDate,
                              image: issue?.image,
                              modified: issue?.modified,
                            );
                            return IssueListTile(
                              issue: issueList,
                              horizontalPadding: 16,
                              isFirst: index == 0,
                              isLast: index == items.length - 1,
                              useCardBackground: false,
                              isCollected: issue?.id != null,
                              isRead: true,
                              onTap: issue?.id != null
                                  ? () => context.pushRoute(
                                      IssueDetailsRoute(issueId: issue!.id),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
