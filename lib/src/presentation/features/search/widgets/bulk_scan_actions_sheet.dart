import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart";
import "package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart";
import "package:takion/src/presentation/features/library/providers/continue_reading_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";

enum BulkAction {
  addToPullList,
  addToCollection,
  markAsRead,
  addToWishlist,
  rate,
}

class _BulkActionState {
  bool selected = false;
  int rating = -1;
}

Future<void> showBulkScanActionsSheet(
  BuildContext context,
  WidgetRef ref, {
  required List<int> issueIds,
  Map<int, int>? issueSeriesIds,
  Map<int, DateTime>? issueReleaseDates,
  VoidCallback? onApplied,
}) async {
  if (issueIds.isEmpty) return;

  final actionsState = {
    BulkAction.addToPullList: _BulkActionState(),
    BulkAction.addToCollection: _BulkActionState(),
    BulkAction.markAsRead: _BulkActionState(),
    BulkAction.addToWishlist: _BulkActionState(),
    BulkAction.rate: _BulkActionState(),
  };

  if (!context.mounted) return;

  final alertContext = context;

  bool isApplying = false;
  TakionBottomSheet.show<void>(
    context: context,
    title: "Bulk Actions (${issueIds.length} issues)",
    isScrollControlled: true,
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ActionCheckboxTile(
                icon: Icons.shopping_bag_outlined,
                title: "Add to Pull List",
                selected: actionsState[BulkAction.addToPullList]!.selected,
                onChanged: (value) {
                  setSheetState(() {
                    actionsState[BulkAction.addToPullList]!.selected = value!;
                  });
                },
              ),
              _ActionCheckboxTile(
                icon: Icons.inventory_2_outlined,
                title: "Add to Collection",
                selected: actionsState[BulkAction.addToCollection]!.selected,
                onChanged: (value) {
                  setSheetState(() {
                    actionsState[BulkAction.addToCollection]!.selected = value!;
                    if (value == true) {
                      actionsState[BulkAction.addToWishlist]!.selected = false;
                    }
                  });
                },
              ),
              _ActionCheckboxTile(
                icon: Icons.bookmark_added_outlined,
                title: "Mark as Read",
                selected: actionsState[BulkAction.markAsRead]!.selected,
                onChanged: (value) {
                  setSheetState(() {
                    actionsState[BulkAction.markAsRead]!.selected = value!;
                  });
                },
              ),
              _ActionCheckboxTile(
                icon: Icons.turned_in_not,
                title: "Add to Wishlist",
                selected: actionsState[BulkAction.addToWishlist]!.selected,
                onChanged: (value) {
                  setSheetState(() {
                    actionsState[BulkAction.addToWishlist]!.selected = value!;
                    if (value == true) {
                      actionsState[BulkAction.addToCollection]!.selected =
                          false;
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RatingPicker(
                  selectedRating: actionsState[BulkAction.rate]!.rating.clamp(
                    0,
                    5,
                  ),
                  enabled: true,
                  onChanged: (value) {
                    setSheetState(() {
                      actionsState[BulkAction.rate]!.rating = value;
                      actionsState[BulkAction.rate]!.selected = true;
                    });
                  },
                  onReset: () {
                    setSheetState(() {
                      actionsState[BulkAction.rate]!.rating = -1;
                      actionsState[BulkAction.rate]!.selected = false;
                    });
                  },
                  iconSize: 40,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: isApplying
                      ? null
                      : () async {
                          setSheetState(() => isApplying = true);
                          final selected = actionsState.entries
                              .where((e) => e.value.selected)
                              .map((e) => e.key)
                              .toList();
                          if (selected.isEmpty) {
                            setSheetState(() => isApplying = false);
                            TakionAlerts.info(
                              context,
                              "Select at least one action",
                            );
                            return;
                          }
                          await _applyBulkActions(
                            alertContext,
                            ref,
                            issueIds: issueIds,
                            actions: actionsState,
                            issueSeriesIds: issueSeriesIds,
                            issueReleaseDates: issueReleaseDates,
                            onApplied: onApplied,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  icon: isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(isApplying ? "Applying..." : "APPLY"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _applyBulkActions(
  BuildContext context,
  WidgetRef ref, {
  required List<int> issueIds,
  required Map<BulkAction, _BulkActionState> actions,
  Map<int, int>? issueSeriesIds,
  Map<int, DateTime>? issueReleaseDates,
  VoidCallback? onApplied,
}) async {
  var successCount = 0;
  var errorCount = 0;
  final totalCount = issueIds.length;
  final errorMessages = <String>[];
  final cacheUpdates = <MapEntry<int, IssueCollectionStatus>>[];

  final selectedActions = actions.entries
      .where((e) => e.value.selected)
      .map((e) => e.key.name)
      .join(", ");
  AppLogger.info(
    "BulkActions: applying [$selectedActions] to $totalCount issues",
  );

  try {
    final libraryRepo = ref.read(libraryRepositoryProvider);
    final pullRepo = ref.read(pullListRepositoryProvider);
    final catalogRepo = ref.read(catalogRepositoryProvider);
    final now = DateTime.now().toUtc();

    for (final issueId in issueIds) {
      try {
        final existing = await libraryRepo.getItemByIssueId(issueId);
        var seriesId = existing?.metronSeriesId;
        if (seriesId == null || seriesId <= 0) {
          seriesId = issueSeriesIds?[issueId];
        }
        if (seriesId == null || seriesId <= 0) {
          final pullEntry = await pullRepo.getEntryByIssueId(issueId);
          seriesId = pullEntry?.metronSeriesId;
        }
        if (seriesId == null || seriesId <= 0) {
          final libItem = await libraryRepo.getItemByIssueId(issueId);
          seriesId = libItem?.metronSeriesId;
        }
        if (seriesId == null || seriesId <= 0) {
          try {
            final details = await catalogRepo.getIssueDetails(issueId);
            seriesId = details.series?.id;
          } catch (e) {
            AppLogger.debug(
              "Failed to resolve series for bulk scan issue $issueId",
              error: e,
            );
          }
        }
        if (seriesId == null || seriesId <= 0) {
          errorCount++;
          errorMessages.add("Issue $issueId: no linked series");
          continue;
        }

        if (actions[BulkAction.addToPullList]?.selected == true) {
          await pullRepo.upsertManualEntry(
            metronIssueId: issueId,
            metronSeriesId: seriesId,
            releaseDate: issueReleaseDates?[issueId],
          );
        }

        final wantCollection =
            actions[BulkAction.addToCollection]?.selected == true;
        final wantWishlist =
            actions[BulkAction.addToWishlist]?.selected == true;
        final wantRead = actions[BulkAction.markAsRead]?.selected == true;
        final wantRate =
            actions[BulkAction.rate]?.selected == true &&
            actions[BulkAction.rate]!.rating > 0;

        if (wantCollection || wantWishlist || wantRead || wantRate) {
          var ownershipStatus =
              existing?.ownershipStatus ?? LibraryOwnershipStatus.notOwned;
          if (wantCollection) {
            ownershipStatus = LibraryOwnershipStatus.owned;
          } else if (wantWishlist) {
            ownershipStatus = LibraryOwnershipStatus.wishlist;
          }

          final targetRating = wantRate
              ? actions[BulkAction.rate]!.rating
              : existing?.rating;

          final wasRead = existing?.isRead ?? false;

          await libraryRepo.upsertItem(
            metronIssueId: issueId,
            metronSeriesId: seriesId,
            ownershipStatus: ownershipStatus,
            isRead: wantRead || wasRead,
            rating: (wantRead || wantRate) ? targetRating : existing?.rating,
            firstReadAt: wantRead && !wasRead ? now : existing?.firstReadAt,
            format: existing?.format ?? LibraryItemFormat.print,
            acquiredOn: wantCollection
                ? (existing?.acquiredOn ?? now)
                : existing?.acquiredOn,
          );

          if (wantRead && !wasRead) {
            await libraryRepo.addReadLog(metronIssueId: issueId, readAt: now);
          }

          final activityRepo = ref.read(activityRepositoryProvider);
          final imageCache = ref.read(entityImageCacheProvider);
          String seriesName = "Unknown Series";
          String issueNumber = "#$issueId";
          String? imageUrl;
          try {
            imageUrl = await imageCache.get("issue", issueId);
          } catch (e) {
            AppLogger.debug(
              "Failed to read cached image during bulk scan",
              error: e,
            );
          }
          if (imageUrl == null || imageUrl.isEmpty) {
            try {
              final details = await catalogRepo.getIssueDetails(issueId);
              seriesName = details.series?.name ?? "Unknown Series";
              issueNumber = details.number;
              imageUrl = details.image;
            } catch (e) {
              AppLogger.debug(
                "Failed to load issue details during bulk scan",
                error: e,
              );
            }
          }

          if (wantCollection &&
              existing?.ownershipStatus != LibraryOwnershipStatus.owned) {
            await activityRepo.addEvent(
              LibraryActivityEvent(
                id: "act-col-$issueId-${DateTime.now().microsecondsSinceEpoch}",
                userId: "local-user",
                type: ActivityEventType.collected,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          }

          if (wantWishlist &&
              existing?.ownershipStatus != LibraryOwnershipStatus.wishlist) {
            await activityRepo.addEvent(
              LibraryActivityEvent(
                id: "act-wsh-$issueId-${DateTime.now().microsecondsSinceEpoch}",
                userId: "local-user",
                type: ActivityEventType.wishlisted,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          }

          if (wantRead && !wasRead) {
            await activityRepo.addEvent(
              LibraryActivityEvent(
                id: "act-read-$issueId-${DateTime.now().microsecondsSinceEpoch}",
                userId: "local-user",
                type: ActivityEventType.read,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          }

          // Rated events intentionally not recorded per user requirement

          cacheUpdates.add(
            MapEntry(
              issueId,
              IssueCollectionStatus(
                isCollected: wantCollection,
                isWishlisted: wantWishlist,
                isRead: wantRead || wasRead,
                rating: (wantRead || wantRate)
                    ? targetRating
                    : existing?.rating,
              ),
            ),
          );
        }

        successCount++;
      } catch (e) {
        errorCount++;
        errorMessages.add("Issue $issueId: $e");
      }
    }

    ref.invalidate(continueReadingAllSuggestionsProvider);
    ref.invalidate(continueReadingSuggestionsProvider);
    ref.invalidate(currentWeekPullsProvider);
    ref.invalidate(pullListEntriesForWeekProvider);
    ref.invalidate(pullsIssuesForWeekProvider);

    if (actions[BulkAction.addToPullList]?.selected == true) {
      for (final issueId in issueIds) {
        ref.invalidate(issuePullListEntryProvider(issueId));
      }
    }

    if (cacheUpdates.isNotEmpty) {
      ref.invalidate(collectionStatusCacheProvider);
    }

    if (!context.mounted) return;

    AppLogger.info(
      "BulkActions: result $successCount/$totalCount succeeded, $errorCount failed",
    );

    if (errorCount == 0) {
      if (successCount > 0) {
        onApplied?.call();
      }
      TakionAlerts.success(context, "$successCount/$totalCount issues updated");
    } else {
      final sample = errorMessages.take(3).join("\n");
      TakionAlerts.error(
        context,
        "$successCount updated, $errorCount failed\n$sample",
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    TakionAlerts.safeError(context, e, userMessage: "Bulk action failed");
  }
}

class _ActionCheckboxTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const _ActionCheckboxTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: selected,
      onChanged: onChanged,
    );
  }
}
