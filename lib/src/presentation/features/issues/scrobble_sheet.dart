import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/rating_picker.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

String _issueTitle(IssueDetails? issue, int issueId) {
  if (issue == null) return 'Issue #$issueId';
  final seriesName = issue.series?.name.trim();
  final issueNumber = issue.number.trim();

  if (seriesName != null &&
      seriesName.isNotEmpty &&
      issueNumber.isNotEmpty) {
    return '$seriesName #$issueNumber';
  }
  if (issue.names.isNotEmpty && issue.names.first.trim().isNotEmpty) {
    return issue.names.first.trim();
  }
  return issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
}

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
          iconSize: 32,
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
}) async {
  final issueDetailsAsync = ref.read(issueDetailsProvider(issueId));
  var issueDetails = issueDetailsAsync.asData?.value;
  if (issueDetails == null && !issueDetailsAsync.isLoading) {
    issueDetails = await ref.read(issueDetailsProvider(issueId).future);
  }

  final issueStatus = ref.read(issueCollectionStatusProvider(issueId));
  final pullEntryAsync = ref.read(issuePullListEntryProvider(issueId));
  final isInPullList = pullEntryAsync.asData?.value != null;

  final title = sheetTitle ?? _issueTitle(issueDetails, issueId);

  var addToCollection = issueStatus?.isCollected ?? false;
  var markAsRead = issueStatus?.isRead ?? false;
  var pullIssue = isInPullList;
  var addToWishlist = issueStatus?.isWishlisted ?? false;
  var selectedRating = (issueStatus?.rating ?? 0).clamp(0, 5);
  ref.read(scrobbleIssueProvider(issueId).notifier).reset();

  final hadCollection = issueStatus?.isCollected ?? false;
  final hadRead = issueStatus?.isRead ?? false;
  final hadPull = isInPullList;

  if (!context.mounted) return;

  TakionBottomSheet.show<void>(
    context: context,
    title: title,
    child: Consumer(
      builder: (context, ref, _) {
        final scrobbleState = ref.watch(scrobbleIssueProvider(issueId));
        final isSubmitting = scrobbleState.isLoading;
        final submitError = scrobbleState.whenOrNull(
          error: (error, _) => '$error',
        );

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
                              setModalState(() {
                                addToCollection = !addToCollection;
                                if (addToCollection) {
                                  addToWishlist = false;
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
                              setModalState(() {
                                markAsRead = !markAsRead;
                                if (!markAsRead) {
                                  selectedRating = 0;
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
                          : () {
                              setModalState(() {
                                pullIssue = !pullIssue;
                              });
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
                              setModalState(() {
                                addToWishlist = !addToWishlist;
                                if (addToWishlist) {
                                  addToCollection = false;
                                }
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                RatingPicker(
                  selectedRating: selectedRating,
                  enabled: !isSubmitting,
                  onChanged: (value) {
                    setModalState(() {
                      selectedRating = value;
                      markAsRead = true;
                    });
                  },
                  onReset: () {
                    setModalState(() {
                      selectedRating = 0;
                    });
                  },
                ),
                if (submitError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    submitError,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              await ref
                                  .read(scrobbleIssueProvider(issueId).notifier)
                                  .scrobble(
                                    markAsRead:
                                        markAsRead || selectedRating > 0,
                                    addToCollection: addToCollection,
                                    addToWishlist: addToWishlist,
                                    dateRead: markAsRead
                                        ? DateTime.now().toUtc()
                                        : null,
                                    rating: markAsRead && selectedRating > 0
                                        ? selectedRating
                                        : null,
                                    refreshReadingSuggestion: true,
                                    refreshRateSuggestion: true,
                                  );

                              final latestState = ref.read(
                                scrobbleIssueProvider(issueId),
                              );
                              if (latestState.hasError) return;

                              if (pullIssue != hadPull) {
                                final series = issueDetails?.series;
                                if (!pullIssue) {
                                  await ref
                                      .read(pullListRepositoryProvider)
                                      .deleteEntryByIssueId(issueId);
                                } else {
                                  if (series == null) {
                                    if (context.mounted) {
                                      TakionAlerts
                                          .noLinkedSeriesForIssue(context);
                                    }
                                    return;
                                  }
                                  await ref
                                      .read(pullListRepositoryProvider)
                                      .upsertManualEntry(
                                        metronSeriesId: series.id,
                                        metronIssueId: issueId,
                                        releaseDate:
                                            issueDetails?.storeDate ??
                                            issueDetails?.coverDate,
                                      );
                                }
                              }

                              ref.invalidate(
                                issuePullListEntryProvider(issueId),
                              );
                              ref.invalidate(
                                pullsIssuesForWeekProvider(
                                  ref.read(selectedWeekProvider),
                                ),
                              );
                              ref.invalidate(currentWeekPullsProvider);

                              if (context.mounted) {
                                Navigator.of(context).pop();

                                final addedNow =
                                    !hadCollection && addToCollection;
                                final markedReadNow =
                                    !hadRead && markAsRead;

                                if (addedNow) {
                                  TakionAlerts.libraryAddedToCollection(
                                    context,
                                  );
                                }
                                if (markedReadNow) {
                                  TakionAlerts.libraryMarkedAsRead(context);
                                }
                                if (!addedNow && !markedReadNow) {
                                  TakionAlerts.libraryUpdated(context);
                                }
                                if (pullIssue && !hadPull) {
                                  TakionAlerts.success(
                                    context,
                                    'Added to Pull List',
                                  );
                                } else if (!pullIssue && hadPull) {
                                  TakionAlerts.info(
                                    context,
                                    'Removed from Pull List',
                                  );
                                }
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Status'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
