import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class SeriesBrowseScreen extends StatelessWidget {
  const SeriesBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<SeriesList>(
      title: "Browse Series",
      providerBuilder: (ref, filter) => ref.watch(seriesBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(seriesBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No series found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load series",
      itemBuilder: (context, item, index, total) => SeriesListTile(
        series: item,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(SeriesDetailsRoute(seriesId: item.id)),
      ),
    );
  }
}
