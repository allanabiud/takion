import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/browse/providers/browse_providers.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

@RoutePage()
class CharacterBrowseScreen extends StatelessWidget {
  const CharacterBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<CharacterList>(
      title: 'Browse Characters',
      providerBuilder: (ref, filter) => ref.watch(characterBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(characterBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No characters found.',
      emptyIcon: Icons.person_off,
      errorPrefix: 'Failed to load characters',
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

@RoutePage()
class SeriesBrowseScreen extends StatelessWidget {
  const SeriesBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<SeriesList>(
      title: 'Browse Series',
      providerBuilder: (ref, filter) => ref.watch(seriesBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(seriesBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No series found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load series',
      itemBuilder: (context, item, index, total) => SeriesListTile(
        series: item,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(SeriesDetailsRoute(seriesId: item.id)),
      ),
    );
  }
}

@RoutePage()
class PublisherBrowseScreen extends StatelessWidget {
  const PublisherBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<PublisherList>(
      title: 'Browse Publishers',
      providerBuilder: (ref, filter) => ref.watch(publisherBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(publisherBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No publishers found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load publishers',
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'publisher',
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

@RoutePage()
class TeamBrowseScreen extends StatelessWidget {
  const TeamBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<TeamList>(
      title: 'Browse Teams',
      providerBuilder: (ref, filter) => ref.watch(teamBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(teamBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No teams found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load teams',
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'team',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(TeamDetailsRoute(teamId: item.id)),
      ),
    );
  }
}

@RoutePage()
class ArcBrowseScreen extends StatelessWidget {
  const ArcBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<ArcList>(
      title: 'Browse Story Arcs',
      providerBuilder: (ref, filter) => ref.watch(arcBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(arcBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No story arcs found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load story arcs',
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'arc',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(ArcDetailsRoute(arcId: item.id)),
      ),
    );
  }
}

@RoutePage()
class UniverseBrowseScreen extends StatelessWidget {
  const UniverseBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<UniverseList>(
      title: 'Browse Universes',
      providerBuilder: (ref, filter) => ref.watch(universeBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(universeBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No universes found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load universes',
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'universe',
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

@RoutePage()
class ImprintBrowseScreen extends StatelessWidget {
  const ImprintBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<ImprintList>(
      title: 'Browse Imprints',
      providerBuilder: (ref, filter) => ref.watch(imprintBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(imprintBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No imprints found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load imprints',
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'imprint',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(ImprintDetailsRoute(imprintId: item.id)),
      ),
    );
  }
}

@RoutePage()
class CreatorBrowseScreen extends StatelessWidget {
  const CreatorBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericBrowseScreen<CreatorList>(
      title: 'Browse Creators',
      providerBuilder: (ref, filter) => ref.watch(creatorBrowseProvider(filter)),
      refreshNotifierGetter: (ref, filter) =>
          ref.read(creatorBrowseProvider(filter).notifier).refresh(),
      emptyMessage: 'No creators found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load creators',
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
