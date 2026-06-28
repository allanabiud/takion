import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/page_navigation_bar.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';

enum SeriesIssueBulkOperation {
  addToCollection,
  removeFromCollection,
  markAsRead,
  markAsUnread,
}

enum SeriesIssueSelectionMode { predefined, range }

enum SeriesIssueSubset { all, collected, uncollected, read, unread }

class SeriesIssueBulkCandidate {
  const SeriesIssueBulkCandidate({
    required this.issueId,
    required this.orderIndex,
    required this.issueNumber,
  });

  final int issueId;
  final int orderIndex;
  final String issueNumber;
}

@RoutePage()
class SeriesIssuesScreen extends ConsumerStatefulWidget {
  const SeriesIssuesScreen({super.key, @pathParam required this.seriesId});

  final int seriesId;

  @override
  ConsumerState<SeriesIssuesScreen> createState() => _SeriesIssuesScreenState();
}

class _SeriesIssuesScreenState extends ConsumerState<SeriesIssuesScreen> {
  int _page = 1;
  SeriesIssueListPage? _lastPage;
  final _overlapHandle = SliverOverlapAbsorberHandle();

  @override
  void dispose() {
    _overlapHandle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final args = SeriesIssueListArgs(
      seriesId: widget.seriesId,
      page: _page,
    );
    final issuesAsync = ref.watch(seriesIssueListProvider(args));
    final seriesName = detailsAsync.asData?.value.name ?? '';
    final yearBegan = detailsAsync.asData?.value.yearBegan;

    if (issuesAsync.hasValue) {
      _lastPage = issuesAsync.value;
    }

    final body = issuesAsync.when(
      loading: () {
        if (_lastPage != null) {
          return _buildContent(context, ref, _lastPage!, sortOption,
              isLoading: true);
        }
        return const AsyncStatePanel.loading();
      },
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load issues: $error',
      ),
      data: (issuePage) =>
          _buildContent(context, ref, issuePage, sortOption, isLoading: false),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issues'),
            if (seriesName.isNotEmpty)
              Text(
                yearBegan != null ? '$seriesName ($yearBegan)' : seriesName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSeriesIssueActionsSheet(
              seriesName: seriesName,
              yearBegan: yearBegan,
            ),
            tooltip: 'Bulk actions',
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SeriesIssueListPage issuePage,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final sortedIssues = sortIssues(issuePage.results, sortOption);
    final totalPages =
        ((issuePage.count / (sortedIssues.isEmpty ? 100 : sortedIssues.length))
                .ceil())
            .clamp(1, 9999);
    final hasPagination = totalPages > 1;
    final issueCount = issuePage.count;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverOverlapAbsorber(
              handle: _overlapHandle,
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeaderDelegate(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListHeader(
                        count: issueCount,
                        unit: 'issue',
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                            ),
                            TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      showSortBottomSheet(
                                        context,
                                        ref,
                                        SortPreferenceContext
                                            .seriesDetailsIssues,
                                        issueSortLabel,
                                      );
                                    },
                              icon: const Icon(Icons.swap_vert),
                              label: Text(issueSortLabel(sortOption)),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverOverlapInjector(handle: _overlapHandle),
            sortedIssues.isEmpty && !isLoading
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox(
                      height: 360,
                      child: EmptyContentState(
                        icon: Icons.menu_book_outlined,
                        message: 'No issues available.',
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final issue = sortedIssues[index];
                        return Opacity(
                          opacity: isLoading ? 0.6 : 1.0,
                          child: IssueListTile(
                            issue: issue,
                            isFirst: index == 0,
                            isLast: index == sortedIssues.length - 1,
                          ),
                        );
                      },
                      childCount: sortedIssues.length,
                    ),
                  ),
            if (hasPagination)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 80,
                ),
              ),
                ],
              ),
        if (hasPagination)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: PageNavigationBar(
                  currentPage: _page,
                  totalPages: totalPages,
                  hasPrevious: issuePage.hasPrevious,
                  hasNext: issuePage.hasNext,
                  onPrevious: () {
                    if (_page <= 1) return;
                    setState(() {
                      _page = _page - 1;
                    });
                  },
                  onNext: () {
                    setState(() {
                      _page = _page + 1;
                    });
                  },
                  enabled: !isLoading,
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showSeriesIssueActionsSheet({
    required String seriesName,
    int? yearBegan,
  }) async {
    return showSeriesIssueBulkActionsSheet(
      context: context,
      ref: ref,
      seriesId: widget.seriesId,
      seriesName: seriesName,
      seriesYear: yearBegan,
    );
  }
}

