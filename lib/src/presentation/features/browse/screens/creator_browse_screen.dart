import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class CreatorBrowseScreen extends StatelessWidget {
  const CreatorBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<CreatorList>(
      title: "Browse Creators",
      providerBuilder: (ref, filter) => ref.watch(creatorBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(creatorBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No creators found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load creators",
      itemBuilder: (context, item, index, total) => PersonListTile(
        characterId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(CreatorDetailsRoute(creatorId: item.id)),
      ),
    );
  }
}
