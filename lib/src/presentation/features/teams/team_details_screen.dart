import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/teams/providers/team_details_provider.dart';
import 'package:takion/src/presentation/features/teams/providers/team_issue_list_provider.dart';
import 'package:takion/src/presentation/shared/resource_url_actions.dart';
import 'package:takion/src/presentation/shared/detail_refresh_actions.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:takion/src/domain/common/content_sorting.dart';
import 'package:takion/src/presentation/providers/providers.dart';

@RoutePage()
class TeamDetailsScreen extends ConsumerStatefulWidget {
  const TeamDetailsScreen({
    super.key,
    @pathParam required this.teamId,
    this.initialImageUrl,
  });

  final int teamId;
  final String? initialImageUrl;

  @override
  ConsumerState<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState
    extends ConsumerState<TeamDetailsScreen>
    with ResourceUrlActions<TeamDetails>, DetailRefreshActions<TeamDetails> {
  @override
  String? resourceUrlOf(TeamDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => 'team';

  @override
  String shareSubjectOf(TeamDetails details) => details.name;

  @override
  String get entityLabel => 'Team';

  @override
  Future<TeamDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getTeamDetails(widget.teamId, forceRefresh: true);
  }

  @override
  TeamDetails? currentStoredDetails() {
    return ref.read(teamDetailsProvider(widget.teamId)).asData?.value;
  }

  @override
  void invalidateDetails() {
    ref.invalidate(teamDetailsProvider(widget.teamId));
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(teamDetailsProvider(widget.teamId));

    return DetailScreenShell<TeamDetails>(
      asyncValue: detailsAsync,
      entityType: 'team',
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'team-image-${d.id}',
      toTitle: (d) => d.name,
      onRefresh: (_) => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) =>
          _buildTeamSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildTeamSheetSlivers(
    TeamDetails details,
    BuildContext context,
    WidgetRef ref,
  ) sync* {
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final hasCreators = details.creators.isNotEmpty;
    final hasUniverses = details.universes.isNotEmpty;

    final issuesPreviewAsync = ref.watch(
      teamDetailsIssuesProvider(widget.teamId),
    );
    final isIssuesLoading = issuesPreviewAsync.isLoading;
    final issuesPreview = issuesPreviewAsync.asData != null
        ? sortIssues(
            issuesPreviewAsync.asData!.value.results,
            ContentSortOption.dateNewest,
          ).take(10).toList()
        : <IssueList>[];
    final totalIssueCount = issuesPreviewAsync.asData?.value.count ?? 0;

    if (hasDescription) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpandableDescription(description: description),
        ),
      );
    }
    if (hasCreators) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(title: 'CREATORS'),
        ),
      );
      yield const SliverToBoxAdapter(child: SizedBox(height: 12));
      yield SliverToBoxAdapter(
        child: SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: details.creators.length,
            separatorBuilder: (_, _) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final creator = details.creators[index];
              return PersonCard(
                creatorId: creator.id,
                name: creator.name,
                width: 100,
              );
            },
          ),
        ),
      );
    }
    if (hasUniverses) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(title: 'UNIVERSES'),
        ),
      );
      yield const SliverToBoxAdapter(child: SizedBox(height: 12));
      yield SliverToBoxAdapter(
        child: SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: details.universes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final universe = details.universes[index];
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
      );
    }
    const SliverToBoxAdapter(child: SizedBox(height: 16));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: isIssuesLoading
                  ? 'Issues'
                  : '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
              onViewAll: isIssuesLoading
                  ? null
                  : () => context.pushRoute(
                      TeamIssuesRoute(teamId: widget.teamId),
                    ),
            ),
            const SizedBox(height: 12),
            if (isIssuesLoading)
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, _) =>
                      const ShimmerWidget(child: IssueCardSkeleton()),
                ),
              )
            else
              HorizontalPreviewSection(
                title: '',
                onViewAll: null,
                itemCount: issuesPreview.length,
                height: 250,
                emptyText: 'No issues available.',
                itemBuilder: (context, index) {
                  final issue = issuesPreview[index];
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
    );
    yield const SliverToBoxAdapter(child: SizedBox(height: 16));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _TeamInfoSection(details: details),
      ),
    );
  }
}

class _TeamInfoSection extends StatelessWidget {
  const _TeamInfoSection({required this.details});

  final TeamDetails details;

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

  String? _modifiedValue() {
    final modified = details.modified;
    if (modified == null) return null;
    return DateFormatter.isoDateTime(modified);
  }
}
