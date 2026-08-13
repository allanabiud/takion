import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/features/library/activity_log_group.dart';
import 'package:takion/src/presentation/features/library/providers/library_activity_provider.dart';
import 'package:takion/src/presentation/features/library/widgets/activity_log_group_tile.dart';

class ActivityLogView extends ConsumerStatefulWidget {
  final ActivityEventType? typeFilter;

  const ActivityLogView({super.key, required this.typeFilter});

  @override
  ConsumerState<ActivityLogView> createState() => _ActivityLogViewState();
}

class _ActivityLogViewState extends ConsumerState<ActivityLogView>
    with AutomaticKeepAliveClientMixin {
  List<ActivityLogGroup>? _cachedGroups;
  List<LibraryActivityEvent>? _lastEvents;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activityAsync = ref.watch(recentActivityProvider(widget.typeFilter));

    return activityAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) =>
          AsyncStatePanel.error(errorMessage: 'Failed to load activity'),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: EmptyContentState(
              icon: Icons.history,
              message: 'No activity.',
            ),
          );
        }

        if (!identical(_lastEvents, events) && _lastEvents != events) {
          _lastEvents = events;
          _cachedGroups = groupActivityEvents(events);
        }
        final groups = _cachedGroups ?? groupActivityEvents(events);

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(recentActivityProvider(widget.typeFilter)),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return ActivityLogGroupTile(
                group: groups[index],
                isFirst: index == 0,
                isLast: index == groups.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}
