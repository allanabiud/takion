import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/library/providers/reading_history_provider.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

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

  Map<String, List<dynamic>> _groupEntries(List<dynamic> entries) {
    final Map<String, List<dynamic>> grouped = {};
    for (final entry in entries) {
      final date = entry.readAt ?? entry.item.modified ?? DateTime.now();
      String key;
      switch (_filter) {
        case HistoryFilter.day:
          key = DateFormat.yMMMd().format(date);
          break;
        case HistoryFilter.week:
          final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
          key = 'Week of ${DateFormat.yMMMd().format(startOfWeek)}';
          break;
        case HistoryFilter.month:
          key = DateFormat.yMMMM().format(date);
          break;
        case HistoryFilter.year:
          key = DateFormat.y().format(date);
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
          errorMessage: TakionAlerts.cleanError(error, fallback: 'Failed to load reading history'),
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

          return SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                ...keys.map((key) {
                  final items = grouped[key]!;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final issue = item.item.issue;
                        final issueList = IssueList(
                          id: issue?.id,
                          name: issue?.series?.name ?? 'Unknown',
                          number: issue?.number ?? '',
                          series: null,
                          coverDate: issue?.coverDate,
                          storeDate: issue?.storeDate,
                          image: issue?.image,
                          modified: issue?.modified,
                        );
                        return IssueListTile(
                          issue: issueList,
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
