import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/series/series_list_tile.dart';
import 'package:takion/src/presentation/features/metron_browse/providers/browse_providers.dart';

class _SearchHeader extends StatefulWidget {
  const _SearchHeader({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<_SearchHeader> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    widget.onChanged(value);
                  });
                },
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

Widget _buildSearchHeader({
  required TextEditingController controller,
  required String hintText,
  required VoidCallback onSearchChanged,
}) {
  return _SearchHeader(
    controller: controller,
    hintText: hintText,
    onChanged: (_) => onSearchChanged(),
  );
}

BrowseFilter _browseFilter({required int page, required String? query}) =>
    BrowseFilter(page: page, name: query?.trim().isEmpty == true ? null : query?.trim());

@RoutePage()
class CharacterBrowseScreen extends ConsumerStatefulWidget {
  const CharacterBrowseScreen({super.key});

  @override
  ConsumerState<CharacterBrowseScreen> createState() =>
      _CharacterBrowseScreenState();
}

class _CharacterBrowseScreenState extends ConsumerState<CharacterBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(characterBrowseProvider(filter));
    return BrowsePagedListScreen<CharacterList>(
      title: 'Browse Characters',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(characterBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No characters found.',
      emptyIcon: Icons.person_off,
      errorPrefix: 'Failed to load characters',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => PersonListTile(
        characterId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          CharacterDetailsRoute(characterId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class SeriesBrowseScreen extends ConsumerStatefulWidget {
  const SeriesBrowseScreen({super.key});

  @override
  ConsumerState<SeriesBrowseScreen> createState() =>
      _SeriesBrowseScreenState();
}

class _SeriesBrowseScreenState extends ConsumerState<SeriesBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(seriesBrowseProvider(filter));
    return BrowsePagedListScreen<SeriesList>(
      title: 'Browse Series',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(seriesBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No series found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load series',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => SeriesListTile(
        series: item,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          SeriesDetailsRoute(seriesId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class PublisherBrowseScreen extends ConsumerStatefulWidget {
  const PublisherBrowseScreen({super.key});

  @override
  ConsumerState<PublisherBrowseScreen> createState() =>
      _PublisherBrowseScreenState();
}

class _PublisherBrowseScreenState extends ConsumerState<PublisherBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(publisherBrowseProvider(filter));
    return BrowsePagedListScreen<PublisherList>(
      title: 'Browse Publishers',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(publisherBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No publishers found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load publishers',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'publisher',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        imageWidth: 80,
        imageHeight: 80,
        imageBorderRadius: 10,
        onTap: () => context.pushRoute(
          PublisherDetailsRoute(publisherId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class TeamBrowseScreen extends ConsumerStatefulWidget {
  const TeamBrowseScreen({super.key});

  @override
  ConsumerState<TeamBrowseScreen> createState() =>
      _TeamBrowseScreenState();
}

class _TeamBrowseScreenState extends ConsumerState<TeamBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(teamBrowseProvider(filter));
    return BrowsePagedListScreen<TeamList>(
      title: 'Browse Teams',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(teamBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No teams found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load teams',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'team',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          TeamDetailsRoute(teamId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class ArcBrowseScreen extends ConsumerStatefulWidget {
  const ArcBrowseScreen({super.key});

  @override
  ConsumerState<ArcBrowseScreen> createState() =>
      _ArcBrowseScreenState();
}

class _ArcBrowseScreenState extends ConsumerState<ArcBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(arcBrowseProvider(filter));
    return BrowsePagedListScreen<ArcList>(
      title: 'Browse Story Arcs',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(arcBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No story arcs found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load story arcs',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'arc',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          ArcDetailsRoute(arcId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class UniverseBrowseScreen extends ConsumerStatefulWidget {
  const UniverseBrowseScreen({super.key});

  @override
  ConsumerState<UniverseBrowseScreen> createState() =>
      _UniverseBrowseScreenState();
}

class _UniverseBrowseScreenState extends ConsumerState<UniverseBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(universeBrowseProvider(filter));
    return BrowsePagedListScreen<UniverseList>(
      title: 'Browse Universes',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(universeBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No universes found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load universes',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'universe',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          UniverseDetailsRoute(universeId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class ImprintBrowseScreen extends ConsumerStatefulWidget {
  const ImprintBrowseScreen({super.key});

  @override
  ConsumerState<ImprintBrowseScreen> createState() =>
      _ImprintBrowseScreenState();
}

class _ImprintBrowseScreenState extends ConsumerState<ImprintBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(imprintBrowseProvider(filter));
    return BrowsePagedListScreen<ImprintList>(
      title: 'Browse Imprints',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(imprintBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No imprints found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load imprints',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => EntityListTile(
        entityType: 'imprint',
        entityId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          ImprintDetailsRoute(imprintId: item.id),
        ),
      ),
    );
  }
}

@RoutePage()
class CreatorBrowseScreen extends ConsumerStatefulWidget {
  const CreatorBrowseScreen({super.key});

  @override
  ConsumerState<CreatorBrowseScreen> createState() =>
      _CreatorBrowseScreenState();
}

class _CreatorBrowseScreenState extends ConsumerState<CreatorBrowseScreen> {
  int _page = 1;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = _browseFilter(page: _page, query: _searchQuery);
    final async = ref.watch(creatorBrowseProvider(filter));
    return BrowsePagedListScreen<CreatorList>(
      title: 'Browse Creators',
      pageAsync: async,
      onRefresh: () async {
        ref.invalidate(creatorBrowseProvider(filter));
      },
      onPrevious: () => setState(() => _page--),
      onNext: () => setState(() => _page++),
      emptyMessage: 'No creators found.',
      emptyIcon: Icons.search_off,
      errorPrefix: 'Failed to load creators',
      header: _buildSearchHeader(
        controller: _searchController,
        hintText: 'Filter by name...',
        onSearchChanged: () => setState(() {
          _page = 1;
          _searchQuery = _searchController.text.trim();
          if (_searchQuery!.isEmpty) _searchQuery = null;
        }),
      ),
      itemBuilder: (context, item, index, total) => PersonListTile(
        characterId: item.id,
        name: item.name,
        isFirst: index == 0,
        isLast: index == total - 1,
        onTap: () => context.pushRoute(
          CreatorDetailsRoute(creatorId: item.id),
        ),
      ),
    );
  }
}
