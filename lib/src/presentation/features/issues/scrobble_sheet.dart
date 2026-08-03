import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/issues/issue_details/issue_my_details_sheets.dart';
import 'package:takion/src/presentation/features/issues/issue_share_util.dart';
import 'package:takion/src/presentation/features/issues/series_subscription_toggle.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/add_to_local_reading_list_bottom_sheet.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/domain/entities.dart';

class _ScrobbleActionIcon extends StatelessWidget {
  const _ScrobbleActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: 36,
          color: color,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

Future<void> showScrobbleSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int issueId,
  String? sheetTitle,
  int? seriesId,
  bool? isSubscribed,
  DateTime? releaseDate,
  String? seriesName,
  String? issueNumber,
  String? imageUrl,
}) async {
  final title = sheetTitle ?? 'Issue #$issueId';

  // Series id is supplied by the caller from the issue-list data (which always
  // includes the series), so the Subscribe tile can render immediately without
  // fetching full issue details.
  final resolvedSeriesId = seriesId;

  var isPulling = false;
  var isSharing = false;
  final notifier = ref.read(scrobbleIssueProvider(issueId).notifier);
  notifier.reset();
  notifier.setContext(
    ScrobbleIssueContext(
      seriesId: seriesId,
      seriesName: seriesName,
      issueNumber: issueNumber,
      imageUrl: imageUrl,
    ),
  );

  if (!context.mounted) return;

  final callerContext = context;

  // Working state lives outside the Consumer build so optimistic edits made
  // while a scrobble is in flight aren't clobbered on every rebuild. The
  // provider value is only adopted when a genuinely new committed status
  // arrives (identity change) and the sheet isn't submitting.
  var addToCollection = false;
  var markAsRead = false;
  var addToWishlist = false;
  var selectedRating = 0;
  IssueCollectionStatus? lastAdoptedStatus;

  TakionBottomSheet.show<void>(
    context: context,
    title: title,
    child: Consumer(
      builder: (context, ref, _) {
        final scrobbleState = ref.watch(scrobbleIssueProvider(issueId));
        final isSubmitting = scrobbleState.isLoading;
        final submitError = scrobbleState.whenOrNull(
          error: (error, _) => error,
        );

        final effectiveSeriesId =
            seriesId ?? ref.watch(issueSeriesIdProvider(issueId)).value;
        final subState = effectiveSeriesId != null
            ? ref.watch(seriesSubscriptionProvider(effectiveSeriesId))
            : null;
        final liveSubscribed = subState?.asData?.value?.isActive ?? false;
        final pullEntryWatch = ref.watch(issuePullListEntryProvider(issueId));
        final pullEntry = pullEntryWatch.asData?.value;
        final pullIssue =
            pullEntry != null &&
            pullEntry.entryStatus != PullListEntryStatus.skipped;
        final collectionStatus = ref.watch(
          issueCollectionStatusProvider(issueId),
        );
        final isCollected = collectionStatus?.isCollected ?? false;
        final isRead = collectionStatus?.isRead ?? false;

        if (!isSubmitting && !identical(collectionStatus, lastAdoptedStatus)) {
          lastAdoptedStatus = collectionStatus;
          addToCollection = collectionStatus?.isCollected ?? false;
          markAsRead = collectionStatus?.isRead ?? false;
          addToWishlist = collectionStatus?.isWishlisted ?? false;
          selectedRating = (collectionStatus?.rating ?? 0).clamp(0, 5);
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            Color toggleColor(bool enabled) => enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ScrobbleActionIcon(
                      icon: addToCollection
                          ? Icons.inventory_2
                          : Icons.inventory_2_outlined,
                      label: 'Collected',
                      color: toggleColor(addToCollection),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              final newValue = !addToCollection;
                              final previousWishlist = addToWishlist;
                              setModalState(() {
                                addToCollection = newValue;
                                if (newValue) addToWishlist = false;
                              });
                              ref
                                  .read(scrobbleIssueProvider(issueId).notifier)
                                  .scrobble(
                                    addToCollection: newValue,
                                    addToWishlist: newValue ? false : null,
                                  )
                                  .then((_) {
                                    if (!context.mounted) return;
                                    if (ref
                                        .read(scrobbleIssueProvider(issueId))
                                        .hasError) {
                                      setModalState(() {
                                        addToCollection = !newValue;
                                        if (newValue) {
                                          addToWishlist = previousWishlist;
                                        }
                                      });
                                    } else if (newValue) {
                                      AppLogger.info(
                                        'Scrobble: added issue #$issueId to collection',
                                      );
                                      TakionAlerts.libraryAddedToCollection(
                                        context,
                                      );
                                    } else {
                                      AppLogger.info(
                                        'Scrobble: removed issue #$issueId from collection',
                                      );
                                    }
                                  });
                            },
                    ),
                    const SizedBox(width: 24),
                    _ScrobbleActionIcon(
                      icon: markAsRead
                          ? Icons.bookmark_added
                          : Icons.bookmark_added_outlined,
                      label: 'Read',
                      color: toggleColor(markAsRead),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              final newValue = !markAsRead;
                              final previousRating = selectedRating;
                              setModalState(() {
                                markAsRead = newValue;
                                if (!newValue) selectedRating = 0;
                              });
                              ref
                                  .read(scrobbleIssueProvider(issueId).notifier)
                                  .scrobble(
                                    markAsRead: newValue,
                                    dateRead: newValue
                                        ? DateTime.now().toUtc()
                                        : null,
                                    rating: newValue && selectedRating > 0
                                        ? selectedRating
                                        : null,
                                  )
                                  .then((_) {
                                    if (!context.mounted) return;
                                    if (ref
                                        .read(scrobbleIssueProvider(issueId))
                                        .hasError) {
                                      setModalState(() {
                                        markAsRead = !newValue;
                                        selectedRating = previousRating;
                                      });
                                    } else if (newValue) {
                                      AppLogger.info(
                                        'Scrobble: marked issue #$issueId as read',
                                      );
                                      TakionAlerts.libraryMarkedAsRead(context);
                                    } else {
                                      AppLogger.info(
                                        'Scrobble: unmarked issue #$issueId as read',
                                      );
                                    }
                                  });
                            },
                    ),
                    const SizedBox(width: 24),
                    _ScrobbleActionIcon(
                      icon: pullIssue
                          ? Icons.shopping_bag
                          : Icons.shopping_bag_outlined,
                      label: 'Pull',
                      color: toggleColor(pullIssue),
                      onPressed:
                          isSubmitting || isPulling || pullEntryWatch.isLoading
                          ? null
                          : () async {
                              final currentlyPulled = pullIssue;
                              final newValue = !currentlyPulled;
                              final seriesIdLocal = resolvedSeriesId;

                              if (newValue && seriesIdLocal == null) {
                                TakionAlerts.noLinkedSeriesForIssue(context);
                                return;
                              }

                              isPulling = true;
                              setModalState(() {});
                              bool didUpdate = false;

                              try {
                                if (!newValue) {
                                  await ref
                                      .read(pullListRepositoryProvider)
                                      .updateEntryStatus(
                                        metronIssueId: issueId,
                                        status: PullListEntryStatus.skipped,
                                      );
                                  AppLogger.info(
                                    'Scrobble: dismissed issue #$issueId from pull list',
                                  );
                                } else {
                                  await ref
                                      .read(pullListRepositoryProvider)
                                      .upsertManualEntry(
                                        metronSeriesId: seriesIdLocal!,
                                        metronIssueId: issueId,
                                        releaseDate: releaseDate,
                                      );
                                  AppLogger.info(
                                    'Scrobble: added issue #$issueId to pull list',
                                  );
                                  final sub = await ref
                                      .read(subscriptionRepositoryProvider)
                                      .getSubscriptionBySeriesId(seriesIdLocal);
                                  if (sub != null && sub.isActive) {
                                    unawaited(
                                      ref
                                          .read(
                                            subscriptionPullReconcilerProvider,
                                          )
                                          .reconcile(
                                            force: true,
                                            onlySeriesId: seriesIdLocal,
                                          ),
                                    );
                                  }
                                }
                                didUpdate = true;

                                if (context.mounted) {
                                  if (newValue) {
                                    TakionAlerts.success(
                                      context,
                                      'Added to Pull List',
                                    );
                                  } else {
                                    TakionAlerts.info(
                                      context,
                                      'Dismissed from Pull List',
                                    );
                                  }
                                }
                              } catch (e) {
                                AppLogger.warning(
                                  'Failed to update pull list',
                                  error: e,
                                );
                                if (context.mounted) {
                                  TakionAlerts.error(
                                    context,
                                    'Failed to update pull list',
                                  );
                                }
                              } finally {
                                isPulling = false;
                                if (context.mounted) {
                                  setModalState(() {});
                                }
                                if (didUpdate) {
                                  ref.invalidate(currentWeekPullsProvider);
                                  ref.invalidate(
                                    pullListEntriesForWeekProvider,
                                  );
                                  ref.invalidate(pullsIssuesForWeekProvider);
                                  ref.invalidate(currentWeekPullsCountProvider);
                                  ref.invalidate(
                                    issuePullListEntryProvider(issueId),
                                  );
                                }
                              }
                            },
                    ),
                    const SizedBox(width: 24),
                    _ScrobbleActionIcon(
                      icon: addToWishlist
                          ? Icons.turned_in
                          : Icons.turned_in_not,
                      label: 'Wishlist',
                      color: toggleColor(addToWishlist),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              final newValue = !addToWishlist;
                              final previousCollection = addToCollection;
                              setModalState(() {
                                addToWishlist = newValue;
                                if (newValue) addToCollection = false;
                              });
                              ref
                                  .read(scrobbleIssueProvider(issueId).notifier)
                                  .scrobble(
                                    addToWishlist: newValue,
                                    addToCollection: newValue ? false : null,
                                  )
                                  .then((_) {
                                    if (!context.mounted) return;
                                    if (ref
                                        .read(scrobbleIssueProvider(issueId))
                                        .hasError) {
                                      setModalState(() {
                                        addToWishlist = !newValue;
                                        if (newValue) {
                                          addToCollection = previousCollection;
                                        }
                                      });
                                    } else if (newValue) {
                                      TakionAlerts.libraryUpdated(context);
                                    }
                                  });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Center(
                  child: RatingPicker(
                    selectedRating: selectedRating,
                    enabled: !isSubmitting,
                    onChanged: (value) {
                      final previousRead = markAsRead;
                      final previousRating = selectedRating;
                      setModalState(() {
                        selectedRating = value;
                        markAsRead = true;
                      });
                      ref
                          .read(scrobbleIssueProvider(issueId).notifier)
                          .scrobble(
                            markAsRead: true,
                            rating: value,
                            dateRead: DateTime.now().toUtc(),
                          )
                          .then((_) {
                            if (!context.mounted) return;
                            if (ref
                                .read(scrobbleIssueProvider(issueId))
                                .hasError) {
                              setModalState(() {
                                selectedRating = previousRating;
                                markAsRead = previousRead;
                              });
                            } else {
                              TakionAlerts.libraryMarkedAsRead(context);
                            }
                          });
                    },
                    onReset: () {
                      final previousRating = selectedRating;
                      setModalState(() {
                        selectedRating = 0;
                      });
                      ref
                          .read(scrobbleIssueProvider(issueId).notifier)
                          .scrobble(rating: 0)
                          .then((_) {
                            if (!context.mounted) return;
                            if (ref
                                .read(scrobbleIssueProvider(issueId))
                                .hasError) {
                              setModalState(() {
                                selectedRating = previousRating;
                              });
                            }
                          });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                if (effectiveSeriesId != null)
                  _SubscribeTile(
                    seriesId: effectiveSeriesId,
                    initialSubscribed: liveSubscribed,
                    callerContext: callerContext,
                  ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Add to Reading List'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => AddToLocalReadingListBottomSheet.show(
                    context: callerContext,
                    targetId: 'issue-$issueId',
                    isSeries: false,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: isCollected
                      ? ListTile(
                          leading: const Icon(Icons.library_books_outlined),
                          title: const Text('My Details'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showEditMyDetailsSheet(
                            callerContext,
                            ref,
                            issueId,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: isRead
                      ? ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Reading History'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showReadingHistorySheet(
                            callerContext,
                            ref,
                            issueId,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                ListTile(
                  leading: isSharing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  title: const Text('Share'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isSharing
                      ? null
                      : () async {
                          setModalState(() => isSharing = true);
                          try {
                            AppLogger.info(
                              'Share: fetching issue #$issueId details',
                            );
                            final repo = ref.read(catalogRepositoryProvider);
                            final details = await repo.getIssueDetails(issueId);

                            if (!context.mounted) return;

                            final resourceUrl = details.resourceUrl?.trim();
                            AppLogger.info(
                              'Share: issue #$issueId resourceUrl=$resourceUrl',
                            );

                            if (resourceUrl == null || resourceUrl.isEmpty) {
                              TakionAlerts.noShareUrl(callerContext, 'issue');
                              return;
                            }

                            await shareIssueResourceUrl(callerContext, details);
                            AppLogger.info(
                              'Share: completed for issue #$issueId',
                            );
                          } catch (e) {
                            AppLogger.warning(
                              'Share: failed for issue #$issueId',
                              error: e,
                            );
                            if (context.mounted) {
                              TakionAlerts.error(
                                callerContext,
                                'Could not load issue details',
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setModalState(() => isSharing = false);
                            }
                          }
                        },
                ),
                if (submitError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    () {
                      final raw = submitError.toString().trim();
                      var cleaned = raw
                          .replaceFirst(
                            RegExp(
                              r'^(Exception|StateError|DioException|PlatformException): ',
                            ),
                            '',
                          )
                          .trim();
                      if (cleaned.isEmpty || cleaned.length > 120) {
                        cleaned = 'Something went wrong';
                      }
                      return cleaned;
                    }(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    ),
  );
}

class _SubscribeTile extends ConsumerStatefulWidget {
  final int seriesId;
  final bool initialSubscribed;
  final BuildContext callerContext;

  const _SubscribeTile({
    required this.seriesId,
    required this.initialSubscribed,
    required this.callerContext,
  });

  @override
  ConsumerState<_SubscribeTile> createState() => _SubscribeTileState();
}

class _SubscribeTileState extends ConsumerState<_SubscribeTile> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(seriesSubscriptionProvider(widget.seriesId));
    final subscribed =
        subState.asData?.value?.isActive ?? widget.initialSubscribed;

    return ListTile(
      enabled: !_isUpdating,
      leading: _isUpdating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              subscribed
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: subscribed ? Theme.of(context).colorScheme.error : null,
            ),
      title: Text(
        subscribed ? 'Unsubscribe from Series' : 'Subscribe to Series',
        style: subscribed
            ? TextStyle(color: Theme.of(context).colorScheme.error)
            : null,
      ),
      onTap: _isUpdating
          ? null
          : () async {
              setState(() {
                _isUpdating = true;
              });
              final container = ref.container;
              try {
                await toggleSeriesSubscription(
                  context: widget.callerContext,
                  container: container,
                  enabled: !subscribed,
                  seriesId: widget.seriesId,
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isUpdating = false;
                  });
                }
              }
            },
    );
  }
}
