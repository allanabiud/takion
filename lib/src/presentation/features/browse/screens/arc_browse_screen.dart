import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class ArcBrowseScreen extends StatelessWidget {
  const ArcBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<ArcList>(
      title: "Browse Story Arcs",
      providerBuilder: (ref, filter) => ref.watch(arcBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(arcBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No story arcs found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load story arcs",
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: "arc",
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(ArcDetailsRoute(arcId: item.id)),
      ),
    );
  }
}
