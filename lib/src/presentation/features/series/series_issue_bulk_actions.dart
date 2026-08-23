import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";

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
    this.imageUrl,
    this.storeDate,
  });

  final int issueId;
  final int orderIndex;
  final String issueNumber;
  final String? imageUrl;
  final DateTime? storeDate;
}

Future<List<SeriesIssueBulkCandidate>> allSeriesIssues(
  WidgetRef ref,
  int seriesId,
) async {
  final metronRepository = ref.read(metronRepositoryProvider);
  var page = 1;
  var orderIndex = 1;
  final issues = <SeriesIssueBulkCandidate>[];
  final visitedPages = <int>{};

  while (true) {
    if (!visitedPages.add(page)) break;
    final issuePage = await metronRepository.getSeriesIssueList(
      seriesId,
      page: page,
    );
    if (issuePage.results.isEmpty) break;

    for (final issue in issuePage.results) {
      final issueId = issue.id;
      if (issueId != null) {
        issues.add(
          SeriesIssueBulkCandidate(
            issueId: issueId,
            orderIndex: orderIndex,
            issueNumber: issue.number,
            storeDate: issue.storeDate,
            imageUrl: issue.image,
          ),
        );
        orderIndex++;
      }
    }
    final nextPage = issuePage.nextPage;
    if (nextPage == null || nextPage <= page) break;
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

int countAffectedIssue({
  required SeriesIssueSelectionMode selectionMode,
  required List<SeriesIssueBulkCandidate> issues,
  required Map<int, LibraryItem> existingByIssueId,
  SeriesIssueSubset? subset,
  int? startOrderIndex,
  int? endOrderIndex,
}) {
  if (selectionMode == SeriesIssueSelectionMode.range) {
    if (startOrderIndex == null || endOrderIndex == null) return 0;
    final start = startOrderIndex.clamp(1, issues.length);
    final end = endOrderIndex.clamp(start, issues.length);
    return end - start + 1;
  }

  final activeSubset = subset;
  if (activeSubset == null) return 0;
  var count = 0;
  for (final issue in issues) {
    final existing = existingByIssueId[issue.issueId];
    final isCollected =
        existing?.ownershipStatus == LibraryOwnershipStatus.owned;
    final isRead = existing?.isRead ?? false;
    if (matchesSubset(
      subset: activeSubset,
      isCollected: isCollected,
      isRead: isRead,
    )) {
      count++;
    }
  }
  return count;
}

Future<void> applySeriesIssueBulkAction({
  required BuildContext context,
  required WidgetRef ref,
  required int seriesId,
  required String seriesName,
  required SeriesIssueBulkOperation operation,
  required SeriesIssueSelectionMode selectionMode,
  required List<SeriesIssueBulkCandidate> issues,
  SeriesIssueSubset? subset,
  int? startOrderIndex,
  int? endOrderIndex,
}) async {
  try {
    final libraryRepository = ref.read(libraryRepositoryProvider);
    final activityRepository = ref.read(activityRepositoryProvider);
    final imageCache = ref.read(entityImageCacheProvider);
    final existingItems = await libraryRepository.getItemsBySeriesId(seriesId);
    final existingByIssueId = {
      for (final e in existingItems) e.metronIssueId: e,
    };
    var affected = 0;
    final affectedIssueIds = <int>{};
    final now = DateTime.now().toUtc();

    final itemsToUpsert = <LibraryItem>[];
    final eventsToAdd = <LibraryActivityEvent>[];
    final readLogsToAdd = <LibraryReadLog>[];
    final issueIdsToDelete = <int>[];
    final readLogItemIdsToDelete = <String>[];
    final imageCacheEntries = <int, String>{};

    for (final issue in issues) {
      final issueId = issue.issueId;
      final existing = existingByIssueId[issueId];
      final isCollected =
          existing?.ownershipStatus == LibraryOwnershipStatus.owned;
      final isRead = existing?.isRead ?? false;

      final matchesSelection = selectionMode == SeriesIssueSelectionMode.range
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
        itemsToUpsert.add(
          LibraryItem(
            id: existing?.id ?? "lib-$issueId",
            userId: "local-user",
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
            acquiredOn: existing?.acquiredOn ?? now,
            notes: existing?.notes,
            createdAt: existing?.createdAt != null ? existing!.createdAt : now,
            updatedAt: now,
          ),
        );
        eventsToAdd.add(
          LibraryActivityEvent(
            id: "act-col-$issueId-${now.microsecondsSinceEpoch}",
            userId: "local-user",
            type: ActivityEventType.collected,
            issueId: issueId,
            seriesId: seriesId,
            seriesName: seriesName,
            issueNumber: issue.issueNumber,
            imageUrl: issue.imageUrl,
            timestamp: now,
          ),
        );
        if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty) {
          imageCacheEntries[issueId] = issue.imageUrl!;
        }
        affectedIssueIds.add(issueId);
        affected++;
        continue;
      }

      if (operation == SeriesIssueBulkOperation.removeFromCollection) {
        if (!isCollected) continue;
        issueIdsToDelete.add(issueId);
        affectedIssueIds.add(issueId);
        affected++;
        continue;
      }

      if (operation == SeriesIssueBulkOperation.markAsRead) {
        if (isRead) continue;
        final ownershipStatus =
            existing?.ownershipStatus ?? LibraryOwnershipStatus.notOwned;
        itemsToUpsert.add(
          LibraryItem(
            id: existing?.id ?? "lib-$issueId",
            userId: "local-user",
            metronIssueId: issueId,
            metronSeriesId: seriesId,
            ownershipStatus: ownershipStatus,
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
            createdAt: existing?.createdAt != null ? existing!.createdAt : now,
            updatedAt: now,
          ),
        );
        readLogsToAdd.add(
          LibraryReadLog(
            id: "read-$issueId-${now.microsecondsSinceEpoch}",
            userId: "local-user",
            collectionItemId: "lib-$issueId",
            readAt: now,
            createdAt: now,
          ),
        );
        eventsToAdd.add(
          LibraryActivityEvent(
            id: "act-read-$issueId-${now.microsecondsSinceEpoch}",
            userId: "local-user",
            type: ActivityEventType.read,
            issueId: issueId,
            seriesId: seriesId,
            seriesName: seriesName,
            issueNumber: issue.issueNumber,
            imageUrl: issue.imageUrl,
            timestamp: now,
          ),
        );
        if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty) {
          imageCacheEntries[issueId] = issue.imageUrl!;
        }
        affectedIssueIds.add(issueId);
        affected++;
        continue;
      }

      if (operation == SeriesIssueBulkOperation.markAsUnread) {
        if (!isRead) continue;
        final ownershipStatus =
            existing?.ownershipStatus ?? LibraryOwnershipStatus.notOwned;
        itemsToUpsert.add(
          LibraryItem(
            id: existing?.id ?? "lib-$issueId",
            userId: "local-user",
            metronIssueId: issueId,
            metronSeriesId: seriesId,
            ownershipStatus: ownershipStatus,
            isRead: false,
            rating: existing?.rating,
            purchaseDate: existing?.purchaseDate,
            pricePaid: existing?.pricePaid,
            quantityOwned: existing?.quantityOwned ?? 1,
            format: existing?.format ?? LibraryItemFormat.print,
            firstReadAt: null,
            conditionGrade: existing?.conditionGrade,
            acquiredOn: existing?.acquiredOn ?? now,
            notes: existing?.notes,
            createdAt: existing?.createdAt != null ? existing!.createdAt : now,
            updatedAt: now,
          ),
        );
        readLogItemIdsToDelete.add("lib-$issueId");
        affectedIssueIds.add(issueId);
        affected++;
      }
    }

    if (imageCacheEntries.isNotEmpty) {
      await imageCache.setMany("issue", imageCacheEntries);
    }
    if (itemsToUpsert.isNotEmpty) {
      await libraryRepository.batchUpsertItems(seriesId, itemsToUpsert);
    }
    if (eventsToAdd.isNotEmpty) {
      final batchId = "batch_${DateTime.now().millisecondsSinceEpoch}";
      await activityRepository.batchAddEvents(eventsToAdd, batchId: batchId);
    }
    if (readLogsToAdd.isNotEmpty) {
      await libraryRepository.batchAddReadLogs(readLogsToAdd);
    }
    if (issueIdsToDelete.isNotEmpty) {
      await libraryRepository.batchDeleteItemsByIssueId(issueIdsToDelete);
    }
    if (readLogItemIdsToDelete.isNotEmpty) {
      await libraryRepository.batchDeleteReadLogsByItemIds(
        readLogItemIdsToDelete,
      );
    }

    if (operation == SeriesIssueBulkOperation.removeFromCollection &&
        issueIdsToDelete.isNotEmpty) {
      await activityRepository.deleteEventsByIssueIds(
        issueIdsToDelete,
        type: ActivityEventType.collected,
      );
    }
    if (operation == SeriesIssueBulkOperation.markAsUnread &&
        affectedIssueIds.isNotEmpty) {
      await activityRepository.deleteEventsByIssueIds(
        affectedIssueIds.toList(),
        type: ActivityEventType.read,
      );
    }

    if (context.mounted) {
      final actionText = switch (operation) {
        SeriesIssueBulkOperation.addToCollection => "Added to Collection",
        SeriesIssueBulkOperation.removeFromCollection =>
          "Removed from Collection",
        SeriesIssueBulkOperation.markAsRead => "Marked as Read",
        SeriesIssueBulkOperation.markAsUnread => "Marked as Unread",
      };
      TakionAlerts.success(context, "$affected $actionText");
      Navigator.of(context).pop();
    }
  } catch (error) {
    if (context.mounted) {
      TakionAlerts.safeError(
        context,
        error,
        userMessage: "Failed to apply series issue action",
      );
    }
  }
}

