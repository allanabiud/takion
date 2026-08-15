import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/releases/providers/selected_week_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";

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
        final activityRepo = ref.read(activityRepositoryProvider);
        await activityRepo.addEvent(
          LibraryActivityEvent(
            id: "act-col-$issueId-${DateTime.now().microsecondsSinceEpoch}",
            userId: "local-user",
            type: ActivityEventType.collected,
            issueId: issueId,
            seriesId: seriesId,
            seriesName: issue.series?.name ?? "Unknown Series",
            issueNumber: issue.number,
            imageUrl: issue.image,
            timestamp: DateTime.now().toUtc(),
          ),
        );
        affected++;
      }

      if (!context.mounted) return;
      TakionAlerts.success(context, "$affected Added to Collection");
    } catch (error) {
      if (!context.mounted) return;
      TakionAlerts.safeError(
        context,
        error,
        userMessage: "Failed to add pulled issues",
      );
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
        final activityRepo = ref.read(activityRepositoryProvider);
        await activityRepo.addEvent(
          LibraryActivityEvent(
            id: "act-read-$issueId-${now.microsecondsSinceEpoch}",
            userId: "local-user",
            type: ActivityEventType.read,
            issueId: issueId,
            seriesId: seriesId,
            seriesName: issue.series?.name ?? "Unknown Series",
            issueNumber: issue.number,
            imageUrl: issue.image,
            timestamp: now,
          ),
        );
        affected++;
      }

      if (!context.mounted) return;
      TakionAlerts.success(context, "$affected Marked as Read");
    } catch (error) {
      if (!context.mounted) return;
      TakionAlerts.safeError(
        context,
        error,
        userMessage: "Failed to mark pulled issues as read",
      );
    }
  }

  void _showPullActionsSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    TakionBottomSheet.show<void>(
      context: context,
      title: "Pull Actions",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text("Add Pulled to Collection"),
            onTap: () async {
              Navigator.of(context).pop();
              await _addPulledToCollection(context, ref, selectedDate);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bookmark_added_outlined),
            title: const Text("Mark Pulled Issues as Read"),
            onTap: () async {
              Navigator.of(context).pop();
              await _markPulledAsRead(context, ref, selectedDate);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionPullReconcilerProvider).browseReconcile();
    });
    final selectedDate = ref.watch(selectedWeekProvider);
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.releasesMyPulls),
    );
    final pullsAsync = ref.watch(pullsIssuesForWeekProvider(selectedDate));

    return PagedIssueListScaffold(
      title: "My Pulls",
      issuesAsync: pullsAsync,
      transformIssues: (issues) => sortIssues(issues, sortOption),
      emptyMessage: "No pulls for this week.",
      emptyIcon: Icons.shopping_bag_outlined,
      errorTextBuilder: (error) => "Failed to load pulls",
      header: pullsAsync.maybeWhen(
        data: (issues) => ListHeader(
          count: issues.length,
          unit: "issue",
          sortLabel: contentSortLabel(sortOption),
          onSortTap: () => showSortBottomSheet(
            context,
            ref,
            SortPreferenceContext.releasesMyPulls,
            contentSortLabel,
          ),
        ),
        orElse: () => null,
      ),
      appBarActions: [
        IconButton(
          tooltip: "Add",
          onPressed: () => _showPullActionsSheet(context, ref, selectedDate),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
