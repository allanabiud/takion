import "package:auto_route/auto_route.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/features/library/providers/category_series_providers.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_cover_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/series_issue_bulk_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/providers/providers.dart";

@RoutePage()
class LibrarySeriesScreen extends ConsumerWidget {
  const LibrarySeriesScreen({
    super.key,
    @pathParam required this.seriesId,
    this.category = "collected",
    this.seriesName,
  });

  final int seriesId;
  final String category;
  final String? seriesName;

  String get _categoryLabel {
    switch (category) {
      case "collected":
        return "Collected";
      case "read":
        return "Read";
      case "wishlist":
        return "Wishlisted";
      case "unread":
        return "Unread";
      case "unrated":
        return "Unrated";
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(seriesDetailsProvider(seriesId));
    final categorySeriesAsync = ref.watch(seriesByCategoryProvider(category));
    final coverImageAsync = ref.watch(seriesCoverImageProvider(seriesId));

    return DetailScreenShell<SeriesDetails>(
      asyncValue: detailsAsync,
      entityType: "series",
      initialChildSize: 0.60,
      headerHeight: 350,
      showHero: false,
      toImageUrl: (d) => null,
      toHeroTag: (d) => "library-series-${d.id}",
      toTitle: (d) => '${d.name.toUpperCase()} (${d.yearBegan ?? ''})',
      appBarTrailingAction: (d) => IconButton(
        icon: const Icon(Icons.open_in_new),
        tooltip: "View full series details",
        onPressed: () =>
            context.pushRoute(SeriesDetailsRoute(seriesId: seriesId)),
      ),
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
            if (d.issueCount != null && d.issueCount! > 0)
              _CombinedCategoryHeader(
                category: category,
                categoryLabel: _categoryLabel,
                seriesId: seriesId,
                total: d.issueCount!,
              ),
          ],
        );
      },
      headerBackground: (context, d) => [
        coverImageAsync.when(
          data: (imageUrl) => imageUrl != null
              ? Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Theme.of(context).colorScheme.surface),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                )
              : Container(color: Theme.of(context).colorScheme.surface),
          loading: () =>
              Container(color: Theme.of(context).colorScheme.surface),
          error: (_, _) =>
              Container(color: Theme.of(context).colorScheme.surface),
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
        return [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CategoryIssueList(
                seriesId: seriesId,
                category: category,
                categoryLabel: _categoryLabel,
                categorySeriesAsync: categorySeriesAsync,
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _CombinedCategoryHeader extends ConsumerWidget {
  const _CombinedCategoryHeader({
    required this.category,
    required this.categoryLabel,
    required this.seriesId,
    required this.total,
  });

  final String category;
  final String categoryLabel;
  final int seriesId;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySeriesAsync = ref.watch(seriesByCategoryProvider(category));
    final theme = Theme.of(context);

    return categorySeriesAsync.when(
      loading: () => const Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: ShimmerWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 12, borderRadius: 4),
                    SizedBox(height: 10),
                    SkeletonBox(height: 8, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      error: (_, _) => const SizedBox(height: 24),
      data: (seriesList) {
        final match = seriesList
            .where((s) => s.seriesId == seriesId)
            .firstOrNull;
        if (match == null || match.categoryCount == 0) {
          return const SizedBox.shrink();
        }

        final count = match.categoryCount;
        final percent = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${categoryLabel.toUpperCase()}: $count / $total",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
              if (category == "unread" || category == "unrated") ...[
                const SizedBox(width: 8),
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
                    onPressed: () async {
                      final allItems = await ref.read(
                        allCollectionItemsProvider.future,
                      );
                      final categoryIssues = allItems.where((ci) {
                        if (ci.issue?.series?.id != seriesId) return false;
                        if (category == "unread") return ci.isRead == false;
                        if (category == "unrated") return ci.rating == null;
                        if (category == "collected") return ci.quantity > 0;
                        if (category == "read") return ci.isRead == true;
                        if (category == "wishlist") return ci.quantity == 0;
                        return true;
                      }).toList();

                      if (!context.mounted) return;

                      _showCategoryBulkSheet(
                        context,
                        ref,
                        seriesId: seriesId,
                        seriesName: match.seriesName,
                        seriesYear: match.yearBegan,
                        categoryIssues: categoryIssues,
                        category: category,
                      );
                    },
                    child: Icon(
                      category == "unread"
                          ? Icons.bookmark_added
                          : Icons.star_outline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showCategoryBulkSheet(
  BuildContext context,
  WidgetRef ref, {
  required int seriesId,
  required String seriesName,
  int? seriesYear,
  required List<CollectionItem> categoryIssues,
  required String category,
}) async {
  final candidates = categoryIssues.asMap().entries.map((entry) {
    return SeriesIssueBulkCandidate(
      issueId: entry.value.issue?.id ?? 0,
      orderIndex: entry.key + 1,
      issueNumber: entry.value.issue?.number ?? "",
      imageUrl: entry.value.issue?.image,
      storeDate: entry.value.issue?.storeDate,
    );
  }).toList();

  final canSelectRange = candidates.length > 1;
  var selectedMode = SeriesIssueSelectionMode.predefined;
  var rangeStart = 1;
  var rangeEnd = candidates.length;
  var selectedRating = 0;
  var isApplying = false;

  TakionBottomSheet.show<void>(
    context: context,
    title: seriesYear != null ? "$seriesName ($seriesYear)" : seriesName,
    child: StatefulBuilder(
      builder: (context, setModalState) {
        final theme = Theme.of(context);
        final selectedStart = rangeStart;
        final selectedEnd = rangeEnd;
        final selectedCount =
            selectedMode == SeriesIssueSelectionMode.range
            ? rangeEnd - rangeStart + 1
            : candidates.length;
        final startIssueNumber = candidates[selectedStart - 1].issueNumber;
        final endIssueNumber = candidates[selectedEnd - 1].issueNumber;

        String previewAction() {
          return category == "unrated" ? "Rate Issues" : "Mark as Read";
        }

        String buttonLabel() {
          if (category == "unrated") return "Rate";
          return "Mark as Read";
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Action", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (category == "unrated")
                RatingPicker(
                  selectedRating: selectedRating,
                  enabled: !isApplying,
                  onChanged: (rating) {
                    setModalState(() => selectedRating = rating);
                  },
                  onReset: () {
                    setModalState(() => selectedRating = 0);
                  },
                )
              else
                Row(
                  children: [
                     Icon(
                       Icons.bookmark_added,
                       size: 20,
                       color: theme.colorScheme.primary,
                     ),
                    const SizedBox(width: 8),
                    Text(
                      "Mark as Read",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text("Selection method", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SeriesIssueSelectionMode>(
                  segments: const [
                    ButtonSegment(
                      value: SeriesIssueSelectionMode.predefined,
                      label: Text("All"),
                    ),
                    ButtonSegment(
                      value: SeriesIssueSelectionMode.range,
                      label: Text("Issue range"),
                    ),
                  ],
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
                            if (value == SeriesIssueSelectionMode.predefined) {
                              rangeStart = 1;
                              rangeEnd = candidates.length;
                            }
                          });
                        },
                ),
              ),
              const SizedBox(height: 12),
              if (selectedMode == SeriesIssueSelectionMode.range)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Issue range", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          "#$startIssueNumber – #$endIssueNumber",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                                candidates,
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
                                candidates,
                                v,
                                startAfter: rangeStart - 1,
                              );
                              if (idx != null &&
                                  idx + 1 <= candidates.length) {
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
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewAction(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$selectedCount ${selectedCount == 1 ? 'Issue' : 'Issues'}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
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
                  if (category == "unrated") ...[
                    FilledButton(
                      onPressed:
                          isApplying ||
                              selectedCount == 0 ||
                              selectedRating == 0
                          ? null
                          : () async {
                              setModalState(() => isApplying = true);
                              try {
                                final libraryRepository = ref.read(
                                  libraryRepositoryProvider,
                                );
                                var affected = 0;
                                final now = DateTime.now().toUtc();

                                final issuesToRate =
                                    selectedMode ==
                                            SeriesIssueSelectionMode.range &&
                                        canSelectRange
                                    ? candidates
                                          .where(
                                            (c) =>
                                                c.orderIndex >= selectedStart &&
                                                c.orderIndex <= selectedEnd,
                                          )
                                          .toList()
                                    : candidates;

                                for (final candidate in issuesToRate) {
                                  final issueId = candidate.issueId;
                                  if (issueId <= 0) continue;

                                  final item = categoryIssues.firstWhere(
                                    (ci) => ci.issue?.id == issueId,
                                    orElse: () => categoryIssues.first,
                                  );

                                  if (item.rating == selectedRating) continue;

                                  final localItem = await libraryRepository
                                      .getItemByIssueId(issueId);
                                  final itemSeriesId =
                                      localItem?.metronSeriesId ??
                                      item.issue?.series?.id;
                                  if (itemSeriesId == null) continue;

                                  await libraryRepository.upsertItem(
                                    metronIssueId: issueId,
                                    metronSeriesId: itemSeriesId,
                                    ownershipStatus:
                                        localItem?.ownershipStatus ??
                                        LibraryOwnershipStatus.notOwned,
                                    isRead: localItem?.isRead ?? item.isRead,
                                    rating: selectedRating,
                                    purchaseDate: localItem?.purchaseDate,
                                    pricePaid: localItem?.pricePaid,
                                    quantityOwned:
                                        localItem?.quantityOwned ?? 1,
                                    format:
                                        localItem?.format ??
                                        LibraryItemFormat.print,
                                    firstReadAt: localItem?.firstReadAt,
                                    conditionGrade: localItem?.conditionGrade,
                                    acquiredOn: localItem?.acquiredOn ?? now,
                                    notes: localItem?.notes,
                                  );
                                  affected++;
                                }

                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                TakionAlerts.success(
                                  context,
                                  "$affected Issues Rated",
                                );
                                ref.invalidate(
                                  seriesByCategoryProvider(category),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  setModalState(() => isApplying = false);
                                }
                              }
                            },
                      child: isApplying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(buttonLabel()),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: isApplying || selectedCount == 0
                          ? null
                          : () async {
                              setModalState(() => isApplying = true);
                              try {
                                await applySeriesIssueBulkAction(
                                  context: context,
                                  ref: ref,
                                  seriesId: seriesId,
                                  seriesName: seriesName,
                                  operation:
                                      SeriesIssueBulkOperation.markAsRead,
                                  selectionMode:
                                      selectedMode ==
                                              SeriesIssueSelectionMode.range &&
                                          canSelectRange
                                      ? SeriesIssueSelectionMode.range
                                      : SeriesIssueSelectionMode.predefined,
                                  issues: candidates,
                                  subset:
                                      !(selectedMode ==
                                              SeriesIssueSelectionMode.range &&
                                          canSelectRange)
                                      ? SeriesIssueSubset.all
                                      : null,
                                  startOrderIndex:
                                      selectedMode ==
                                              SeriesIssueSelectionMode.range &&
                                          canSelectRange
                                      ? selectedStart
                                      : null,
                                  endOrderIndex:
                                      selectedMode ==
                                              SeriesIssueSelectionMode.range &&
                                          canSelectRange
                                      ? selectedEnd
                                      : null,
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setModalState(() => isApplying = false);
                                }
                              }
                            },
                      child: isApplying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(buttonLabel()),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _CategoryIssueList extends ConsumerWidget {
  const _CategoryIssueList({
    required this.seriesId,
    required this.category,
    required this.categoryLabel,
    required this.categorySeriesAsync,
  });

  final int seriesId;
  final String category;
  final String categoryLabel;
  final AsyncValue<List<CategorySeriesSummary>> categorySeriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItemsAsync = ref.watch(allCollectionItemsProvider);

    return allItemsAsync.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: "ISSUES"),
          SizedBox(height: 8),
          ShimmerWidget(
            child: Column(
              children: [
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
                _IssueTileSkeleton(),
              ],
            ),
          ),
        ],
      ),
      error: (error, _) => const Text("Failed to load issues"),
      data: (allItems) {
        final categoryItems = allItems.where((ci) {
          if (ci.issue?.series?.id != seriesId) return false;
          if (category == "unread") return ci.isRead == false;
          if (category == "unrated") return ci.rating == null;
          if (category == "collected") return ci.quantity > 0;
          if (category == "read") return ci.isRead == true;
          if (category == "wishlist") return ci.quantity == 0;
          return true;
        }).toList();

        if (categoryItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Center(
              child: Text(
                "No $categoryLabel issues in this series.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: "ISSUES", badge: "(${categoryItems.length})"),
            const SizedBox(height: 8),
            ...categoryItems.map((item) {
              final index = categoryItems.indexOf(item);
              return IssueListTile(
                issue: item.toIssueList(),
                isFirst: index == 0,
                isLast: index == categoryItems.length - 1,
                isCollected: item.quantity > 0,
                isRead: item.isRead,
                rating: item.rating,
                horizontalPadding: 4,
              );
            }),
          ],
        );
      },
    );
  }
}

extension _CollectionItemToIssueList on CollectionItem {
  IssueList toIssueList() {
    return IssueList(
      id: issue?.id ?? 0,
      name: issue?.series?.name ?? issue?.number ?? "",
      number: issue?.number ?? "",
      image: issue?.image,
      coverDate: issue?.coverDate,
      storeDate: issue?.storeDate,
      series: issue?.series != null
          ? Series(
              id: issue!.series!.id ?? 0,
              name: issue!.series!.name,
              volume: issue!.series!.volume,
              yearBegan: issue!.series!.yearBegan,
            )
          : null,
      modified: null,
    );
  }
}

class _IssueTileSkeleton extends StatelessWidget {
  const _IssueTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SkeletonBox(width: 72, height: 98, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(width: 60, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
