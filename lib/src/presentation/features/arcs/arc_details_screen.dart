import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/arc_details.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_details_provider.dart';
import 'package:takion/src/presentation/features/arcs/providers/arc_issue_list_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/detail_screen_skeleton.dart';
import 'package:takion/src/presentation/components/entity_detail_actions.dart';
import 'package:takion/src/presentation/components/horizontal_preview_section.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/features/issues/issue_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';
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
    final scaffoldBg = Theme.of(context).colorScheme.surface;

    return detailsAsync.when(
      loading: () => DetailScreenSkeleton(
        initialChildSize: 0.55,
        header:
            widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: CachedNetworkImage(
                      imageUrl: widget.initialImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                ],
              )
            : ColoredBox(color: scaffoldBg),
        body: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(height: 22, width: 200, borderRadius: 4),
              const SizedBox(height: 24),
              const SkeletonBox(height: 14, width: double.infinity, borderRadius: 4),
              const SizedBox(height: 8),
              const SkeletonBox(height: 14, width: 240, borderRadius: 4),
              const SizedBox(height: 8),
              const SkeletonBox(height: 14, width: 180, borderRadius: 4),
              const SizedBox(height: 24),
              const SkeletonBox(height: 18, width: 100, borderRadius: 4),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: SkeletonBox(height: 14, borderRadius: 4),
                      ),
                      SizedBox(width: 8),
                      Expanded(child: SkeletonBox(height: 14, borderRadius: 4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Failed to load arc details: $error')),
      ),
      data: (details) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: 400,
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
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                            scaffoldBg,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 48),
                          if (details.image != null &&
                              details.image!.isNotEmpty)
                            Hero(
                              tag: 'arc-image-${details.id}',
                              child: GestureDetector(
                                onTap: () => context.pushRoute(
                                  ImagePreviewRoute(
                                    imageUrl: details.image!,
                                    title: details.name,
                                    heroTag: 'arc-image-${details.id}',
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: CachedNetworkImage(
                                      imageUrl: details.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          _bannerPlaceholder(
                                            context,
                                            details.name,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          _bannerPlaceholder(
                                            context,
                                            details.name,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 250,
                                height: 250,
                                child: _bannerPlaceholder(
                                  context,
                                  details.name,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
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
                            onOpenInBrowser: () =>
                                _openResourceUrlInBrowser(details),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.55,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.55, 0.9],
                builder: (context, scrollController) {
                  return _ArcDetailsSheet(
                    scrollController: scrollController,
                    details: details,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bannerPlaceholder(BuildContext context, String name) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.8),
      child: Center(
        child: Text(
          initials(name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ArcDetailsSheet extends ConsumerWidget {
  const _ArcDetailsSheet({
    required this.scrollController,
    required this.details,
  });

  final ScrollController scrollController;
  final ArcDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;

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
                    Text(
                      details.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                  child: _ExpandableArcDescription(description: description),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _ArcIssuesSection(arcId: details.id),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ArcDatabaseIdsSection(details: details),
              ),
            ),
            if (details.modified != null) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ArcModifiedSection(modified: details.modified!),
                ),
              ),
            ],
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

class _ExpandableArcDescription extends StatefulWidget {
  const _ExpandableArcDescription({required this.description});

  final String description;

  @override
  State<_ExpandableArcDescription> createState() =>
      _ExpandableArcDescriptionState();
}

class _ExpandableArcDescriptionState
    extends State<_ExpandableArcDescription> {
  static const _descriptionMaxLines = 4;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = widget.description;
    final textStyle = theme.textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullPainter = TextPainter(
          text: TextSpan(text: description, style: textStyle),
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final collapsedPainter = TextPainter(
          text: TextSpan(text: description, style: textStyle),
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
                const SectionHeader(title: 'SUMMARY'),
                const SizedBox(height: 8),
                ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    heightFactor: _isExpanded ? 1.0 : heightFactor,
                    child: Text(description, style: textStyle),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
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
