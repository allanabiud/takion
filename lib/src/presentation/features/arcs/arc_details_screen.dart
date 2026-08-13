import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_details_provider.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_issue_list_provider.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
  LocalReadingList? _localList;
  bool _isLoadingImport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkImportStatus());
  }

  Future<void> _checkImportStatus() async {
    final repo = ref.read(localReadingListRepositoryProvider);
    final local = await repo.findByMetronArcId(widget.arcId);
    if (mounted) {
      setState(() => _localList = local);
    }
  }

  Future<void> _import() async {
    setState(() => _isLoadingImport = true);
    try {
      final details = await ref.read(arcDetailsProvider(widget.arcId).future);
      final issues = await ref
          .read(catalogRepositoryProvider)
          .getArcIssueListAll(widget.arcId);

      final now = DateTime.now().toUtc();
      final list = LocalReadingList(
        id: const Uuid().v4(),
        title: details.name,
        description: details.desc ?? '',
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: now,
        updatedAt: now,
        items: issues.map(localReadingListItemFromIssueList).toList(),
        metronArcId: widget.arcId,
        metronAttributionSource: 'Metron Arc',
        metronImageUrl: details.image,
        lastSyncedAt: now,
      );

      await ref.read(localReadingListsProvider.notifier).addList(list);

      if (mounted) {
        TakionAlerts.success(context, 'Reading List Imported');
        setState(() => _localList = list);
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: 'Failed to import arc as reading list',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImport = false);
    }
  }

  Future<void> _removeFromLibrary() async {
    if (_localList == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Library'),
        content: Text(
          'Are you sure you want to remove "${_localList!.title}" from your library?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_outline, size: 22),
            label: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(localReadingListRepositoryProvider);
    await repo.deleteList(_localList!.id);

    if (mounted) {
      TakionAlerts.success(context, 'Removed from Library');
      setState(() => _localList = null);
    }
  }

  Widget _buildActionRow() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: _localList != null
          ? FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: theme.textTheme.titleMedium,
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _removeFromLibrary,
              icon: const Icon(Icons.delete_outline, size: 22),
              label: const Text('Remove from Library'),
            )
          : FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: theme.textTheme.titleMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoadingImport ? null : _import,
              icon: _isLoadingImport
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add, size: 22),
              label: const Text('Add to Library'),
            ),
    );
  }

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

  Future<void> _refreshArcData(ArcDetails details) async {
    try {
      final newDetails = await ref
          .read(catalogRepositoryProvider)
          .getArcDetails(details.id, forceRefresh: true);
      final currentDetails = ref
          .read(arcDetailsProvider(details.id))
          .asData
          ?.value;
      if (currentDetails != newDetails) {
        ref.invalidate(arcDetailsProvider(details.id));
      }
      if (mounted) {
        TakionAlerts.success(context, 'Arc details refreshed');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to refresh arc details');
      }
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
      onRefresh: (d) => _refreshArcData(d),
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) =>
          _buildArcSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildArcSheetSlivers(
    ArcDetails details,
    BuildContext context,
    WidgetRef ref,
  ) sync* {
    yield SliverToBoxAdapter(child: _buildActionRow());
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
    yield SliverToBoxAdapter(child: _ArcIssuesSection(arcId: details.id));
    yield const SliverToBoxAdapter(child: SizedBox(height: 16));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DatabaseIdsSection(
          metronId: details.id,
          comicVineId: details.cvId,
          gcdId: details.gcdId,
          modifiedAt: details.modified,
        ),
      ),
    );
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
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ShimmerWidget(child: IssueCardSkeleton(width: 140)),
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
                title:
                    '$totalIssueCount Issue${totalIssueCount == 1 ? '' : 's'}',
                onViewAll: () =>
                    context.pushRoute(ArcIssuesRoute(arcId: arcId)),
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
                    title:
                        '${issue.series?.name ?? issue.name} #${issue.number}',
                    seriesId: issue.series?.id,
                    seriesName: issue.series?.name,
                    issueNumber: issue.number,
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
