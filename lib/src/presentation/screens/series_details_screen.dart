import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/providers/series_details_provider.dart';
import 'package:takion/src/presentation/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/display_settings_button.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/page_navigation_bar.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/widgets/tappable_link_row.dart';
import 'package:url_launcher/url_launcher.dart';

enum _SeriesDetailsMenuAction { share, openInBrowser }

enum _SeriesIssueBulkOperation { addToCollection, markAsRead }

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
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({super.key, @pathParam required this.seriesId});

  final int seriesId;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  static const _expandedHeight = 280.0;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0;
  int _issuesPage = 1;
  bool _isUpdatingSubscription = false;

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
        final actionText =
            operation == _SeriesIssueBulkOperation.addToCollection
            ? 'added to collection'
            : 'marked as read';
        TakionAlerts.success(context, '$affected issues $actionText.');
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String operationLabel(_SeriesIssueBulkOperation value) {
              switch (value) {
                case _SeriesIssueBulkOperation.addToCollection:
                  return 'Add to Collection';
                case _SeriesIssueBulkOperation.markAsRead:
                  return 'Mark as Read';
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
                case _SeriesIssueBulkOperation.markAsRead:
                  return const [
                    _SeriesIssueSubset.all,
                    _SeriesIssueSubset.unread,
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

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            seriesName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage Series Issues',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<_SeriesIssueBulkOperation>(
                      value: selectedOperation,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                      ),
                      items: _SeriesIssueBulkOperation.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(operationLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: isApplying
                          ? null
                          : (value) {
                              if (value == null) return;
                              setModalState(() {
                                selectedOperation = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selection method',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_SeriesIssueSelectionMode>(
                      segments: _SeriesIssueSelectionMode.values
                          .map(
                            (value) => ButtonSegment(
                              value: value,
                              label: Text(selectionModeLabel(value)),
                            ),
                          )
                          .toList(),
                      selected: {selectedMode},
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
                    const SizedBox(height: 12),
                    if (selectedMode == _SeriesIssueSelectionMode.predefined)
                      DropdownButtonFormField<_SeriesIssueSubset>(
                        value: selectedSubset,
                        decoration: const InputDecoration(
                          labelText: 'Apply to',
                          border: OutlineInputBorder(),
                        ),
                        items: availableSubsets
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(subsetLabel(value)),
                              ),
                            )
                            .toList(),
                        onChanged: isApplying
                            ? null
                            : (value) {
                                if (value == null) return;
                                setModalState(() {
                                  selectedSubset = value;
                                });
                              },
                      ),
                    if (selectedMode == _SeriesIssueSelectionMode.range) ...[
                      Text(
                        'Issue range: #$startIssueNumber - #$endIssueNumber',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isApplying
                              ? null
                              : () => Navigator.of(sheetContext).pop(),
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
                                              _SeriesIssueSelectionMode
                                                  .predefined
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
                                    if (sheetContext.mounted) {
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Apply'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setSeriesSubscription(bool enabled) async {
    if (_isUpdatingSubscription) return;
    setState(() {
      _isUpdatingSubscription = true;
    });
    try {
      final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
      if (enabled) {
        await subscriptionRepository.subscribe(metronSeriesId: widget.seriesId);
      } else {
        await subscriptionRepository.unsubscribe(widget.seriesId);
      }
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday % 7));
      await ref
          .read(pullListRepositoryProvider)
          .regenerateFromSubscriptions(fromDate: startOfWeek);
      if (enabled) {
        await ref
            .read(subscriptionPullReconcilerProvider)
            .reconcile(force: true, onlySeriesId: widget.seriesId);
      }
      final selectedWeek = ref.read(selectedWeekProvider);
      ref.invalidate(seriesSubscriptionProvider(widget.seriesId));
      ref.invalidate(issuePullListEntryProvider);
      ref.invalidate(pullListEntriesForWeekProvider);
      ref.invalidate(pullsIssuesForWeekProvider);
      ref.invalidate(pullsIssuesForWeekProvider(selectedWeek));
      ref.invalidate(currentWeekPullsProvider);
      ref.invalidate(currentWeekPullsCountProvider);
      await invalidateSubscriptionsLocalCacheWithHive(
        ref.read(hiveServiceProvider),
      );
      ref.invalidate(activeSubscriptionsProvider);
      ref.invalidate(activeSubscriptionsCountProvider);
      ref.invalidate(subscribedSeriesListProvider);
      ref.invalidate(subscribedSeriesPageProvider);
      await ref.read(currentWeekPullsProvider.future);
      if (mounted) {
        TakionAlerts.success(
          context,
          enabled
              ? 'Subscribed and pull list updated.'
              : 'Unsubscribed and pull list updated.',
        );
      }
    } catch (error) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update subscription: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSubscription = false;
        });
      }
    }
  }

  void _showAddActionsSheet({required String seriesName}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final subscriptionAsync = ref.watch(
              seriesSubscriptionProvider(widget.seriesId),
            );
            final isSubscribed =
                subscriptionAsync.asData?.value?.isActive ?? false;

            var isTogglingSubscription = false;
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final showLoading =
                    isTogglingSubscription || _isUpdatingSubscription;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                seriesName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          secondary: showLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isSubscribed
                                      ? Icons.notifications_active
                                      : Icons.notifications_outlined,
                                ),
                          title: const Text('Subscribe and Pull Series'),
                          subtitle: Text(
                            isSubscribed ? 'Subscribed' : 'Not subscribed',
                          ),
                          value: isSubscribed,
                          onChanged: subscriptionAsync.isLoading || showLoading
                              ? null
                              : (value) async {
                                  setSheetState(() {
                                    isTogglingSubscription = true;
                                  });
                                  try {
                                    await _setSeriesSubscription(value);
                                  } finally {
                                    if (context.mounted) {
                                      setSheetState(() {
                                        isTogglingSubscription = false;
                                      });
                                    }
                                  }
                                },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.library_add_check_outlined),
                          title: const Text('Manage Series Issues'),
                          subtitle: const Text(
                            'Add to collection or mark read by issue range',
                          ),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _showSeriesIssueActionsSheet(
                              seriesName: seriesName,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _subscriptionBadge(bool isSubscribed) {
    return Icon(
      isSubscribed
          ? Icons.notifications_active
          : Icons.notifications_none_outlined,
      size: 18,
      color: isSubscribed
          ? Theme.of(context).colorScheme.primary
          : Colors.white70,
    );
  }

  Uri? _resourceUri(SeriesDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'series');
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(SeriesDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'series');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'series');
    }
  }

  Future<void> _handleMoreAction(
    _SeriesDetailsMenuAction action,
    SeriesDetails details,
  ) async {
    switch (action) {
      case _SeriesDetailsMenuAction.share:
        await _shareResourceUrl(details);
        break;
      case _SeriesDetailsMenuAction.openInBrowser:
        await _openResourceUrlInBrowser(details);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final fadeStart = _expandedHeight * 0.58;
    final fadeEnd = _expandedHeight - kToolbarHeight;
    final next = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);

    if ((next - _titleOpacity).abs() > 0.01) {
      setState(() {
        _titleOpacity = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final subscriptionAsync = ref.watch(
      seriesSubscriptionProvider(widget.seriesId),
    );
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;

    return detailsAsync.when(
      loading: () => const _SeriesDetailsLoading(),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncStatePanel.error(
          errorMessage: 'Failed to load series details: $error',
        ),
      ),
      data: (details) => DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context).colorScheme.surface,
                  actions: [
                    IconButton(
                      tooltip: 'Add',
                      onPressed: () =>
                          _showAddActionsSheet(seriesName: details.name),
                      icon: const Icon(Icons.add),
                    ),
                    DisplaySettingsButton(
                      selectedOption: sortOption,
                      optionLabel: issueSortLabel,
                      onSelected: (option) {
                        ref
                            .read(sortPreferencesProvider.notifier)
                            .setPreference(
                              SortPreferenceContext.seriesDetailsIssues,
                              option,
                            );
                      },
                    ),
                    PopupMenuButton<_SeriesDetailsMenuAction>(
                      tooltip: 'More options',
                      onSelected: (action) {
                        _handleMoreAction(action, details);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _SeriesDetailsMenuAction.share,
                          child: Text('Share'),
                        ),
                        PopupMenuItem(
                          value: _SeriesDetailsMenuAction.openInBrowser,
                          child: Text('Open in browser'),
                        ),
                      ],
                    ),
                  ],
                  title: Opacity(
                    opacity: _titleOpacity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            details.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _subscriptionBadge(isSubscribed),
                      ],
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _SeriesHeader(
                      details: details,
                      seriesId: widget.seriesId,
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SeriesTabBarDelegate(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: const TabBar(
                        tabs: [
                          Tab(text: 'About'),
                          Tab(text: 'Issues'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _SeriesAboutTab(details: details),
                _SeriesIssuesTab(
                  seriesId: widget.seriesId,
                  page: _issuesPage,
                  sortOption: sortOption,
                  onPrevious: () {
                    if (_issuesPage <= 1) return;
                    setState(() {
                      _issuesPage = _issuesPage - 1;
                    });
                  },
                  onNext: () {
                    setState(() {
                      _issuesPage = _issuesPage + 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeriesHeader extends ConsumerWidget {
  const _SeriesHeader({required this.details, required this.seriesId});

  final SeriesDetails details;
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundTint = Theme.of(context).scaffoldBackgroundColor;
    final publisher = details.publisher?.name.trim();
    final hasPublisher = details.publisher != null;
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider((seriesId: seriesId, allowRemoteFetch: true)),
    );
    final subscriptionAsync = ref.watch(seriesSubscriptionProvider(seriesId));
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final headerImage = coverImageAsync.asData?.value;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (headerImage != null)
          CachedNetworkImage(imageUrl: headerImage, fit: BoxFit.cover)
        else
          ColoredBox(color: colorScheme.surfaceContainerHighest),
        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundTint.withValues(alpha: 0.5),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.55, 1],
              colors: [
                Colors.black.withValues(alpha: 0.56),
                Colors.black.withValues(alpha: 0.30),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (hasPublisher) ...[
                      Flexible(
                        child: Text(
                          publisher?.toUpperCase() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Flexible(
                      child: Text(
                        _yearRange(details).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  details.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isSubscribed
                          ? Icons.notifications_active
                          : Icons.notifications_none_outlined,
                      size: 22,
                      color: isSubscribed
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _yearRange(SeriesDetails details) {
    return details.yearEnd != null
        ? '${details.yearBegan ?? '—'}-${details.yearEnd}'
        : '${details.yearBegan ?? '—'}-Present';
  }
}

class _SeriesAboutTab extends StatefulWidget {
  const _SeriesAboutTab({required this.details});

  final SeriesDetails details;

  @override
  State<_SeriesAboutTab> createState() => _SeriesAboutTabState();
}

class _SeriesAboutTabState extends State<_SeriesAboutTab> {
  static const _descriptionMaxLines = 4;
  bool _isDescriptionExpanded = false;

  SeriesDetails get details => widget.details;

  String _yearRange() {
    final start = details.yearBegan;
    final end = details.yearEnd;

    if (start == null && end == null) return 'Unknown';
    if (start != null && end != null) return '$start - $end';
    if (start != null) return '$start - Present';
    return 'Until $end';
  }

  String? _modifiedValue() {
    final modified = details.modified;
    if (modified == null) return null;

    final year = modified.year.toString().padLeft(4, '0');
    final month = modified.month.toString().padLeft(2, '0');
    final day = modified.day.toString().padLeft(2, '0');
    final hour = modified.hour.toString().padLeft(2, '0');
    final minute = modified.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  List<({String label, String value})> _gridItems() {
    final items = <({String label, String value})>[];

    void addString(String label, String? value) {
      final text = value?.trim();
      if (text == null || text.isEmpty) return;
      items.add((label: label, value: text));
    }

    void addInt(String label, int? value) {
      if (value == null) return;
      items.add((label: label, value: '$value'));
    }

    addString('STATUS', details.status);
    addInt('VOLUME', details.volume);
    if (details.yearBegan != null || details.yearEnd != null) {
      items.add((label: 'YEARS', value: _yearRange()));
    }
    addString('TYPE', details.seriesType?.name);
    addInt('ISSUES', details.issueCount);
    addString('PUBLISHER', details.publisher?.name);
    addString('IMPRINT', details.imprint?.name);
    items.add((label: 'METRON ID', value: '${details.id}'));
    addInt('CV ID', details.cvId);
    addInt('GCD ID', details.gcdId);

    return items;
  }

  TextStyle? _sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    Widget child, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }

  Widget _buildExpansionTileNoSplash(
    BuildContext context, {
    Key? key,
    required Widget title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: ExpansionTile(
        key: key,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: title,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = details.description?.trim();
    final associated = details.associated
        .where((entry) => entry.series.trim().isNotEmpty)
        .toList();
    final gridItems = _gridItems();
    final modifiedValue = _modifiedValue();
    final hasDescription = description != null && description.isNotEmpty;
    final hasGrid = gridItems.isNotEmpty;
    final hasGenres = details.genres.isNotEmpty;
    final hasAssociated = associated.isNotEmpty;
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (hasDescription)
          _buildSectionCard(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: _sectionTitleStyle(context)),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textStyle = Theme.of(context).textTheme.bodyMedium;
                    final painter = TextPainter(
                      text: TextSpan(text: description, style: textStyle),
                      maxLines: _descriptionMaxLines,
                      textDirection: Directionality.of(context),
                    )..layout(maxWidth: constraints.maxWidth);
                    final isOverflowing = painter.didExceedMaxLines;

                    if (!isOverflowing || _isDescriptionExpanded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description, style: textStyle),
                          if (isOverflowing) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Tap to read less',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: textStyle,
                          maxLines: _descriptionMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to read more',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
          ),
        if (hasDescription &&
            (hasGrid || hasGenres || hasAssociated || hasModified))
          const SizedBox(height: 12),
        if (hasGrid || hasGenres)
          _buildSectionCard(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasGrid)
                  ...gridItems.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: '${entry.value.label.toUpperCase()}: ',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            TextSpan(text: entry.value.value),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (hasGenres) ...[
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'GENRES: ',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        TextSpan(
                          text: details.genres
                              .map((genre) => genre.name)
                              .join(' • '),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        if ((hasGrid || hasGenres) && (hasAssociated || hasModified))
          const SizedBox(height: 12),
        if (hasAssociated)
          _buildSectionCard(
            context,
            _buildExpansionTileNoSplash(
              context,
              key: PageStorageKey('series-associated-${details.id}'),
              title: Text(
                'Associated Series',
                style: _sectionTitleStyle(context),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: associated
                        .asMap()
                        .entries
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.only(
                              bottom: item.key == associated.length - 1 ? 0 : 6,
                            ),
                            child: TappableLinkRow(
                              label: item.value.series,
                              isCurrent: item.value.id == details.id,
                              onTap: item.value.id == details.id
                                  ? null
                                  : () {
                                      context.pushRoute(
                                        SeriesDetailsRoute(
                                          seriesId: item.value.id,
                                        ),
                                      );
                                    },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        if (hasAssociated && hasModified) const SizedBox(height: 12),
        if (hasModified)
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        if (!hasDescription &&
            !hasGrid &&
            !hasGenres &&
            !hasAssociated &&
            !hasModified)
          Text(
            'No about information available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _SeriesIssuesTab extends ConsumerWidget {
  const _SeriesIssuesTab({
    required this.seriesId,
    required this.page,
    required this.sortOption,
    required this.onPrevious,
    required this.onNext,
  });

  final int seriesId;
  final int page;
  final ContentSortOption sortOption;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = SeriesIssueListArgs(seriesId: seriesId, page: page);
    final issuesAsync = ref.watch(seriesIssueListProvider(args));

    return issuesAsync.when(
      loading: () => const AsyncStatePanel.loading(),
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load series issues: $error',
      ),
      data: (issuePage) {
        final sortedIssues = sortIssues(issuePage.results, sortOption);
        final totalPages =
            ((issuePage.count /
                        (sortedIssues.isEmpty ? 100 : sortedIssues.length))
                    .ceil())
                .clamp(1, 9999);
        final hasPagination = totalPages > 1;

        return Stack(
          children: [
            sortedIssues.isEmpty
                ? ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: hasPagination ? 96 : 12),
                    children: const [
                      SizedBox(
                        height: 360,
                        child: EmptyContentState(
                          icon: Icons.menu_book_outlined,
                          message: 'No issues available.',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      12,
                      0,
                      hasPagination ? 96 : 12,
                    ),
                    itemCount: sortedIssues.length,
                    itemBuilder: (context, index) {
                      final issue = sortedIssues[index];
                      return IssueListTile(
                        issue: issue,
                        isFirst: index == 0,
                        isLast: index == sortedIssues.length - 1,
                      );
                    },
                  ),
            if (hasPagination)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: PageNavigationBar(
                      currentPage: page,
                      totalPages: totalPages,
                      hasPrevious: issuePage.hasPrevious,
                      hasNext: issuePage.hasNext,
                      onPrevious: onPrevious,
                      onNext: onNext,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SeriesTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SeriesTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SeriesTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _SeriesDetailsLoading extends StatelessWidget {
  const _SeriesDetailsLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280.0,
            backgroundColor: colorScheme.surface,
            title: const Text('Series'),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: ColoredBox(
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SeriesTabBarDelegate(
              child: Material(
                color: colorScheme.surface,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'About'),
                    Tab(text: 'Issues'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
