import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/teams/providers/team_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _TeamDetailsScreenState extends ConsumerState<TeamDetailsScreen> {
  Uri? _resourceUri(TeamDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(TeamDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'team');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(TeamDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'team');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'team');
    }
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
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) => _buildTeamSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildTeamSheetSlivers(TeamDetails details, BuildContext context, WidgetRef ref) sync* {
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final hasCreators = details.creators.isNotEmpty;
    final hasUniverses = details.universes.isNotEmpty;

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

    final contentItems = <InfoGridItem>[
      InfoGridItem(label: 'Name', value: details.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DETAILS'),
        const SizedBox(height: 12),
        InfoGrid(items: contentItems),
        const SizedBox(height: 16),
        _buildDatabaseIdsSection(context),
        if (hasModified) ...[
          const SizedBox(height: 8),
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
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

  Widget _buildDatabaseIdsSection(BuildContext context) {
    final entries = <Widget>[];
    void addEntry(String label, String value) {
      entries.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '$label $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    addEntry('Metron', '${details.id}');
    if (details.cvId != null) addEntry('CV', '${details.cvId}');
    if (details.gcdId != null) addEntry('GCD', '${details.gcdId}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DATABASE IDS'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: entries,
        ),
      ],
    );
  }
}
