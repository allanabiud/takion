import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class ImprintBrowseScreen extends StatelessWidget {
  const ImprintBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<ImprintList>(
      title: "Browse Imprints",
      providerBuilder: (ref, filter) => ref.watch(imprintBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(imprintBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No imprints found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load imprints",
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: "imprint",
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(ImprintDetailsRoute(imprintId: item.id)),
      ),
    );
  }
}
