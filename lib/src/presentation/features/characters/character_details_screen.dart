import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/characters/providers/character_details_provider.dart';
import 'package:takion/src/presentation/features/characters/widgets/powerstats_radar_card.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';

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

      if (mounted) {
        final added = !isFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await repository.toggleCharacterFavorite(widget.characterId);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favourites');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      characterDetailsProvider(widget.characterId),
    );
    final superheroAsync = ref.watch(
      superheroCharacterProvider(widget.characterId),
    );
    final usePowerstats =
        ref.watch(superheroUsePowerstatsProvider).value ?? false;
    final superhero = superheroAsync.asData?.value;
    final isSuperHeroLoading = superheroAsync.isLoading;
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
        ? sortIssues(allIssues, ContentSortOption.dateNewest).take(5).toList()
        : <IssueList>[];

    return DetailScreenShell<CharacterDetails>(
      asyncValue: detailsAsync,
      loadingImageUrl: widget.initialImageUrl,
      entityType: 'character',
      initialChildSize: 0.60,
      headerHeight: 350,
      toImageUrl: (d) => d.image,
      toFallbackImageUrl: (d) => null,
      toHeroTag: (d) => 'character-image-${d.id}',
      toTitle: (d) => d.name,
      toSubtitle: (d) => d.alias,
      onRefresh: (d) async {
        try {
          final newDetails = await ref
              .read(catalogRepositoryProvider)
              .getCharacterDetails(d.id, forceRefresh: true);
          final currentDetails = ref
              .read(characterDetailsProvider(d.id))
              .asData
              ?.value;
          if (currentDetails != newDetails) {
            ref.invalidate(characterDetailsProvider(d.id));
          }
          if (context.mounted) {
            TakionAlerts.success(context, 'Character details refreshed');
          }
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.error(context, 'Failed to refresh character details');
          }
        }
      },
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      circular: true,
      heroWidth: 260,
      heroHeight: 260,
      toTrailingHeaderAction: (d) => FavoriteToggleButton(
        isFavorite: isFavorite,
        onToggleFavorite: _toggleFavorite,
        compact: true,
      ),
      sheetContentBuilder: (context, data, ref) {
        final description = data.desc?.trim();
        final hasDescription = description != null && description.isNotEmpty;
        final hasIssues = allIssues.isNotEmpty;
        final hasCreators = data.creators.isNotEmpty;
        final hasTeams = data.teams.isNotEmpty;
        final hasUniverses = data.universes.isNotEmpty;

        DateTime? issueDate(IssueList issue) =>
            issue.storeDate ?? issue.coverDate;

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

        return [
          if (hasDescription) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpandableDescription(description: description),
              ),
            ),
          ],
          if (showStats) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isIssuesLoading
                    ? const ShimmerWidget(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              flex: 4,
                              child: SkeletonBox(borderRadius: 12, height: 70),
                            ),
                          ],
                        ),
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
                    ? const ShimmerWidget(
                        child: SkeletonBox(borderRadius: 14, height: 90),
                      )
                    : _CharacterFirstAppearanceCard(issue: firstAppearance!),
              ),
            ),
          ],
          if (hasCreators) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CharacterCreatorsCard(creators: data.creators),
              ),
            ),
          ],
          if (usePowerstats &&
              (isSuperHeroLoading || superhero?.powerstats != null)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isSuperHeroLoading
                    ? const ShimmerWidget(
                        child: SkeletonBox(borderRadius: 16, height: 340),
                      )
                    : PowerStatsRadarCard(powerstats: superhero!.powerstats!),
              ),
            ),
          ],
          if (hasIssues || isIssuesLoading) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isIssuesLoading
                    ? ShimmerWidget(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonBox(
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
                                itemBuilder: (context, index) => const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: IssueCardSkeleton(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Recently Appeared In',
                            onViewAll: () => context.pushRoute(
                              CharacterIssuesRoute(characterId: data.id),
                            ),
                          ),
                          const SizedBox(height: 12),
                          HorizontalPreviewSection(
                            title: '',
                            onViewAll: null,
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
                                seriesId: issue.series?.id,
                                seriesName: issue.series?.name,
                                issueNumber: issue.number,
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
                        ],
                      ),
              ),
            ),
          ],
          if (hasTeams) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const SectionHeader(title: 'TEAMS'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: data.teams.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final team = data.teams[index];
                    return EntityCard(
                      entityType: 'team',
                      entityId: team.id,
                      name: team.name,
                      width: 110,
                      onTap: () =>
                          context.pushRoute(TeamDetailsRoute(teamId: team.id)),
                    );
                  },
                ),
              ),
            ),
          ],
          if (hasUniverses) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const SectionHeader(title: 'UNIVERSES'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: data.universes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final universe = data.universes[index];
                    return EntityCard(
                      entityType: 'universe',
                      entityId: universe.id,
                      name: universe.name,
                      width: 140,
                      imageHeight: 80,
                      onTap: () => context.pushRoute(
                        UniverseDetailsRoute(universeId: universe.id),
                      ),
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
              child: _CharacterInfoCard(details: data),
            ),
          ),
        ];
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
        const SectionHeader(title: 'CREATORS'),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
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
                child: EntityCover(
                  imageUrl: issue.image,
                  width: 60,
                  height: 90,
                  borderRadius: 0,
                  aspectRatio: 60 / 90,
                  iconSize: 24,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FIRST APPEARANCE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
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
    return DateFormatter.isoDateTime(modified);
  }

  @override
  Widget build(BuildContext context) {
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatabaseIdsSection(
          metronId: details.id,
          comicVineId: details.cvId,
          gcdId: details.gcdId,
        ),
        if (hasModified) ...[
          const SizedBox(height: 8),
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
