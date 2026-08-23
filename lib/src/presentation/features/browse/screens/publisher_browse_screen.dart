import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/browse/providers/browse_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

@RoutePage()
class PublisherBrowseScreen extends StatelessWidget {
  const PublisherBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<PublisherList>(
      title: "Browse Publishers",
      providerBuilder: (ref, filter) =>
          ref.watch(publisherBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(publisherBrowseProvider(filter).notifier).refresh(),
      emptyMessage: "No publishers found.",
      emptyIcon: Icons.search_off,
      errorPrefix: "Failed to load publishers",
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: "publisher",
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        imageWidth: 80,
        imageHeight: 80,
        imageBorderRadius: 10,
        onTap: () =>
            context.pushRoute(PublisherDetailsRoute(publisherId: item.id)),
      ),
    );
  }
}
