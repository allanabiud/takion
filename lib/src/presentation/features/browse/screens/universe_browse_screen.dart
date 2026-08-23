import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class UniverseBrowseScreen extends StatelessWidget {
  const UniverseBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<UniverseList>(
      title: "Browse Universes",
      providerBuilder: (ref, filter) =>
          ref.watch(universeBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(universeBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No universes found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load universes",
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: "universe",
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () =>
            context.pushRoute(UniverseDetailsRoute(universeId: item.id)),
      ),
    );
  }
}