int? findClosestIssueIndex(
  List<SeriesIssueBulkCandidate> issues,
  String input, {
  int? startAfter,
}) {
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
  Map<int, LibraryItem> existingByIssueId = {};
  var selectedOperation = SeriesIssueBulkOperation.addToCollection;
  var selectedMode = SeriesIssueSelectionMode.predefined;
  var selectedSubset = SeriesIssueSubset.all;
  var rangeStart = 1;
  var rangeEnd = 1;
  var isApplying = false;

  TakionBottomSheet.show<void>(
    context: context,
    title: seriesYear != null ? "$seriesName ($seriesYear)" : seriesName,
    child: StatefulBuilder(
      builder: (context, setModalState) {
        if (isLoading) {
          if (!hasStarted) {
            hasStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final fetched = await allSeriesIssues(ref, seriesId);
                if (!context.mounted) return;
                if (fetched.isEmpty) {
                  Navigator.of(context).pop();
                  TakionAlerts.info(context, "No issues found");
                  return;
                }
                final existingItems = await ref
                    .read(libraryRepositoryProvider)
                    .getItemsBySeriesId(seriesId);
                if (!context.mounted) return;
                existingByIssueId = {
                  for (final e in existingItems) e.metronIssueId: e,
                };
                setModalState(() {
                  issues = fetched;
                  totalIssues = fetched.length;
                  rangeStart = 1;
                  rangeEnd = totalIssues;
                  isLoading = false;
                });
              } catch (error) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                TakionAlerts.safeError(
                  context,
                  error,
                  userMessage: "Failed to load series issues",
                );
              }
            });
          }
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        String operationLabel(SeriesIssueBulkOperation value) {
          switch (value) {
            case SeriesIssueBulkOperation.addToCollection:
              return "Add to Collection";
            case SeriesIssueBulkOperation.removeFromCollection:
              return "Remove from Collection";
            case SeriesIssueBulkOperation.markAsRead:
              return "Mark as Read";
            case SeriesIssueBulkOperation.markAsUnread:
              return "Mark as Unread";
          }
        }

        String selectionModeLabel(SeriesIssueSelectionMode value) {
          switch (value) {
            case SeriesIssueSelectionMode.predefined:
              return "Filters";
            case SeriesIssueSelectionMode.range:
              return "Issue range";
          }
        }

        String subsetLabel(SeriesIssueSubset value) {
          switch (value) {
            case SeriesIssueSubset.all:
              return "All issues";
            case SeriesIssueSubset.collected:
              return "Collected issues";
            case SeriesIssueSubset.uncollected:
              return "Uncollected issues";
            case SeriesIssueSubset.read:
              return "Read issues";
            case SeriesIssueSubset.unread:
              return "Unread issues";
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
              return const [SeriesIssueSubset.all, SeriesIssueSubset.collected];
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

        final selectedStart = rangeStart;
        final selectedEnd = rangeEnd;
        final startIssueNumber = issues[selectedStart - 1].issueNumber;
        final endIssueNumber = issues[selectedEnd - 1].issueNumber;
        final affectedCount = countAffectedIssue(
          selectionMode: selectedMode,
          issues: issues,
          existingByIssueId: existingByIssueId,
          subset: selectedMode == SeriesIssueSelectionMode.predefined
              ? selectedSubset
              : null,
          startOrderIndex: selectedMode == SeriesIssueSelectionMode.range
              ? selectedStart
              : null,
          endOrderIndex: selectedMode == SeriesIssueSelectionMode.range
              ? selectedEnd
              : null,
        );

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Action",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                  children: SeriesIssueBulkOperation.values.map((operation) {
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
                "Selection method",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
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
              if (selectedMode == SeriesIssueSelectionMode.predefined)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apply to",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Issue range",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "#$startIssueNumber – #$endIssueNumber",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: startIssueNumber,
                            decoration: const InputDecoration(
                              labelText: "From issue #",
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !isApplying,
                            onChanged: (v) {
                              if (v.isEmpty) return;
                              final idx = findClosestIssueIndex(
                                issues,
                                v,
                                startAfter: null,
                              );
                              if (idx != null && idx + 1 <= rangeEnd) {
                                setModalState(() {
                                  rangeStart = idx + 1;
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
                              labelText: "To issue #",
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !isApplying,
                            onChanged: (v) {
                              if (v.isEmpty) return;
                              final idx = findClosestIssueIndex(
                                issues,
                                v,
                                startAfter: rangeStart - 1,
                              );
                              if (idx != null && idx + 1 <= totalIssues) {
                                setModalState(() {
                                  rangeEnd = idx + 1;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operationLabel(selectedOperation),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$affectedCount ${affectedCount == 1 ? 'Issue' : 'Issues'}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: isApplying
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isApplying || affectedCount == 0
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
                                seriesName: seriesName,
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
                        : const Text("Apply"),
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
