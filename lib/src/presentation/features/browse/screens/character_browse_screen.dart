import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class CharacterBrowseScreen extends StatelessWidget {
  const CharacterBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<CharacterList>(
      title: "Browse Characters",
      providerBuilder: (ref, filter) =>
          ref.watch(characterBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(characterBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No characters found.",
      emptyIcon: Icons.person_off,
      errorPrefix: "Failed to load characters",
      itemBuilder: (context, item, index, total) => PersonListTile(
        characterId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () =>
            context.pushRoute(CharacterDetailsRoute(characterId: item.id)),
      ),
    );
  }
}
