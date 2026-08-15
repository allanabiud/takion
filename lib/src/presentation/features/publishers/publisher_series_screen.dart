import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_series_list_provider.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/entity_paged_list_screen.dart";

@RoutePage()
class PublisherSeriesScreen extends ConsumerWidget {
  const PublisherSeriesScreen({
    super.key,
    @pathParam required this.publisherId,
  });

  final int publisherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisherName =
        ref.watch(publisherDetailsProvider(publisherId)).asData?.value.name ??
        "";
    return EntityPagedListScreen<SeriesListPage, SeriesList>(
      title: "Series",
      subtitle: publisherName,
      unit: "series",
      pluralUnit: "series",
      emptyHeight: 360,
      enableRefresh: false,
      sortContext: SortPreferenceContext.publisherSeries,
      sortLabel: contentSortLabel,
      sortItems: sortSeries,
      watchPage: (ref, page) => ref.watch(
        publisherSeriesListPaginatedProvider(
          PublisherSeriesListArgs(publisherId: publisherId, page: page),
        ),
      ),
      invalidatePage: (ref, page) => ref.invalidate(
        publisherSeriesListPaginatedProvider(
          PublisherSeriesListArgs(publisherId: publisherId, page: page),
        ),
      ),
      countOf: (page) => page.count,
      resultsOf: (page) => page.results,
      hasNextOf: (page) => page.hasNext,
      hasPreviousOf: (page) => page.hasPrevious,
      tileBuilder: (context, series, {required isFirst, required isLast}) =>
          SeriesListTile(
            series: series,
            isFirst: isFirst,
            isLast: isLast,
          ),
      emptyMessage: "No series available.",
      emptyIcon: Icons.collections_bookmark_outlined,
      errorMessage: "Failed to load series",
    );
  }
}