Future<List<SeriesIssueBulkCandidate>> allSeriesIssues(
  WidgetRef ref,
  int seriesId,
) async {
  final metronRepository = ref.read(metronRepositoryProvider);
  var page = 1;
  var orderIndex = 1;
  final issues = <SeriesIssueBulkCandidate>[];

  while (true) {
    final issuePage = await metronRepository.getSeriesIssueList(
      seriesId,
      page: page,
    );
    for (final issue in issuePage.results) {
      final issueId = issue.id;
      if (issueId != null) {
        issues.add(
          SeriesIssueBulkCandidate(
            issueId: issueId,
            orderIndex: orderIndex,
            issueNumber: issue.number,
          ),
        );
        orderIndex++;
      }
    }
    final nextPage = issuePage.nextPage;
    if (nextPage == null) break;
    page = nextPage;
  }

  return issues;
}

bool matchesSubset({
  required SeriesIssueSubset subset,
  required bool isCollected,
  required bool isRead,
}) {
  switch (subset) {
    case SeriesIssueSubset.all:
      return true;
    case SeriesIssueSubset.collected:
      return isCollected;
    case SeriesIssueSubset.uncollected:
      return !isCollected;
    case SeriesIssueSubset.read:
      return isRead;
    case SeriesIssueSubset.unread:
      return !isRead;
  }
}

Future<void> applySeriesIssueBulkAction({
  required BuildContext context,
  required WidgetRef ref,
  required int seriesId,
  required SeriesIssueBulkOperation operation,
  required SeriesIssueSelectionMode selectionMode,
  required List<SeriesIssueBulkCandidate> issues,
  SeriesIssueSubset? subset,
  int? startOrderIndex,
  int? endOrderIndex,
}) async {
  try {
    final libraryRepository = ref.read(libraryRepositoryProvider);
    var affected = 0;
    final affectedIssueIds = <int>{};

    for (final issue in issues) {
      final issueId = issue.issueId;
      final existing = await libraryRepository.getItemByIssueId(issueId);
      final isCollected =
          existing?.ownershipStatus == LibraryOwnershipStatus.owned;
      final isRead = existing?.isRead ?? false;

      final matchesSelection =
          selectionMode == SeriesIssueSelectionMode.range
          ? (startOrderIndex != null &&
                endOrderIndex != null &&
                issue.orderIndex >= startOrderIndex &&
                issue.orderIndex <= endOrderIndex)
          : (subset != null &&
                matchesSubset(
                  subset: subset,
                  isCollected: isCollected,
                  isRead: isRead,
                ));
      if (!matchesSelection) continue;

      if (operation == SeriesIssueBulkOperation.addToCollection) {
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
        affectedIssueIds.add(issueId);
        continue;
      }

      if (operation == SeriesIssueBulkOperation.removeFromCollection) {
        if (!isCollected) continue;
        await libraryRepository.deleteItemByIssueId(issueId);
        affected++;
        affectedIssueIds.add(issueId);
        continue;
      }

      if (operation == SeriesIssueBulkOperation.markAsRead) {
        if (isRead) continue;
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
        await libraryRepository.addReadLog(
          metronIssueId: issueId,
          readAt: now,
        );
        affected++;
        affectedIssueIds.add(issueId);
        continue;
      }

      if (operation == SeriesIssueBulkOperation.markAsUnread) {
        if (!isRead) continue;
        await libraryRepository.upsertItem(
          metronIssueId: issueId,
          metronSeriesId: seriesId,
          ownershipStatus:
              existing?.ownershipStatus ?? LibraryOwnershipStatus.notOwned,
          isRead: false,
          rating: existing?.rating,
          purchaseDate: existing?.purchaseDate,
          pricePaid: existing?.pricePaid,
          quantityOwned: existing?.quantityOwned ?? 1,
          format: existing?.format ?? LibraryItemFormat.print,
          firstReadAt: null,
          conditionGrade: existing?.conditionGrade,
          acquiredOn: existing?.acquiredOn ?? DateTime.now().toUtc(),
          notes: existing?.notes,
        );
        final logs = await libraryRepository.getReadLogsByIssueId(issueId);
        for (final log in logs) {
          await libraryRepository.deleteReadLogById(log.id);
        }
        affected++;
        affectedIssueIds.add(issueId);
      }
    }

    await invalidateLibraryItemsLocalCacheWithHive(
      ref.read(hiveServiceProvider),
    );
    ref.invalidate(allLibraryItemsProvider);
    await ref.read(allLibraryItemsProvider.future);
    ref.invalidate(collectionIssueStatusMapProvider);
    await ref.read(collectionIssueStatusMapProvider.future);
    for (final issueId in affectedIssueIds) {
      ref.invalidate(issueCollectionStatusProvider(issueId));
    }
    ref.invalidate(collectionStatsProvider);
    invalidateLibraryCollectionProvidersForWidget(ref);

    if (context.mounted) {
      final actionText = switch (operation) {
        SeriesIssueBulkOperation.addToCollection => 'added to collection',
        SeriesIssueBulkOperation.removeFromCollection =>
          'removed from collection',
        SeriesIssueBulkOperation.markAsRead => 'marked as read',
        SeriesIssueBulkOperation.markAsUnread => 'marked as unread',
      };
      TakionAlerts.success(context, '$affected issues $actionText.');
      Navigator.of(context).pop();
    }
  } catch (error) {
    if (context.mounted) {
      TakionAlerts.error(
        context,
        'Failed to apply series issue action: $error',
      );
    }
  }
}

Future<void> showSeriesIssueBulkActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int seriesId,
  required String seriesName,
  int? seriesYear,
}) async {
  var totalIssues = 0;
  var isLoading = true;
  var hasStarted = false;
  List<SeriesIssueBulkCandidate> issues = [];
  var selectedOperation = SeriesIssueBulkOperation.addToCollection;
  var selectedMode = SeriesIssueSelectionMode.predefined;
  var selectedSubset = SeriesIssueSubset.uncollected;
  var selectedRange = const RangeValues(1, 1);
  var isApplying = false;

  TakionBottomSheet.show<void>(
    context: context,
    title: seriesYear != null ? '$seriesName ($seriesYear)' : seriesName,
    child: StatefulBuilder(
      builder: (context, setModalState) {
        if (isLoading) {
          if (!hasStarted) {
            hasStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final fetched = await allSeriesIssues(ref, seriesId);
              if (!context.mounted) return;
              if (fetched.isEmpty) {
                Navigator.of(context).pop();
                TakionAlerts.info(context, 'No issues found for this series yet.');
                return;
              }
              setModalState(() {
                issues = fetched;
                totalIssues = fetched.length;
                selectedRange = RangeValues(1, totalIssues.toDouble());
                isLoading = false;
              });
            });
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        String operationLabel(SeriesIssueBulkOperation value) {
          switch (value) {
            case SeriesIssueBulkOperation.addToCollection:
              return 'Add to Collection';
            case SeriesIssueBulkOperation.removeFromCollection:
              return 'Remove from Collection';
            case SeriesIssueBulkOperation.markAsRead:
              return 'Mark as Read';
            case SeriesIssueBulkOperation.markAsUnread:
              return 'Mark as Unread';
          }
        }

        String selectionModeLabel(SeriesIssueSelectionMode value) {
          switch (value) {
            case SeriesIssueSelectionMode.predefined:
              return 'Filters';
            case SeriesIssueSelectionMode.range:
              return 'Issue range';
          }
        }

        String subsetLabel(SeriesIssueSubset value) {
          switch (value) {
            case SeriesIssueSubset.all:
              return 'All issues';
            case SeriesIssueSubset.collected:
              return 'Collected issues';
            case SeriesIssueSubset.uncollected:
              return 'Uncollected issues';
            case SeriesIssueSubset.read:
              return 'Read issues';
            case SeriesIssueSubset.unread:
              return 'Unread issues';
          }
        }

        List<SeriesIssueSubset> applicableSubsets(
          SeriesIssueBulkOperation operation,
        ) {
          switch (operation) {
            case SeriesIssueBulkOperation.addToCollection:
              return const [
                SeriesIssueSubset.all,
                SeriesIssueSubset.uncollected,
                SeriesIssueSubset.read,
                SeriesIssueSubset.unread,
              ];
            case SeriesIssueBulkOperation.removeFromCollection:
              return const [
                SeriesIssueSubset.all,
                SeriesIssueSubset.collected,
              ];
            case SeriesIssueBulkOperation.markAsRead:
              return const [
                SeriesIssueSubset.all,
                SeriesIssueSubset.unread,
                SeriesIssueSubset.collected,
                SeriesIssueSubset.uncollected,
              ];
            case SeriesIssueBulkOperation.markAsUnread:
              return const [
                SeriesIssueSubset.all,
                SeriesIssueSubset.read,
                SeriesIssueSubset.collected,
                SeriesIssueSubset.uncollected,
              ];
          }
        }

        final availableSubsets = applicableSubsets(selectedOperation);
        if (!availableSubsets.contains(selectedSubset)) {
          selectedSubset = availableSubsets.first;
        }

        final selectedStart = selectedRange.start.round();
        final selectedEnd = selectedRange.end.round();
        final startIssueNumber = issues[selectedStart - 1].issueNumber;
        final endIssueNumber = issues[selectedEnd - 1].issueNumber;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Action', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              RadioGroup<SeriesIssueBulkOperation>(
                groupValue: selectedOperation,
                onChanged: (value) {
                  if (isApplying || value == null) return;
                  setModalState(() {
                    selectedOperation = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: SeriesIssueBulkOperation.values.map((
                    operation,
                  ) {
                    return RadioListTile<SeriesIssueBulkOperation>(
                      title: Text(operationLabel(operation)),
                      value: operation,
                      contentPadding: EdgeInsets.zero,
                      enabled: !isApplying,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Selection method',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SeriesIssueSelectionMode>(
                  segments: SeriesIssueSelectionMode.values
                      .map(
                        (value) => ButtonSegment(
                          value: value,
                          label: Text(selectionModeLabel(value)),
                        ),
                      )
                      .toList(),
                  selected: {selectedMode},
                  showSelectedIcon: false,
                  multiSelectionEnabled: false,
                  emptySelectionAllowed: false,
                  onSelectionChanged: isApplying
                      ? null
                      : (selection) {
                          final value = selection.firstOrNull;
                          if (value == null) return;
                          setModalState(() {
                            selectedMode = value;
                          });
                        },
                ),
              ),
              const SizedBox(height: 12),
              if (selectedMode == SeriesIssueSelectionMode.predefined) ...[
                Text(
                  'Apply to',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSubsets
                      .map(
                        (value) => ChoiceChip(
                          label: Text(
                            subsetLabel(value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: value == selectedSubset,
                          shape: const StadiumBorder(),
                          onSelected: isApplying
                              ? null
                              : (_) {
                                  setModalState(() {
                                    selectedSubset = value;
                                  });
                                },
                        ),
                      )
                      .toList(),
                ),
              ],
              if (selectedMode == SeriesIssueSelectionMode.range) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issue range: #$startIssueNumber - #$endIssueNumber',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        min: 1,
                        max: totalIssues.toDouble(),
                        divisions: totalIssues > 1 ? totalIssues - 1 : null,
                        labels: RangeLabels('$selectedStart', '$selectedEnd'),
                        values: selectedRange,
                        onChanged: isApplying
                            ? null
                            : (value) {
                                setModalState(() {
                                  selectedRange = RangeValues(
                                    value.start.roundToDouble(),
                                    value.end.roundToDouble(),
                                  );
                                });
                              },
                      ),
                      Text(
                        'Selected positions: $selectedStart to $selectedEnd of $totalIssues',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: isApplying
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isApplying
                        ? null
                        : () async {
                            setModalState(() {
                              isApplying = true;
                            });
                            try {
                              await applySeriesIssueBulkAction(
                                context: context,
                                ref: ref,
                                seriesId: seriesId,
                                operation: selectedOperation,
                                selectionMode: selectedMode,
                                issues: issues,
                                subset:
                                    selectedMode ==
                                            SeriesIssueSelectionMode.predefined
                                        ? selectedSubset
                                        : null,
                                startOrderIndex:
                                    selectedMode ==
                                            SeriesIssueSelectionMode.range
                                        ? selectedStart
                                        : null,
                                endOrderIndex:
                                    selectedMode ==
                                            SeriesIssueSelectionMode.range
                                        ? selectedEnd
                                        : null,
                              );
                            } finally {
                              if (context.mounted) {
                                setModalState(() {
                                  isApplying = false;
                                });
                              }
                            }
                          },
                    child: isApplying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.child});

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Container(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      );

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) =>
      child != oldDelegate.child;
}
