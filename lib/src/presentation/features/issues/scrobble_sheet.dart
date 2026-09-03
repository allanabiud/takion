import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/issues/issue_details/issue_my_details_sheets.dart";
import "package:takion/src/presentation/features/issues/issue_share_util.dart";
import "package:takion/src/presentation/features/issues/series_subscription_toggle.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart";
import "package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart";
import "package:takion/src/presentation/features/issues/providers/scrobble_issue_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/reading_lists/add_to_local_reading_list_bottom_sheet.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

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
  final title = sheetTitle ?? "Issue #$issueId";

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

  // Optimistic edits live outside the Consumer build so they survive rebuilds; provider values are adopted only on committed status changes.
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
                      label: "Collected",
                      color: toggleColor(addToCollection),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setModalState(() {
                                addToCollection = !addToCollection;
                                if (addToCollection) addToWishlist = false;
                              });
                            },
                    ),
                    const SizedBox(width: 32),
                    _ScrobbleActionIcon(
                      icon: markAsRead
                          ? Icons.bookmark_added
                          : Icons.bookmark_added_outlined,
                      label: "Read",
                      color: toggleColor(markAsRead),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setModalState(() {
                                markAsRead = !markAsRead;
                                if (!markAsRead) selectedRating = 0;
                              });
                            },
                    ),
                    const SizedBox(width: 32),
                    _ScrobbleActionIcon(
                      icon: addToWishlist
                          ? Icons.turned_in
                          : Icons.turned_in_not,
                      label: "Wishlist",
                      color: toggleColor(addToWishlist),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setModalState(() {
                                addToWishlist = !addToWishlist;
                                if (addToWishlist) addToCollection = false;
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
                ),
                const SizedBox(height: 12),
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            await ref
                                .read(scrobbleIssueProvider(issueId).notifier)
                                .scrobble(
                                  addToCollection: addToCollection,
                                  markAsRead: markAsRead,
                                  addToWishlist: addToWishlist,
                                  rating: selectedRating,
                                  dateRead: markAsRead
                                      ? DateTime.now().toUtc()
                                      : null,
                                );
                            if (context.mounted &&
                                !ref
                                    .read(scrobbleIssueProvider(issueId))
                                    .hasError) {
                              Navigator.pop(context);
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Save Changes"),
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
                  title: const Text("Add to Reading List"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => AddToLocalReadingListBottomSheet.show(
                    context: callerContext,
                    targetId: "issue-$issueId",
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
                          title: const Text("My Details"),
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
                          title: const Text("Reading History"),
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
                  title: const Text("Share"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isSharing
                      ? null
                      : () async {
                          setModalState(() => isSharing = true);
                          try {
                            AppLogger.info(
                              "Share: fetching issue #$issueId details",
                            );
                            final repo = ref.read(catalogRepositoryProvider);
                            final details = await repo.getIssueDetails(issueId);

                            if (!context.mounted) return;

                            final resourceUrl = details.resourceUrl?.trim();
                            AppLogger.info(
                              "Share: issue #$issueId resourceUrl=$resourceUrl",
                            );

                            if (resourceUrl == null || resourceUrl.isEmpty) {
                              TakionAlerts.noShareUrl(callerContext, "issue");
                              return;
                            }

                            await shareIssueResourceUrl(callerContext, details);
                            AppLogger.info(
                              "Share: completed for issue #$issueId",
                            );
                          } catch (e) {
                            AppLogger.warning(
                              "Share: failed for issue #$issueId",
                              error: e,
                            );
                            if (context.mounted) {
                              TakionAlerts.error(
                                callerContext,
                                "Could not load issue details",
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
                              r"^(Exception|StateError|DioException|PlatformException): ",
                            ),
                            "",
                          )
                          .trim();
                      if (cleaned.isEmpty || cleaned.length > 120) {
                        cleaned = "Something went wrong";
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
        subscribed ? "Unsubscribe from Series" : "Subscribe to Series",
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
