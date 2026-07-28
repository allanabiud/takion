import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/features/library/activity_log_group.dart';
import 'package:takion/src/presentation/features/library/providers/library_activity_provider.dart';
import 'package:takion/src/presentation/features/library/widgets/activity_log_group_tile.dart';

class ActivityLogView extends ConsumerWidget {
  final ActivityEventType? typeFilter;

  const ActivityLogView({super.key, required this.typeFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider(typeFilter));

    return activityAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load activity'),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: EmptyContentState(
              icon: Icons.history,
              message: 'No activity yet.',
            ),
          );
        }

        final groups = groupActivityEvents(events);

        final flatItems = <_ActivityLogItem>[];
        for (int i = 0; i < groups.length; i++) {
          final group = groups[i];

          final isNewDate = i == 0 || groups[i].date != groups[i - 1].date;
          if (isNewDate) {
            flatItems.add(_ActivityLogItem.header(group.date));
          }

          final isFirstInDate = isNewDate;
          final isLastInDate =
              i == groups.length - 1 || groups[i + 1].date != group.date;

          flatItems.add(
            _ActivityLogItem.group(
              group: group,
              isFirst: isFirstInDate,
              isLast: isLastInDate,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(recentActivityProvider(typeFilter)),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: flatItems.length,
            itemBuilder: (context, index) {
              final item = flatItems[index];
              if (item.isHeader) {
                return _buildHeader(context, item.date!);
              } else {
                return ActivityLogGroupTile(
                  group: item.group!,
                  isFirst: item.isFirst,
                  isLast: item.isLast,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        _formatDateHeader(date),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

class _ActivityLogItem {
  final DateTime? date;
  final ActivityLogGroup? group;
  final bool isFirst;
  final bool isLast;

  _ActivityLogItem.header(this.date)
    : group = null,
      isFirst = false,
      isLast = false;

  _ActivityLogItem.group({
    required this.group,
    required this.isFirst,
    required this.isLast,
  }) : date = null;

  bool get isHeader => date != null;
}
