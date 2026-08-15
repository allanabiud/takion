import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class TeamBrowseScreen extends StatelessWidget {
  const TeamBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<TeamList>(
      title: "Browse Teams",
      providerBuilder: (ref, filter) => ref.watch(teamBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(teamBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No teams found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load teams",
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: "team",
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(TeamDetailsRoute(teamId: item.id)),
      ),
    );
  }
}
