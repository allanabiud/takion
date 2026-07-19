import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
  int _totalPages = 1;
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
    final isLoading = issuesAsync.isLoading;
    final seriesName = detailsAsync.asData?.value.name ?? '';
    final yearBegan = detailsAsync.asData?.value.yearBegan;

    if (issuesAsync.hasValue) {
      _lastPage = issuesAsync.value;
      _totalPages =
          ((issuesAsync.value!.count - 1) ~/ metronDefaultPageSize) + 1;
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
        errorMessage: 'Failed to load issues',
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
      bottomNavigationBar: _totalPages > 1
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isLoading || !_pageHasPrevious
                        ? null
                        : () => setState(() => _page--),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Page $_page of $_totalPages',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isLoading || !_pageHasNext
                        ? null
                        : () => setState(() => _page++),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  bool get _pageHasPrevious =>
      _lastPage?.hasPrevious ?? false;

  bool get _pageHasNext =>
      _lastPage?.hasNext ?? false;

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SeriesIssueListPage issuePage,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final sortedIssues = sortIssues(issuePage.results, sortOption);
    final issueCount = issuePage.count;

    return CustomScrollView(
      slivers: [
        SliverOverlapAbsorber(
          handle: _overlapHandle,
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              isLoading: isLoading,
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
      limit: 500,
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

    ref.invalidate(allLibraryItemsProvider);
    for (final issueId in affectedIssueIds) {
      ref.invalidate(issueCollectionStatusProvider(issueId));
    }

    if (context.mounted) {
      final actionText = switch (operation) {
        SeriesIssueBulkOperation.addToCollection => 'Added to Collection',
        SeriesIssueBulkOperation.removeFromCollection =>
          'Removed from Collection',
        SeriesIssueBulkOperation.markAsRead => 'Marked as Read',
        SeriesIssueBulkOperation.markAsUnread => 'Marked as Unread',
      };
      TakionAlerts.success(context, '$affected $actionText');
      Navigator.of(context).pop();
    }
  } catch (error) {
    if (context.mounted) {
      TakionAlerts.safeError(context, error, userMessage: 'Failed to apply series issue action');
    }
  }
}

int? _findClosestIssueIndex(List<SeriesIssueBulkCandidate> issues, String input, {int? startAfter}) {
  final query = input.trim();
  if (query.isEmpty) return null;

  final parsedQuery = int.tryParse(query);

  var startIndex = startAfter ?? 0;
  if (startIndex < 0) startIndex = 0;

  for (var i = startIndex; i < issues.length; i++) {
    final candidate = issues[i].issueNumber.trim();
    if (candidate == query) return i;

    if (parsedQuery != null) {
      final parsedCandidate = int.tryParse(candidate);
      if (parsedCandidate == parsedQuery) return i;
    }
  }

  return null;
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
  var useManualRange = false;
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
                TakionAlerts.info(context, 'No issues found');
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Issue range: #$startIssueNumber - #$endIssueNumber',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: isApplying
                                ? null
                                : () {
                                    setModalState(() {
                                      useManualRange = !useManualRange;
                                    });
                                  },
                            child: Text(useManualRange ? 'Use Slider' : 'Use Inputs'),
                          ),
                        ],
                      ),
                      if (useManualRange)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: startIssueNumber,
                                decoration: const InputDecoration(
                                  labelText: 'From issue #',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                enabled: !isApplying,
                                onChanged: (v) {
                                  if (v.isEmpty) return;
                                  final idx = _findClosestIssueIndex(issues, v, startAfter: null);
                                  if (idx != null && idx + 1 <= selectedEnd) {
                                    setModalState(() {
                                      selectedRange = RangeValues(
                                        (idx + 1).toDouble(),
                                        selectedRange.end,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: endIssueNumber,
                                decoration: const InputDecoration(
                                  labelText: 'To issue #',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                enabled: !isApplying,
                                onChanged: (v) {
                                  if (v.isEmpty) return;
                                  final idx = _findClosestIssueIndex(issues, v, startAfter: selectedStart - 1);
                                  if (idx != null && idx + 1 <= totalIssues) {
                                    setModalState(() {
                                      selectedRange = RangeValues(
                                        selectedRange.start,
                                        (idx + 1).toDouble(),
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        RangeSlider(
                          min: 1,
                          max: totalIssues.toDouble(),
                          divisions: totalIssues > 1
                              ? (totalIssues - 1).clamp(1, 100)
                              : null,
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
                      const SizedBox(height: 4),
                      Text(
                        'Selected: #$startIssueNumber - #$endIssueNumber ($selectedStart to $selectedEnd of $totalIssues)',
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
  _PinnedHeaderDelegate({required this.child, this.isLoading = false});

  final Widget child;
  final bool isLoading;

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
  double get maxExtent => isLoading ? 74.0 : 56.0;

  @override
  double get minExtent => isLoading ? 74.0 : 56.0;

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || isLoading != oldDelegate.isLoading;
}
