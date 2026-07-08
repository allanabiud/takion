import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/arc_details.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_details_provider.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_issue_list_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/detail_screen_shell.dart';
import 'package:takion/src/presentation/components/expandable_description.dart';
import 'package:takion/src/presentation/components/horizontal_preview_section.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/components/section_header.dart';

@RoutePage()
class ArcDetailsScreen extends ConsumerStatefulWidget {
  const ArcDetailsScreen({
    super.key,
    @pathParam required this.arcId,
    this.initialImageUrl,
  });

  final int arcId;
  final String? initialImageUrl;

  @override
  ConsumerState<ArcDetailsScreen> createState() => _ArcDetailsScreenState();
}

class _ArcDetailsScreenState extends ConsumerState<ArcDetailsScreen> {
  Uri? _resourceUri(ArcDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(ArcDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'arc');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(ArcDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'arc');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'arc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(arcDetailsProvider(widget.arcId));

    return DetailScreenShell<ArcDetails>(
      asyncValue: detailsAsync,
      entityType: 'arc',
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'arc-image-${d.id}',
      toTitle: (d) => d.name,
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) => _buildArcSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildArcSheetSlivers(ArcDetails details, BuildContext context, WidgetRef ref) sync* {
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    if (hasDescription) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpandableDescription(description: description),
        ),
      );
    }
    yield SliverToBoxAdapter(
      child: _ArcIssuesSection(arcId: details.id),
    );
    yield const SliverToBoxAdapter(child: SizedBox(height: 16));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _ArcDatabaseIdsSection(details: details),
      ),
    );
    if (details.modified != null) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ArcModifiedSection(modified: details.modified!),
        ),
      );
    }
  }
}

class _ArcIssuesSection extends ConsumerWidget {
  const _ArcIssuesSection({required this.arcId});

  final int arcId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(arcDetailsIssuesProvider(arcId));
    return issuesAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Issues'),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SkeletonBox(width: 140, height: 250, borderRadius: 8),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (page) {
        if (page.results.isEmpty) return const SizedBox.shrink();
        final totalIssueCount = page.count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
                onViewAll: () => context.pushRoute(
                  ArcIssuesRoute(arcId: arcId),
                ),
              ),
              const SizedBox(height: 12),
              HorizontalPreviewSection(
                title: '',
                onViewAll: null,
                itemCount: page.results.length,
                height: 250,
                emptyText: 'No issues available.',
                itemBuilder: (context, index) {
                  final issue = page.results[index];
                  final issueId = issue.id;
                  return IssueCard(
                    issueId: issueId,
                    imageUrl: issue.image,
                    title: '${issue.series?.name ?? issue.name} #${issue.number}',
                    compact: true,
                    onTap: issueId == null
                        ? null
                        : () => context.pushRoute(
                          IssueDetailsRoute(
                            issueId: issueId,
                            initialImageUrl: issue.image,
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcDatabaseIdsSection extends StatelessWidget {
  const _ArcDatabaseIdsSection({required this.details});

  final ArcDetails details;

  @override
  Widget build(BuildContext context) {
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

class _ArcModifiedSection extends StatelessWidget {
  const _ArcModifiedSection({required this.modified});

  final DateTime modified;

  @override
  Widget build(BuildContext context) {
    final formatted = '${modified.day.toString().padLeft(2, '0')}/${modified.month.toString().padLeft(2, '0')}/${modified.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'LAST MODIFIED'),
        const SizedBox(height: 12),
        Text(
          formatted,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
