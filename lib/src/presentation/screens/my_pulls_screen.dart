import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/widgets/weekly_issue_list_scaffold.dart';

@RoutePage()
class MyPullsScreen extends ConsumerWidget {
  const MyPullsScreen({super.key});

  Future<void> _addPulledToCollection(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) async {
    try {
      final pulls = await ref.read(
        pullsIssuesForWeekProvider(selectedDate).future,
      );
      final libraryRepository = ref.read(libraryRepositoryProvider);
      var affected = 0;

      for (final issue in pulls) {
        final issueId = issue.id;
        final seriesId = issue.series?.id;
        if (issueId == null || seriesId == null) continue;

        final existing = await libraryRepository.getItemByIssueId(issueId);
        final isCollected =
            existing?.ownershipStatus == LibraryOwnershipStatus.owned;
        if (isCollected) continue;

        await libraryRepository.upsertItem(
          metronIssueId: issueId,
          metronSeriesId: seriesId,
          ownershipStatus: LibraryOwnershipStatus.owned,
          isRead: existing?.isRead ?? false,
          rating: existing?.rating,
          purchaseDate: existing?.purchaseDate,
          pricePaid: existing?.pricePaid,
          quantityOwned: existing?.quantityOwned ?? 1,
          format: existing?.format ?? LibraryItemFormat.print,
          firstReadAt: existing?.firstReadAt,
          conditionGrade: existing?.conditionGrade,
          acquiredOn: existing?.acquiredOn ?? DateTime.now().toUtc(),
          notes: existing?.notes,
        );
        affected++;
      }
      await invalidateLibraryItemsLocalCacheWithHive(
        ref.read(hiveServiceProvider),
      );

      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      invalidateLibraryCollectionProvidersForWidget(ref);

      if (!context.mounted) return;
      TakionAlerts.success(
        context,
        '$affected pulled issues added to collection.',
      );
    } catch (error) {
      if (!context.mounted) return;
      TakionAlerts.error(context, 'Failed to add pulled issues: $error');
    }
  }

  Future<void> _markPulledAsRead(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) async {
    try {
      final pulls = await ref.read(
        pullsIssuesForWeekProvider(selectedDate).future,
      );
      final libraryRepository = ref.read(libraryRepositoryProvider);
      var affected = 0;

      for (final issue in pulls) {
        final issueId = issue.id;
        final seriesId = issue.series?.id;
        if (issueId == null || seriesId == null) continue;

        final existing = await libraryRepository.getItemByIssueId(issueId);
        if (existing?.isRead == true) continue;

        final now = DateTime.now().toUtc();
        await libraryRepository.upsertItem(
          metronIssueId: issueId,
          metronSeriesId: seriesId,
          ownershipStatus:
              existing?.ownershipStatus ?? LibraryOwnershipStatus.notOwned,
          isRead: true,
          rating: existing?.rating,
          purchaseDate: existing?.purchaseDate,
          pricePaid: existing?.pricePaid,
          quantityOwned: existing?.quantityOwned ?? 1,
          format: existing?.format ?? LibraryItemFormat.print,
          firstReadAt: existing?.firstReadAt ?? now,
          conditionGrade: existing?.conditionGrade,
          acquiredOn: existing?.acquiredOn ?? now,
          notes: existing?.notes,
        );
        await libraryRepository.addReadLog(metronIssueId: issueId, readAt: now);
        affected++;
      }
      await invalidateLibraryItemsLocalCacheWithHive(
        ref.read(hiveServiceProvider),
      );

      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      invalidateLibraryCollectionProvidersForWidget(ref);

      if (!context.mounted) return;
      TakionAlerts.success(context, '$affected pulled issues marked as read.');
    } catch (error) {
      if (!context.mounted) return;
      TakionAlerts.error(
        context,
        'Failed to mark pulled issues as read: $error',
      );
    }
  }

  void _showPullActionsSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pull Actions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Add Pulled to Collection'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _addPulledToCollection(context, ref, selectedDate);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark_added_outlined),
                  title: const Text('Mark Pulled Issues as Read'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _markPulledAsRead(context, ref, selectedDate);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesMyPulls),
    );
    final pullsAsync = ref.watch(pullsIssuesForWeekProvider(selectedDate));

    return WeeklyIssueListScaffold(
      title: 'My Pulls',
      issuesAsync: pullsAsync,
      transformIssues: (issues) => sortIssues(issues, sortOption),
      emptyMessage: 'No pulls for this week.',
      emptyIcon: Icons.shopping_bag_outlined,
      errorTextBuilder: (error) => 'Failed to load pulls: $error',
      appBarActions: [
        DisplaySettingsButton(
          selectedOption: sortOption,
          optionLabel: issueSortLabel,
          onSelected: (option) {
            ref
                .read(sortPreferencesProvider.notifier)
                .setPreference(SortPreferenceContext.releasesMyPulls, option);
          },
        ),
        IconButton(
          tooltip: 'Add',
          onPressed: () => _showPullActionsSheet(context, ref, selectedDate),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
