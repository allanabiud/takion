import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/issues/series_subscription_toggle.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

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
}) async {
  final issueStatus = ref.read(issueCollectionStatusProvider(issueId));
  final pullEntryAsync = ref.read(issuePullListEntryProvider(issueId));
  final isInPullList = pullEntryAsync.asData?.value != null;

  final title = sheetTitle ?? 'Issue #$issueId';

  // Series id is supplied by the caller from the issue-list data (which always
  // includes the series), so the Subscribe tile can render immediately without
  // fetching full issue details.
  final resolvedSeriesId = seriesId;

  var addToCollection = issueStatus?.isCollected ?? false;
  var markAsRead = issueStatus?.isRead ?? false;
  var pullIssue = isInPullList;
  var addToWishlist = issueStatus?.isWishlisted ?? false;
  var selectedRating = (issueStatus?.rating ?? 0).clamp(0, 5);
  ref.read(scrobbleIssueProvider(issueId).notifier).reset();

  if (!context.mounted) return;

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
        final subState = resolvedSeriesId != null
            ? ref.watch(seriesSubscriptionProvider(resolvedSeriesId))
            : null;
        final liveSubscribed = subState?.asData?.value?.isActive ?? false;

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
                                    if (ref.read(scrobbleIssueProvider(issueId)).hasError) {
                                      setModalState(() {
                                        addToCollection = !newValue;
                                        if (newValue) addToWishlist = previousWishlist;
                                      });
                                    } else if (newValue) {
                                      AppLogger.info('Scrobble: added issue #$issueId to collection');
                                      TakionAlerts.libraryAddedToCollection(context);
                                    } else {
                                      AppLogger.info('Scrobble: removed issue #$issueId from collection');
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
                                    dateRead: newValue ? DateTime.now().toUtc() : null,
                                    rating: newValue && selectedRating > 0 ? selectedRating : null,
                                  )
                                  .then((_) {
                                    if (!context.mounted) return;
                                    if (ref.read(scrobbleIssueProvider(issueId)).hasError) {
                                      setModalState(() {
                                        markAsRead = !newValue;
                                        selectedRating = previousRating;
                                      });
                                    } else if (newValue) {
                                      AppLogger.info('Scrobble: marked issue #$issueId as read');
                                      TakionAlerts.libraryMarkedAsRead(context);
                                    } else {
                                      AppLogger.info('Scrobble: unmarked issue #$issueId as read');
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
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final newValue = !pullIssue;
                              final seriesIdLocal = resolvedSeriesId;

                              if (newValue && seriesIdLocal == null) {
                                TakionAlerts.noLinkedSeriesForIssue(context);
                                return;
                              }

                              setModalState(() {
                                pullIssue = newValue;
                              });

                              try {
                                if (!newValue) {
                                  await ref.read(pullListRepositoryProvider).deleteEntryByIssueId(issueId);
                                  AppLogger.info('Scrobble: removed issue #$issueId from pull list');
                                } else {
                                  await ref.read(pullListRepositoryProvider).upsertManualEntry(
                                    metronSeriesId: seriesIdLocal!,
                                    metronIssueId: issueId,
                                    releaseDate: releaseDate,
                                  );
                                  AppLogger.info('Scrobble: added issue #$issueId to pull list');
                                }

                                ref.invalidate(issuePullListEntryProvider(issueId));
                                ref.invalidate(pullsIssuesForWeekProvider(ref.read(selectedWeekProvider)));
                                ref.invalidate(currentWeekPullsProvider);

                                if (context.mounted) {
                                  if (newValue) {
                                    TakionAlerts.success(context, 'Added to Pull List');
                                  } else {
                                    TakionAlerts.info(context, 'Removed from Pull List');
                                  }
                                }
                              } catch (e) {
                                AppLogger.warning('Failed to update pull list', error: e);
                                if (context.mounted) {
                                  setModalState(() {
                                    pullIssue = !newValue;
                                  });
                                  TakionAlerts.error(context, 'Failed to update pull list');
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
                                    if (ref.read(scrobbleIssueProvider(issueId)).hasError) {
                                      setModalState(() {
                                        addToWishlist = !newValue;
                                        if (newValue) addToCollection = previousCollection;
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
                RatingPicker(
                  selectedRating: selectedRating,
                  enabled: !isSubmitting,
                  resetIconEdgeInset: 0,
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
                          if (ref.read(scrobbleIssueProvider(issueId)).hasError) {
                            setModalState(() {
                              selectedRating = previousRating;
                              markAsRead = previousRead;
                            });
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
                        .scrobble(
                          rating: null,
                        )
                        .then((_) {
                          if (!context.mounted) return;
                          if (ref.read(scrobbleIssueProvider(issueId)).hasError) {
                            setModalState(() {
                              selectedRating = previousRating;
                            });
                          }
                        });
                  },
                ),
                const SizedBox(height: 12),
                if (resolvedSeriesId != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  _SubscribeTile(
                    seriesId: resolvedSeriesId,
                    initialSubscribed: liveSubscribed,
                  ),
                ],
                if (submitError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    () {
                      final raw = submitError.toString().trim();
                      var cleaned = raw.replaceFirst(RegExp(
                        r'^(Exception|StateError|DioException|PlatformException): ',
                      ), '').trim();
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

  const _SubscribeTile({
    required this.seriesId,
    required this.initialSubscribed,
  });

  @override
  ConsumerState<_SubscribeTile> createState() => _SubscribeTileState();
}

class _SubscribeTileState extends ConsumerState<_SubscribeTile> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(seriesSubscriptionProvider(widget.seriesId));
    final subscribed = subState.asData?.value?.isActive ?? widget.initialSubscribed;

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
              try {
                await toggleSeriesSubscription(
                  context,
                  ref,
                  !subscribed,
                  widget.seriesId,
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
