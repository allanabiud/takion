import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/character_details.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/components/horizontal_preview_section.dart';
import 'package:takion/src/presentation/components/person_card.dart';
import 'package:takion/src/presentation/components/universe_card.dart';
import 'package:takion/src/presentation/features/characters/providers/character_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/logic/content_sorting.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/components/detail_screen_skeleton.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';
import 'package:takion/src/presentation/components/entity_detail_actions.dart';

String _monthYear(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}



@RoutePage()
class CharacterDetailsScreen extends ConsumerStatefulWidget {
  const CharacterDetailsScreen({
    super.key,
    @pathParam required this.characterId,
    this.initialImageUrl,
  });

  final int characterId;
  final String? initialImageUrl;

  @override
  ConsumerState<CharacterDetailsScreen> createState() =>
      _CharacterDetailsScreenState();
}

class _CharacterDetailsScreenState
    extends ConsumerState<CharacterDetailsScreen> {
  Uri? _resourceUri(CharacterDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(CharacterDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'character');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(CharacterDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'character');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'character');
    }
  }



  Future<void> _toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isCharacterFavoriteProvider(widget.characterId).future,
      );

      await repository.toggleCharacterFavorite(widget.characterId);

      ref.invalidate(isCharacterFavoriteProvider(widget.characterId));
      ref.invalidate(favoriteCharactersListProvider);

      if (mounted) {
        TakionAlerts.success(
          context,
          !isFavorite
              ? 'Character added to favorites'
              : 'Character removed from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      characterDetailsProvider(widget.characterId),
    );
    final scaffoldBg = Theme.of(context).colorScheme.surface;

    return detailsAsync.when(
      loading: () =>
          DetailScreenSkeleton(
            header: widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: CachedNetworkImage(
                          imageUrl: widget.initialImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    ],
                  )
                : ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest),
          ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Failed to load character details: $error')),
      ),
      data: (details) {
        final isFavoriteAsync = ref.watch(
          isCharacterFavoriteProvider(widget.characterId),
        );
        final isFavorite = isFavoriteAsync.asData?.value ?? false;
        final issueListAsync = ref.watch(
          characterDetailsIssuesProvider(widget.characterId),
        );
        final allIssues = issueListAsync.asData?.value.results ?? [];
        final totalIssueCount = issueListAsync.asData?.value.count ?? 0;
        final isIssuesLoading = issueListAsync.isLoading;

        final previewIssues = allIssues.isNotEmpty
            ? sortIssues(
                allIssues,
                ContentSortOption.dateNewest,
              ).take(5).toList()
            : <IssueList>[];

        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (details.image != null && details.image!.isNotEmpty)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: CachedNetworkImage(
                          imageUrl: details.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ColoredBox(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => ColoredBox(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      )
                    else
                      ColoredBox(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    Container(color: Colors.black.withValues(alpha: 0.55)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scaffoldBg.withValues(alpha: 0.75),
                            Colors.transparent,
                            scaffoldBg.withValues(alpha: 0.75),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (details.image != null &&
                              details.image!.isNotEmpty)
                            Hero(
                              tag: 'character-image-${details.id}',
                              child: GestureDetector(
                                onTap: () => context.pushRoute(
                                  ImagePreviewRoute(
                                    imageUrl: details.image!,
                                    title: details.name,
                                    heroTag: 'character-image-${details.id}',
                                  ),
                                ),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 260,
                                    height: 260,
                                    child: CachedNetworkImage(
                                      imageUrl: details.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          _initialsAvatar(
                                            context,
                                            details.name,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          _initialsAvatar(
                                            context,
                                            details.name,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ClipOval(
                              child: SizedBox(
                                width: 260,
                                height: 260,
                                child: _initialsAvatar(context, details.name),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          EntityDetailActions(
                            onShare: () => _shareResourceUrl(details),
                            onOpenInBrowser: () => _openResourceUrlInBrowser(details),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.60, 0.9],
                builder: (context, scrollController) {
                  return _CharacterDetailsSheet(
                    scrollController: scrollController,
                    details: details,
                    allIssues: allIssues,
                    previewIssues: previewIssues,
                    totalIssueCount: totalIssueCount,
                    isIssuesLoading: isIssuesLoading,
                    isFavorite: isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _initialsAvatar(BuildContext context, String name) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.8),
      child: Center(
        child: Text(
          initials(name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 64,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

TextStyle? _sectionTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.primary,
  );
}

class _CharacterDetailsSheet extends ConsumerWidget {
  const _CharacterDetailsSheet({
    required this.scrollController,
    required this.details,
    required this.allIssues,
    required this.previewIssues,
    required this.totalIssueCount,
    required this.isIssuesLoading,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final ScrollController scrollController;
  final CharacterDetails details;
  final List<IssueList> allIssues;
  final List<IssueList> previewIssues;
  final int totalIssueCount;
  final bool isIssuesLoading;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final alias = details.alias?.trim();
    final hasAlias = alias != null && alias.isNotEmpty;
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final hasIssues = allIssues.isNotEmpty;
    final hasCreators = details.creators.isNotEmpty;
    final hasTeams = details.teams.isNotEmpty;
    final hasUniverses = details.universes.isNotEmpty;

    DateTime? issueDate(IssueList issue) => issue.storeDate ?? issue.coverDate;

    final dates = allIssues
        .map((i) => issueDate(i))
        .where((d) => d != null)
        .toList();
    dates.sort();
    final dateRange = dates.isNotEmpty
        ? '${dates.first!.year} – ${dates.last!.year}'
        : null;

    final distinctSeries = allIssues
        .map((i) => i.series?.name)
        .where((n) => n != null)
        .toSet()
        .length;

    IssueList? firstAppearance;
    if (dates.isNotEmpty) {
      final earliest = dates.first;
      firstAppearance = allIssues.firstWhere(
        (i) => issueDate(i) == earliest,
        orElse: () => allIssues.first,
      );
    }

    final showStats = hasIssues || isIssuesLoading;
    final showFirstAppearance =
        (firstAppearance != null && firstAppearance.id != null) ||
        isIssuesLoading;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: theme.colorScheme.surface,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (hasAlias) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '@$alias',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FavoriteToggleButton(
                          isFavorite: isFavorite,
                          onToggleFavorite: onToggleFavorite,
                          compact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (hasDescription) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CharacterDescriptionCard(description: description),
                ),
              ),
            ],
            if (showStats) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isIssuesLoading
                      ? Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 4,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                          ],
                        )
                      : _CharacterStatsCard(
                          issueCount: totalIssueCount,
                          seriesCount: distinctSeries,
                          dateRange: dateRange,
                        ),
                ),
              ),
            ],
            if (showFirstAppearance) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isIssuesLoading
                      ? const SkeletonBox(borderRadius: 14, height: 90)
                      : _CharacterFirstAppearanceCard(issue: firstAppearance!),
                ),
              ),
            ],
            if (hasCreators) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CharacterCreatorsCard(creators: details.creators),
                ),
              ),
            ],
            if (hasIssues || isIssuesLoading) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isIssuesLoading
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              width: 100,
                              height: 20,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SkeletonBox(
                                    width: 150,
                                    height: 250,
                                    borderRadius: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : HorizontalPreviewSection(
                          title: 'Recently Appeared In',
                          onViewAll: () => context.pushRoute(
                            CharacterIssuesRoute(characterId: details.id),
                          ),
                          itemCount: previewIssues.length,
                          height: 250,
                          emptyText: 'No issues available.',
                          itemBuilder: (context, index) {
                            final issue = previewIssues[index];
                            final issueId = issue.id;
                            return IssueCard(
                              issueId: issueId,
                              imageUrl: issue.image,
                              title:
                                  '${issue.series?.name ?? issue.name} #${issue.number}',
                              onTap: issueId == null
                                  ? null
                                  : () {
                                      context.pushRoute(
                                        IssueDetailsRoute(
                                          issueId: issueId,
                                          initialImageUrl: issue.image,
                                        ),
                                      );
                                    },
                            );
                          },
                        ),
                ),
              ),
            ],
            if (hasTeams) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CharacterListSection(
                    title: 'Teams',
                    items: details.teams,
                  ),
                ),
              ),
            ],
            if (hasUniverses) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Universes', style: _sectionTitleStyle(context)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: details.universes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 4),
                    itemBuilder: (context, index) {
                      final universe = details.universes[index];
                      return UniverseCard(
                        universeId: universe.id,
                        name: universe.name,
                        width: 140,
                      );
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CharacterInfoCard(details: details),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _CharacterDescriptionCard extends StatefulWidget {
  const _CharacterDescriptionCard({required this.description});

  final String description;

  @override
  State<_CharacterDescriptionCard> createState() =>
      _CharacterDescriptionCardState();
}

class _CharacterDescriptionCardState extends State<_CharacterDescriptionCard> {
  static const _descriptionMaxLines = 4;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = Theme.of(context).textTheme.bodyMedium;
        final fullPainter = TextPainter(
          text: TextSpan(text: widget.description, style: textStyle),
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final collapsedPainter = TextPainter(
          text: TextSpan(text: widget.description, style: textStyle),
          maxLines: _descriptionMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = collapsedPainter.didExceedMaxLines;
        final collapsedHeight = isOverflowing
            ? collapsedPainter.height
            : fullPainter.height;
        final heightFactor = fullPainter.height > 0
            ? collapsedHeight / fullPainter.height
            : 1.0;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isOverflowing
              ? () => setState(() => _isExpanded = !_isExpanded)
              : null,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    heightFactor: _isExpanded ? 1.0 : heightFactor,
                    child: Text(widget.description, style: textStyle),
                  ),
                ),
                if (isOverflowing) ...[
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topLeft,
                        child: child,
                      ),
                    ),
                    child: Text(
                      _isExpanded ? 'Tap to read less' : 'Tap to read more',
                      key: ValueKey(_isExpanded),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CharacterCreatorsCard extends StatelessWidget {
  const _CharacterCreatorsCard({required this.creators});

  final List<CharacterDetailsNamedRef> creators;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Creators', style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: creators.length,
            separatorBuilder: (_, _) => const SizedBox(width: 0),
            itemBuilder: (context, index) {
              final creator = creators[index];
              return PersonCard(
                creatorId: creator.id,
                name: creator.name.trim().isNotEmpty
                    ? creator.name.trim()
                    : 'Unknown Creator',
                width: 95,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CharacterListSection extends StatelessWidget {
  const _CharacterListSection({required this.title, required this.items});

  final String title;
  final List<CharacterDetailsNamedRef> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items
              .map(
                (item) => Chip(
                  label: Text(
                    item.name.trim().isNotEmpty ? item.name.trim() : 'Unknown',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CharacterStatsCard extends StatelessWidget {
  const _CharacterStatsCard({
    required this.issueCount,
    required this.seriesCount,
    required this.dateRange,
  });

  final int issueCount;
  final int seriesCount;
  final String? dateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget statCard({required Widget child, int flex = 1}) {
      return Expanded(
        flex: flex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      );
    }

    return Row(
      children: [
        statCard(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$issueCount',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Issues',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        statCard(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$seriesCount',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Series',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (dateRange != null) ...[
          const SizedBox(width: 6),
          statCard(
            flex: 4,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateRange!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Date range',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CharacterFirstAppearanceCard extends StatelessWidget {
  const _CharacterFirstAppearanceCard({required this.issue});

  final IssueList issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seriesName = issue.series?.name.trim();
    final label = seriesName != null && seriesName.isNotEmpty
        ? '$seriesName #${issue.number}'
        : '${issue.name} #${issue.number}';
    final displayDate = issue.storeDate ?? issue.coverDate;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.pushRoute(
        IssueDetailsRoute(issueId: issue.id!, initialImageUrl: issue.image),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 90,
                child: issue.image != null && issue.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: issue.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image, size: 24),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('First Appearance', style: _sectionTitleStyle(context)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (displayDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _monthYear(displayDate),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterInfoCard extends StatelessWidget {
  const _CharacterInfoCard({required this.details});

  final CharacterDetails details;

  String? _modifiedValue() {
    final modified = details.modified;
    if (modified == null) return null;
    final year = modified.year.toString().padLeft(4, '0');
    final month = modified.month.toString().padLeft(2, '0');
    final day = modified.day.toString().padLeft(2, '0');
    final hour = modified.hour.toString().padLeft(2, '0');
    final minute = modified.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final infoItems = <({String label, String value})>[
      (label: 'Metron ID', value: '${details.id}'),
      if (details.cvId != null) (label: 'CV ID', value: '${details.cvId}'),
      if (details.gcdId != null) (label: 'GCD ID', value: '${details.gcdId}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information', style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        if (infoItems.isNotEmpty)
          ...infoItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      item.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.value, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        if (hasModified) ...[
          const SizedBox(height: 12),
          Text(
            'Last modified: $modifiedValue',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
