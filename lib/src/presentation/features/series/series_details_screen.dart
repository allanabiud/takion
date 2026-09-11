import "package:auto_route/auto_route.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_completion_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_cover_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/features/series/widgets/series_associated_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_genres_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_info_card.dart";
import "package:takion/src/presentation/features/series/widgets/series_more_options_sheet.dart";
import "package:takion/src/presentation/features/series/widgets/series_progress_cards.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/favorite_toggle_actions.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({
    super.key,
    @pathParam required this.seriesId,
    this.initialImageUrl,
    this.initialFilter,
    this.category,
    this.seriesName,
  });

  final int seriesId;
  final String? initialImageUrl;
  final String? initialFilter;
  final String? category;
  final String? seriesName;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen>
    with
        ResourceUrlActions<SeriesDetails>,
        FavoriteToggleActions,
        DetailRefreshActions<SeriesDetails> {
  late String _selectedFilter;
  final Set<int> _selectedIssueIds = <int>{};
  bool _isBatchProcessing = false;
  bool _isAddingMissingToWishlist = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? widget.category ?? "all";
    if (_selectedFilter == "collected") _selectedFilter = "owned";
  }

  @override
  String? resourceUrlOf(SeriesDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "series";

  @override
  String shareSubjectOf(SeriesDetails details) => details.name;

  @override
  String get entityLabel => "Series";

  @override
  Future<SeriesDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getSeriesDetails(widget.seriesId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(seriesDetailsProvider(widget.seriesId));
    ref.invalidate(seriesFullDetailsProvider(widget.seriesId));
    ref.invalidate(seriesIssueListProvider);
    ref.invalidate(seriesMissingIssuesProvider(widget.seriesId));
  }

  bool _isUpdatingSubscription = false;

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
      if (mounted) {
        (enabled ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          enabled ? "Subscribed" : "Unsubscribed",
          icon: Icons.notifications,
          actionLabel: "Undo",
          onUndo: () async {
            if (enabled) {
              await subscriptionRepository.unsubscribe(widget.seriesId);
              await ref
                  .read(pullListRepositoryProvider)
                  .deleteEntriesBySeriesId(widget.seriesId);
            } else {
              await subscriptionRepository.subscribe(
                metronSeriesId: widget.seriesId,
              );
            }
          },
        );
      }
    } catch (error) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to update subscription");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSubscription = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() {
    return toggleFavoriteWithUndo(
      context,
      isFavorite: ref.read(isSeriesFavoriteProvider(widget.seriesId).future),
      toggle: () async {
        final repository = ref.read(favoritesRepositoryProvider);
        await repository.toggleSeriesFavorite(widget.seriesId);
      },
    );
  }

  void _toggleIssueSelection(int issueId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIssueIds.contains(issueId)) {
        _selectedIssueIds.remove(issueId);
      } else {
        _selectedIssueIds.add(issueId);
      }
    });
  }

  Future<void> _batchMarkRead() async {
    if (_selectedIssueIds.isEmpty || _isBatchProcessing) return;
    setState(() => _isBatchProcessing = true);
    final count = _selectedIssueIds.length;
    final ids = _selectedIssueIds.toList();
    try {
      final libraryRepo = ref.read(libraryRepositoryProvider);
      final now = DateTime.now().toUtc();
      for (final id in ids) {
        await libraryRepo.upsertItem(
          metronIssueId: id,
          metronSeriesId: widget.seriesId,
          ownershipStatus: LibraryOwnershipStatus.owned,
          isRead: true,
          acquiredOn: now,
        );
        await libraryRepo.addReadLog(metronIssueId: id, readAt: now);
      }
      ref.invalidate(collectionStatusCacheProvider);
      ref.invalidate(allCollectionItemsProvider);
      if (mounted) {
        setState(_selectedIssueIds.clear);
        TakionAlerts.success(context, "Marked $count issues as read");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to mark issues as read");
      }
    } finally {
      if (mounted) setState(() => _isBatchProcessing = false);
    }
  }

  Future<void> _batchCollect() async {
    if (_selectedIssueIds.isEmpty || _isBatchProcessing) return;
    setState(() => _isBatchProcessing = true);
    final count = _selectedIssueIds.length;
    final ids = _selectedIssueIds.toList();
    try {
      final libraryRepo = ref.read(libraryRepositoryProvider);
      final now = DateTime.now().toUtc();
      for (final id in ids) {
        await libraryRepo.upsertItem(
          metronIssueId: id,
          metronSeriesId: widget.seriesId,
          ownershipStatus: LibraryOwnershipStatus.owned,
          acquiredOn: now,
        );
      }
      ref.invalidate(collectionStatusCacheProvider);
      ref.invalidate(allCollectionItemsProvider);
      if (mounted) {
        setState(_selectedIssueIds.clear);
        TakionAlerts.success(context, "Added $count issues to collection");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to add issues to collection");
      }
    } finally {
      if (mounted) setState(() => _isBatchProcessing = false);
    }
  }

  Future<void> _batchWishlist() async {
    if (_selectedIssueIds.isEmpty || _isBatchProcessing) return;
    setState(() => _isBatchProcessing = true);
    final count = _selectedIssueIds.length;
    final ids = _selectedIssueIds.toList();
    try {
      final wishlistRepo = ref.read(wishlistRepositoryProvider);
      for (final id in ids) {
        await wishlistRepo.addToWishList(issueId: id);
      }
      ref.invalidate(collectionStatusCacheProvider);
      ref.invalidate(wishlistCollectionItemsProvider);
      if (mounted) {
        setState(_selectedIssueIds.clear);
        TakionAlerts.success(context, "Added $count issues to wishlist");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to add issues to wishlist");
      }
    } finally {
      if (mounted) setState(() => _isBatchProcessing = false);
    }
  }

  Future<void> _addAllMissingToWishlist(List<MissingIssue> missingIssues) async {
    if (missingIssues.isEmpty || _isAddingMissingToWishlist) return;
    setState(() => _isAddingMissingToWishlist = true);
    final count = missingIssues.length;
    try {
      final wishlistRepo = ref.read(wishlistRepositoryProvider);
      for (final issue in missingIssues) {
        await wishlistRepo.addToWishList(
          issueId: issue.id,
          seriesId: issue.seriesId,
          seriesName: issue.seriesName,
          issueNumber: issue.issueNumber,
          imageUrl: issue.imageUrl,
        );
      }
      ref.invalidate(collectionStatusCacheProvider);
      ref.invalidate(wishlistCollectionItemsProvider);
      if (mounted) {
        TakionAlerts.success(
          context,
          "Added $count missing issues to Wishlist",
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, "Failed to add missing issues to wishlist");
      }
    } finally {
      if (mounted) setState(() => _isAddingMissingToWishlist = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(seriesFullDetailsProvider(widget.seriesId));
    final coverImageAsync = ref.watch(
      seriesCoverImageProvider(widget.seriesId),
    );
    final isSubscribed = ref.watch(
      subscribedSeriesIdsSetProvider.select(
        (set) => set.contains(widget.seriesId),
      ),
    );
    final isFavorite =
        ref.watch(isSeriesFavoriteProvider(widget.seriesId)).asData?.value ==
        true;
    final isSubscriptionLoading = _isUpdatingSubscription;

    final ownedCountAsync = ref.watch(seriesOwnedCountProvider(widget.seriesId));
    final readCountAsync = ref.watch(seriesReadCountProvider(widget.seriesId));
    final wishlistCountAsync = ref.watch(
      seriesWishlistCountProvider(widget.seriesId),
    );

    return Scaffold(
      body: DetailScreenShell<SeriesDetails>(
        asyncValue: detailsAsync,
        loadingImageUrl: widget.initialImageUrl,
        entityType: "series",
        initialChildSize: 0.60,
        headerHeight: 350,
        showHero: false,
        toImageUrl: (d) => null,
        toHeroTag: (d) => "series-${d.id}",
        toTitle: (d) => "${d.name.toUpperCase()} (${d.yearBegan ?? ''})",
        toHeaderExtra: (d) {
          final theme = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (d.publisher != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: () => context.pushRoute(
                      PublisherDetailsRoute(publisherId: d.publisher!.id),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d.publisher!.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      style: isSubscribed
                          ? FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                              foregroundColor:
                                  theme.colorScheme.onErrorContainer,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: theme.textTheme.titleMedium,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                          : FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: theme.textTheme.titleMedium,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                      onPressed: isSubscriptionLoading
                          ? null
                          : () => _setSeriesSubscription(!isSubscribed),
                      child: isSubscriptionLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSubscribed
                                      ? Icons.notifications_active
                                      : Icons.notifications_outlined,
                                  size: 26,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    isSubscribed ? "Unsubscribe" : "Subscribe",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: isFavorite
                        ? FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              iconSize: 28,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _toggleFavorite,
                            child: const Icon(Icons.favorite),
                          )
                        : FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              iconSize: 28,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _toggleFavorite,
                            child: const Icon(Icons.favorite_border),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 1,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        iconSize: 28,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => showSeriesMoreOptionsSheet(
                        context,
                        ref,
                        widget.seriesId,
                        seriesName: d.name,
                        seriesYear: d.yearBegan,
                      ),
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
              if (d.issueCount != null && d.issueCount! > 0) ...[
                const SizedBox(height: 12),
                const SectionHeader(title: "PROGRESS"),
                const SizedBox(height: 8),
                SeriesProgressCards(seriesId: d.id, total: d.issueCount!),
              ],
            ],
          );
        },
        onRefresh: (_) => refreshDetails(context),
        onRetry: () => refreshDetails(context),
        onShare: (d) => shareResourceUrl(context, d),
        onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
        headerBackground: (context, d) => [
          coverImageAsync.when(
            data: (imageUrl) => imageUrl != null
                ? Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.image_outlined, size: 40),
                  ),
            loading: () =>
                Container(color: Theme.of(context).colorScheme.surface),
            error: (_, _) => Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Icon(Icons.error_outline),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
        sheetContentBuilder: (context, d, ref) {
          final description = d.description?.trim();
          final showDescription = description != null && description.isNotEmpty;
          final associated = d.associated
              .where((entry) => entry.series.trim().isNotEmpty)
              .toList();
          final showAssociated = associated.isNotEmpty;

          final ownedCount = ownedCountAsync.value ?? 0;
          final readCount = readCountAsync.value ?? 0;
          final unreadCount = (ownedCount - readCount).clamp(0, 99999);
          final wishlistCount = wishlistCountAsync.value ?? 0;

          return [
            if (showDescription) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpandableDescription(description: description),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Filter Chips Bar
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip("all", "All"),
                    const SizedBox(width: 8),
                    _buildFilterChip("owned", "Owned", count: ownedCount),
                    const SizedBox(width: 8),
                    _buildFilterChip("unread", "Unread", count: unreadCount),
                    const SizedBox(width: 8),
                    _buildFilterChip("wishlist", "Wishlist", count: wishlistCount),
                    const SizedBox(width: 8),
                    _buildFilterChip("missing", "Missing Issues"),
                    const SizedBox(width: 8),
                    _buildFilterChip("unrated", "Unrated"),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Issues List based on selected filter
            _buildFilteredIssuesSliver(context, ref, d),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SeriesInfoCard(details: d),
              ),
            ),
            if (showAssociated) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SeriesAssociatedCard(associated: associated),
                ),
              ),
            ],
            if (d.genres.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SeriesGenresCard(genres: d.genres),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: DatabaseIdsSection(
                  metronId: d.id,
                  comicVineId: d.cvId,
                  gcdId: d.gcdId,
                  modifiedAt: d.modified,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ];
        },
      ),
      bottomNavigationBar: _selectedIssueIds.isNotEmpty
          ? _buildMultiSelectBottomBar(context)
          : null,
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {int? count}) {
    final isSelected = _selectedFilter == filterKey;
    final displayLabel = count != null && count > 0 ? "$label ($count)" : label;
    return FilterChip(
      selected: isSelected,
      label: Text(displayLabel),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = filterKey;
          _selectedIssueIds.clear();
        });
      },
    );
  }

  Widget _buildFilteredIssuesSliver(
    BuildContext context,
    WidgetRef ref,
    SeriesDetails series,
  ) {
    if (_selectedFilter == "missing") {
      return _buildMissingIssuesSliver(context, ref, series);
    }

    if (_selectedFilter == "all") {
      return _buildAllIssuesSliver(context, ref, series);
    }

    return _buildLocalFilteredIssuesSliver(context, ref, series, _selectedFilter);
  }

  Widget _buildAllIssuesSliver(
    BuildContext context,
    WidgetRef ref,
    SeriesDetails series,
  ) {
    final issuesPageAsync = ref.watch(
      seriesIssueListProvider(
        SeriesIssueListArgs(seriesId: widget.seriesId, page: 1),
      ),
    );

    return issuesPageAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AsyncStatePanel.error(
            errorMessage: "Failed to load issues",
            onRetry: () => ref.invalidate(seriesIssueListProvider),
          ),
        ),
      ),
      data: (page) {
        final issues = page.results;
        if (issues.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text("No issues found")),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final issue = issues[index];
              final issueId = issue.id ?? 0;
              final isSelected = _selectedIssueIds.contains(issueId);

              return _buildSelectableIssueTile(
                context,
                issue: issue,
                issueId: issueId,
                isSelected: isSelected,
                isFirst: index == 0,
                isLast: index == issues.length - 1,
              );
            },
            childCount: issues.length,
          ),
        );
      },
    );
  }

  Widget _buildLocalFilteredIssuesSliver(
    BuildContext context,
    WidgetRef ref,
    SeriesDetails series,
    String filter,
  ) {
    final allItemsAsync = filter == "wishlist"
        ? ref.watch(wishlistCollectionItemsProvider)
        : ref.watch(allCollectionItemsProvider);

    return allItemsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AsyncStatePanel.error(
            errorMessage: "Failed to load series issues",
            onRetry: () {
              ref.invalidate(allCollectionItemsProvider);
              ref.invalidate(wishlistCollectionItemsProvider);
            },
          ),
        ),
      ),
      data: (allItems) {
        final filteredItems = allItems.where((ci) {
          if (ci.seriesId != widget.seriesId) {
            return false;
          }
          if (filter == "owned") {
            return ci.ownershipStatus == LibraryOwnershipStatus.owned;
          }
          if (filter == "unread") {
            return ci.ownershipStatus == LibraryOwnershipStatus.owned &&
                ci.isRead == false;
          }
          if (filter == "read") {
            return ci.ownershipStatus == LibraryOwnershipStatus.owned &&
                ci.isRead == true;
          }
          if (filter == "wishlist") {
            return ci.ownershipStatus == LibraryOwnershipStatus.wishlist;
          }
          if (filter == "unrated") {
            return ci.ownershipStatus == LibraryOwnershipStatus.owned &&
                (ci.rating == null || ci.rating! <= 0);
          }
          return true;
        }).toList();

        if (filteredItems.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  "No issues in '$filter'",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final ci = filteredItems[index];
              final issue = IssueList(
                id: ci.issueId,
                number: ci.issueNumber,
                name: "${series.name} #${ci.issueNumber}",
                image: ci.imageUrl,
                storeDate: ci.storeDate,
                coverDate: ci.coverDate,
                modified: ci.modified,
                series: Series(
                  id: widget.seriesId,
                  name: series.name,
                  volume: series.volume,
                  yearBegan: series.yearBegan,
                ),
              );
              final issueId = ci.issueId;
              final isSelected = _selectedIssueIds.contains(issueId);

              return _buildSelectableIssueTile(
                context,
                issue: issue,
                issueId: issueId,
                isSelected: isSelected,
                isFirst: index == 0,
                isLast: index == filteredItems.length - 1,
              );
            },
            childCount: filteredItems.length,
          ),
        );
      },
    );
  }

  Widget _buildMissingIssuesSliver(
    BuildContext context,
    WidgetRef ref,
    SeriesDetails series,
  ) {
    final missingAsync = ref.watch(
      seriesMissingIssuesProvider(widget.seriesId),
    );

    return missingAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AsyncStatePanel.error(
            errorMessage: "Failed to load missing issues",
            onRetry: () => ref.invalidate(
              seriesMissingIssuesProvider(widget.seriesId),
            ),
          ),
        ),
      ),
      data: (missingIssues) {
        if (missingIssues.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Run Complete!",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No missing issues found for this series.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.travel_explore,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Missing ${missingIssues.length} issues",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                "Add missing run issues to your wishlist with 1 tap.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: _isAddingMissingToWishlist
                              ? null
                              : () => _addAllMissingToWishlist(missingIssues),
                          child: _isAddingMissingToWishlist
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("Add All"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final missing = missingIssues[index];
                  final issue = IssueList(
                    id: missing.id,
                    number: missing.issueNumber,
                    name: "${missing.seriesName} #${missing.issueNumber}",
                    image: missing.imageUrl,
                    storeDate: missing.storeDate,
                    coverDate: missing.coverDate,
                    modified: null,
                    series: Series(
                      id: missing.seriesId,
                      name: missing.seriesName,
                      volume: series.volume,
                      yearBegan: series.yearBegan,
                    ),
                  );
                  final isSelected = _selectedIssueIds.contains(missing.id);

                  return _buildSelectableIssueTile(
                    context,
                    issue: issue,
                    issueId: missing.id,
                    isSelected: isSelected,
                    isFirst: index == 0,
                    isLast: index == missingIssues.length - 1,
                  );
                },
                childCount: missingIssues.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectableIssueTile(
    BuildContext context, {
    required IssueList issue,
    required int issueId,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
  }) {
    if (_selectedIssueIds.isNotEmpty) {
      return InkWell(
        onTap: () => _toggleIssueSelection(issueId),
        child: Container(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              Expanded(
                child: IgnorePointer(
                  child: IssueListTile(
                    issue: issue,
                    isFirst: isFirst,
                    isLast: isLast,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _toggleIssueSelection(issueId);
      },
      child: IssueListTile(
        issue: issue,
        isFirst: isFirst,
        isLast: isLast,
      ),
    );
  }

  Widget _buildMultiSelectBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final count = _selectedIssueIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(_selectedIssueIds.clear),
              tooltip: "Clear selection",
            ),
            Text(
              "$count selected",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_isBatchProcessing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              FilledButton.tonalIcon(
                onPressed: _batchWishlist,
                icon: const Icon(Icons.bookmark_outline, size: 18),
                label: const Text("Wishlist"),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _batchCollect,
                icon: const Icon(Icons.collections_bookmark_outlined, size: 18),
                label: const Text("Collect"),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _batchMarkRead,
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Read"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

