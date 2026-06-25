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

enum _SeriesIssueBulkOperation {
  addToCollection,
  removeFromCollection,
  markAsRead,
  markAsUnread,
}

enum _SeriesIssueSelectionMode { predefined, range }

enum _SeriesIssueSubset { all, collected, uncollected, read, unread }

class _SeriesIssueBulkCandidate {
  const _SeriesIssueBulkCandidate({
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
        if (hasPagination && sortedIssues.isNotEmpty)
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

  Future<List<_SeriesIssueBulkCandidate>> _allSeriesIssues() async {
    final metronRepository = ref.read(metronRepositoryProvider);
    var page = 1;
    var orderIndex = 1;
    final issues = <_SeriesIssueBulkCandidate>[];

    while (true) {
      final issuePage = await metronRepository.getSeriesIssueList(
        widget.seriesId,
        page: page,
      );
      for (final issue in issuePage.results) {
        final issueId = issue.id;
        if (issueId != null) {
          issues.add(
            _SeriesIssueBulkCandidate(
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

  Future<void> _applySeriesIssueBulkAction({
    required _SeriesIssueBulkOperation operation,
    required _SeriesIssueSelectionMode selectionMode,
    required List<_SeriesIssueBulkCandidate> issues,
    _SeriesIssueSubset? subset,
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
            selectionMode == _SeriesIssueSelectionMode.range
            ? (startOrderIndex != null &&
                  endOrderIndex != null &&
                  issue.orderIndex >= startOrderIndex &&
                  issue.orderIndex <= endOrderIndex)
            : (subset != null &&
                  _matchesSubset(
                    subset: subset,
                    isCollected: isCollected,
                    isRead: isRead,
                  ));
        if (!matchesSelection) continue;

        if (operation == _SeriesIssueBulkOperation.addToCollection) {
          if (isCollected) continue;
          await libraryRepository.upsertItem(
            metronIssueId: issueId,
            metronSeriesId: widget.seriesId,
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

        if (operation == _SeriesIssueBulkOperation.removeFromCollection) {
          if (!isCollected) continue;
          await libraryRepository.deleteItemByIssueId(issueId);
          affected++;
          affectedIssueIds.add(issueId);
          continue;
        }

        if (operation == _SeriesIssueBulkOperation.markAsRead) {
          if (isRead) continue;
          final now = DateTime.now().toUtc();
          await libraryRepository.upsertItem(
            metronIssueId: issueId,
            metronSeriesId: widget.seriesId,
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

        if (operation == _SeriesIssueBulkOperation.markAsUnread) {
          if (!isRead) continue;
          await libraryRepository.upsertItem(
            metronIssueId: issueId,
            metronSeriesId: widget.seriesId,
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

      if (mounted) {
        final actionText = switch (operation) {
          _SeriesIssueBulkOperation.addToCollection => 'added to collection',
          _SeriesIssueBulkOperation.removeFromCollection =>
            'removed from collection',
          _SeriesIssueBulkOperation.markAsRead => 'marked as read',
          _SeriesIssueBulkOperation.markAsUnread => 'marked as unread',
        };
        TakionAlerts.success(context, '$affected issues $actionText.');
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        TakionAlerts.error(
          context,
          'Failed to apply series issue action: $error',
        );
      }
    }
  }

  bool _matchesSubset({
    required _SeriesIssueSubset subset,
    required bool isCollected,
    required bool isRead,
  }) {
    switch (subset) {
      case _SeriesIssueSubset.all:
        return true;
      case _SeriesIssueSubset.collected:
        return isCollected;
      case _SeriesIssueSubset.uncollected:
        return !isCollected;
      case _SeriesIssueSubset.read:
        return isRead;
      case _SeriesIssueSubset.unread:
        return !isRead;
    }
  }

  Future<void> _showSeriesIssueActionsSheet({
    required String seriesName,
  }) async {
    final issues = await _allSeriesIssues();
    if (!mounted) return;
    if (issues.isEmpty) {
      TakionAlerts.info(context, 'No issues found for this series yet.');
      return;
    }

    final totalIssues = issues.length;
    var selectedOperation = _SeriesIssueBulkOperation.addToCollection;
    var selectedMode = _SeriesIssueSelectionMode.predefined;
    var selectedSubset = _SeriesIssueSubset.uncollected;
    var selectedRange = RangeValues(1, totalIssues.toDouble());
    var isApplying = false;

    TakionBottomSheet.show<void>(
      context: context,
      title: seriesName,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          String operationLabel(_SeriesIssueBulkOperation value) {
            switch (value) {
              case _SeriesIssueBulkOperation.addToCollection:
                return 'Add to Collection';
              case _SeriesIssueBulkOperation.removeFromCollection:
                return 'Remove from Collection';
              case _SeriesIssueBulkOperation.markAsRead:
                return 'Mark as Read';
              case _SeriesIssueBulkOperation.markAsUnread:
                return 'Mark as Unread';
            }
          }

          String selectionModeLabel(_SeriesIssueSelectionMode value) {
            switch (value) {
              case _SeriesIssueSelectionMode.predefined:
                return 'Filters';
              case _SeriesIssueSelectionMode.range:
                return 'Issue range';
            }
          }

          String subsetLabel(_SeriesIssueSubset value) {
            switch (value) {
              case _SeriesIssueSubset.all:
                return 'All issues';
              case _SeriesIssueSubset.collected:
                return 'Collected issues';
              case _SeriesIssueSubset.uncollected:
                return 'Uncollected issues';
              case _SeriesIssueSubset.read:
                return 'Read issues';
              case _SeriesIssueSubset.unread:
                return 'Unread issues';
            }
          }

          List<_SeriesIssueSubset> applicableSubsets(
            _SeriesIssueBulkOperation operation,
          ) {
            switch (operation) {
              case _SeriesIssueBulkOperation.addToCollection:
                return const [
                  _SeriesIssueSubset.all,
                  _SeriesIssueSubset.uncollected,
                  _SeriesIssueSubset.read,
                  _SeriesIssueSubset.unread,
                ];
              case _SeriesIssueBulkOperation.removeFromCollection:
                return const [
                  _SeriesIssueSubset.all,
                  _SeriesIssueSubset.collected,
                ];
              case _SeriesIssueBulkOperation.markAsRead:
                return const [
                  _SeriesIssueSubset.all,
                  _SeriesIssueSubset.unread,
                  _SeriesIssueSubset.collected,
                  _SeriesIssueSubset.uncollected,
                ];
              case _SeriesIssueBulkOperation.markAsUnread:
                return const [
                  _SeriesIssueSubset.all,
                  _SeriesIssueSubset.read,
                  _SeriesIssueSubset.collected,
                  _SeriesIssueSubset.uncollected,
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: RadioGroup<_SeriesIssueBulkOperation>(
                    groupValue: selectedOperation,
                    onChanged: (value) {
                      if (isApplying || value == null) return;
                      setModalState(() {
                        selectedOperation = value;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _SeriesIssueBulkOperation.values.map((
                        operation,
                      ) {
                        return RadioListTile<_SeriesIssueBulkOperation>(
                          title: Text(operationLabel(operation)),
                          value: operation,
                          enabled: !isApplying,
                        );
                      }).toList(),
                    ),
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
                  child: SegmentedButton<_SeriesIssueSelectionMode>(
                    segments: _SeriesIssueSelectionMode.values
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
                if (selectedMode == _SeriesIssueSelectionMode.predefined) ...[
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
                if (selectedMode == _SeriesIssueSelectionMode.range) ...[
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isApplying
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: isApplying
                          ? null
                          : () async {
                              setModalState(() {
                                isApplying = true;
                              });
                              try {
                                await _applySeriesIssueBulkAction(
                                  operation: selectedOperation,
                                  selectionMode: selectedMode,
                                  issues: issues,
                                  subset:
                                      selectedMode ==
                                              _SeriesIssueSelectionMode.predefined
                                          ? selectedSubset
                                          : null,
                                  startOrderIndex:
                                      selectedMode ==
                                              _SeriesIssueSelectionMode.range
                                          ? selectedStart
                                          : null,
                                  endOrderIndex:
                                      selectedMode ==
                                              _SeriesIssueSelectionMode.range
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
