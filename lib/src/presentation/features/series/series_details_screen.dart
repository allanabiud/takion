import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_issue_list_page.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issues_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/series_cover_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/providers/sort_preferences_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/components/list_header.dart';
import 'package:takion/src/presentation/components/sort_bottom_sheet.dart';
import 'package:takion/src/presentation/components/page_navigation_bar.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/common/tappable_link_row.dart';
import 'package:url_launcher/url_launcher.dart';

enum _SeriesDetailsMenuAction { share, openInBrowser }

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
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({super.key, @pathParam required this.seriesId});

  final int seriesId;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  int _issuesPage = 1;
  bool _isUpdatingSubscription = false;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0;

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

  Future<void> _toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isSeriesFavoriteProvider(widget.seriesId).future,
      );

      await repository.toggleSeriesFavorite(widget.seriesId);

      ref.invalidate(isSeriesFavoriteProvider(widget.seriesId));
      ref.invalidate(favoriteSeriesListProvider);

      if (mounted) {
        TakionAlerts.success(
          context,
          !isFavorite
              ? 'Series added to favorites'
              : 'Series removed from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final fadeStart = 260 * 0.58;
    final fadeEnd = 260 - kToolbarHeight;
    final next = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);

    if ((next - _titleOpacity).abs() > 0.01) {
      setState(() {
        _titleOpacity = next;
      });
    }
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
                Text(
                  'Action',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        RangeSlider(
                          min: 1,
                          max: totalIssues.toDouble(),
                          divisions: totalIssues > 1 ? totalIssues - 1 : null,
                          labels: RangeLabels(
                            '$selectedStart',
                            '$selectedEnd',
                          ),
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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
        await ref
            .read(pullListRepositoryProvider)
            .deleteEntriesBySeriesId(widget.seriesId);
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
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final colorScheme = Theme.of(context).colorScheme;

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
          bottomNavigationBar: Builder(
            builder: (context) {
              final subscriptionAsync = ref.watch(
                seriesSubscriptionProvider(widget.seriesId),
              );
              final isSubscribed =
                  subscriptionAsync.asData?.value?.isActive ?? false;
              final isSubscriptionLoading =
                  subscriptionAsync.isLoading || _isUpdatingSubscription;
              return BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                    children: [
                      IconButton(
                        iconSize: 28,
                        tooltip: isSubscribed
                            ? 'Unsubscribe and remove pull'
                            : 'Subscribe and pull series',
                        onPressed: isSubscriptionLoading
                            ? null
                            : () {
                                _setSeriesSubscription(!isSubscribed);
                              },
                        icon: isSubscriptionLoading
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
                                color: isSubscribed
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        iconSize: 28,
                        tooltip: 'Add to reading list',
                        onPressed: () {
                          AddToReadingListBottomSheet.show(
                            context: context,
                            targetId: widget.seriesId.toString(),
                            isSeries: true,
                          );
                        },
                        icon: const Icon(Icons.playlist_add),
                      ),
                        const SizedBox(width: 4),
                        IconButton(
                          iconSize: 28,
                          tooltip: 'Favorite series',
                          onPressed: _toggleFavorite,
                          icon: ref
                              .watch(isSeriesFavoriteProvider(widget.seriesId))
                              .when(
                                data: (isFavorite) => Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 28,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                loading: () => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                error: (_, _) =>
                                    const Icon(Icons.favorite_border, size: 28),
                              ),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      onPressed: () => _showSeriesIssueActionsSheet(
                        seriesName: details.name,
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            },
          ),
          body: Builder(
            builder: (context) {
              final coverImageAsync = ref.watch(
                seriesCoverImageProvider((
                  seriesId: widget.seriesId,
                  allowRemoteFetch: true,
                )),
              );

              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      elevation: 0,
                      surfaceTintColor: colorScheme.surface,
                      expandedHeight: 260,
                      title: Opacity(
                        opacity: _titleOpacity,
                        child: Text(
                          details.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _SeriesHeroFlexibleSpace(
                          details: details,
                          coverImageAsync: coverImageAsync,
                          isSubscribed:
                              ref
                                  .watch(
                                    seriesSubscriptionProvider(widget.seriesId),
                                  )
                                  .asData
                                  ?.value
                                  ?.isActive ??
                              false,
                        ),
                      ),
                      actions: [
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
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SeriesTabBarDelegate(
                        child: Container(
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SeriesHeroFlexibleSpace extends StatelessWidget {
  const _SeriesHeroFlexibleSpace({
    required this.details,
    required this.coverImageAsync,
    required this.isSubscribed,
  });

  final SeriesDetails details;
  final AsyncValue<String?> coverImageAsync;
  final bool isSubscribed;

  String _formatSeriesType(String? type) {
    if (type == null) return '';
    final lower = type.toLowerCase();
    if (lower == 'single issue') return '';
    if (lower == 'limited series') return '';
    if (lower.contains('trade paperback') || lower.contains('tpb')) {
      return 'TPB';
    }
    if (lower.contains('hardcover') || lower.contains('hc')) return 'HC';
    if (lower.contains('graphic novel') || lower.contains('gn')) return 'GN';
    if (lower.contains('omnibus')) return 'Omnibus';
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publisher = details.publisher?.name.trim();
    final hasPublisher = details.publisher != null;
    Widget imageContent() {
      return coverImageAsync.when(
        data: (imageUrl) => imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              )
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_outlined, size: 40),
              ),
        loading: () => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, _) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.error_outline),
        ),
      );
    }

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageContent(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.38),
                  Colors.black.withValues(alpha: 0.08),
                  theme.colorScheme.surface.withValues(alpha: 0.86),
                  theme.colorScheme.surface,
                ],
                stops: const [0, 0.32, 0.62, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSubscribed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SUBSCRIBED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  details.seriesType?.name != null &&
                          details.seriesType!.name.isNotEmpty &&
                          _formatSeriesType(details.seriesType!.name).isNotEmpty
                      ? '${details.name} (${_formatSeriesType(details.seriesType!.name)})'
                      : details.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (hasPublisher)
                  Text(
                    publisher?.toUpperCase() ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '${details.yearBegan ?? '—'} • ${details.status ?? 'Unknown'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildAdditionalInformationSection(BuildContext context) {
    final start = details.yearBegan;
    final end = details.yearEnd;
    final years = (start == null && end == null)
        ? 'N/A'
        : (start != null && end != null)
        ? '$start - $end'
        : (start != null)
        ? '$start - Present'
        : 'Until $end';

    final genreText = details.genres.isNotEmpty
        ? details.genres.map((g) => g.name).join(', ')
        : 'N/A';

    final infoItems = <({String label, String value})>[
      (
        label: 'Status',
        value: details.status?.trim().isNotEmpty == true
            ? details.status!.trim()
            : 'N/A',
      ),
      (
        label: 'Volume',
        value: details.volume != null ? '${details.volume}' : 'N/A',
      ),
      (label: 'Years', value: years),
      (label: 'Type', value: details.seriesType?.name ?? 'N/A'),
      (
        label: 'Issues',
        value: details.issueCount != null ? '${details.issueCount}' : 'N/A',
      ),
      (label: 'Publisher', value: details.publisher?.name ?? 'N/A'),
      (label: 'Imprint', value: details.imprint?.name ?? 'N/A'),
      (label: 'Metron ID', value: '${details.id}'),
      if (details.cvId != null) (label: 'CV ID', value: '${details.cvId}'),
      if (details.gcdId != null) (label: 'GCD ID', value: '${details.gcdId}'),
      (label: 'Genres', value: genreText),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information', style: _sectionTitleStyle(context)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: infoItems.length,
          itemBuilder: (context, index) {
            final item = infoItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ],
    );
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: child,
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
    final modifiedValue = _modifiedValue();
    final hasDescription = description != null && description.isNotEmpty;
    final hasAssociated = associated.isNotEmpty;
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final noContent =
        !hasDescription &&
        !hasAssociated &&
        !hasModified &&
        details.genres.isEmpty;

    if (noContent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No about information available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (hasDescription) ...[
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
        ],
        if (hasAssociated) ...[
          if (hasDescription) const Divider(height: 24),
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
        ],
        if (hasDescription || hasAssociated) const Divider(height: 24),
        _buildSectionCard(context, _buildAdditionalInformationSection(context)),
        const Divider(height: 24),
        if (hasModified)
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}

class _SeriesIssuesTab extends ConsumerStatefulWidget {
  const _SeriesIssuesTab({
    required this.seriesId,
    required this.page,
    required this.onPrevious,
    required this.onNext,
  });

  final int seriesId;
  final int page;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  ConsumerState<_SeriesIssuesTab> createState() => _SeriesIssuesTabState();
}

class _SeriesIssuesTabState extends ConsumerState<_SeriesIssuesTab> {
  SeriesIssueListPage? _lastPage;

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(
        SortPreferenceContext.seriesDetailsIssues,
      ),
    );
    final args = SeriesIssueListArgs(
      seriesId: widget.seriesId,
      page: widget.page,
    );
    final issuesAsync = ref.watch(seriesIssueListProvider(args));

    if (issuesAsync.hasValue) {
      _lastPage = issuesAsync.value;
    }

    return issuesAsync.when(
      loading: () {
        if (_lastPage != null) {
          return _buildContent(
            context,
            ref,
            _lastPage!,
            sortOption,
            isLoading: true,
          );
        }
        return const AsyncStatePanel.loading();
      },
      error: (error, _) => AsyncStatePanel.error(
        errorMessage: 'Failed to load series issues: $error',
      ),
      data: (issuePage) =>
          _buildContent(context, ref, issuePage, sortOption, isLoading: false),
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
        sortedIssues.isEmpty && !isLoading
            ? ListView(
                padding: EdgeInsets.only(bottom: hasPagination ? 96 : 12),
                children: [
                  ListHeader(
                    count: issueCount,
                    unit: 'issue',
                    sortLabel: issueSortLabel(sortOption),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    enabled: !isLoading,
                    onSortTap: () {
                      showSortBottomSheet(
                        context,
                        ref,
                        SortPreferenceContext.seriesDetailsIssues,
                        issueSortLabel,
                      );
                    },
                  ),
                  const SizedBox(
                    height: 360,
                    child: EmptyContentState(
                      icon: Icons.menu_book_outlined,
                      message: 'No issues available.',
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 8, 0, hasPagination ? 96 : 12),
                itemCount: sortedIssues.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListHeader(
                          count: issueCount,
                          unit: 'issue',
                          sortLabel: issueSortLabel(sortOption),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          enabled: !isLoading,
                          onSortTap: () {
                            showSortBottomSheet(
                              context,
                              ref,
                              SortPreferenceContext.seriesDetailsIssues,
                              issueSortLabel,
                            );
                          },
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
                    );
                  }
                  final issue = sortedIssues[index - 1];
                  return Opacity(
                    opacity: isLoading ? 0.6 : 1.0,
                    child: IssueListTile(
                      issue: issue,
                      isFirst: index == 1,
                      isLast: index == sortedIssues.length,
                    ),
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
                  currentPage: widget.page,
                  totalPages: totalPages,
                  hasPrevious: issuePage.hasPrevious,
                  hasNext: issuePage.hasNext,
                  onPrevious: widget.onPrevious,
                  onNext: widget.onNext,
                  enabled: !isLoading,
                ),
              ),
            ),
          ),
      ],
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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              surfaceTintColor: theme.colorScheme.surface,
              expandedHeight: 260,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: theme.colorScheme.surfaceContainerHighest),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.black.withValues(alpha: 0.06),
                            theme.colorScheme.surface.withValues(alpha: 0.86),
                            theme.colorScheme.surface,
                          ],
                          stops: const [0, 0.32, 0.62, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 26,
                            width: double.infinity,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 20,
                            width: 190,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: 160,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SeriesTabBarDelegate(
                child: Container(
                  color: theme.colorScheme.surface,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'About'),
                      Tab(text: 'Issues'),
                    ],
                  ),
                ),
              ),
            ),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
