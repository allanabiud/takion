import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';
import 'package:takion/src/presentation/components/detail_screen_skeleton.dart';
import 'package:takion/src/presentation/components/entity_detail_actions.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/components/info_grid.dart';

@RoutePage()
class ImprintDetailsScreen extends ConsumerStatefulWidget {
  const ImprintDetailsScreen({
    super.key,
    @pathParam required this.imprintId,
    this.initialImageUrl,
  });

  final int imprintId;
  final String? initialImageUrl;

  @override
  ConsumerState<ImprintDetailsScreen> createState() =>
      _ImprintDetailsScreenState();
}

class _ImprintDetailsScreenState extends ConsumerState<ImprintDetailsScreen> {
  Uri? _resourceUri(ImprintDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(ImprintDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'imprint');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(ImprintDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'imprint');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'imprint');
    }
  }



  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(imprintDetailsProvider(widget.imprintId));
    final scaffoldBg = Theme.of(context).colorScheme.surface;

    return detailsAsync.when(
      loading: () => DetailScreenSkeleton(
        initialChildSize: 0.55,
        header: widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
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
              const SkeletonBox(height: 18, width: 90, borderRadius: 4),
              const SizedBox(height: 12),
              const SkeletonBox(height: 14, width: double.infinity, borderRadius: 4),
              const SizedBox(height: 8),
              const SkeletonBox(height: 14, width: 240, borderRadius: 4),
              const SizedBox(height: 8),
              const SkeletonBox(height: 14, width: 180, borderRadius: 4),
              const SizedBox(height: 24),
              const SkeletonBox(height: 18, width: 90, borderRadius: 4),
              const SizedBox(height: 12),
              ...List.generate(4, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: SkeletonBox(height: 14, borderRadius: 4)),
                    SizedBox(width: 8),
                    Expanded(child: SkeletonBox(height: 14, borderRadius: 4)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Failed to load imprint details: $error')),
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
                              tag: 'imprint-image-${details.id}',
                              child: GestureDetector(
                                onTap: () => context.pushRoute(
                                  ImagePreviewRoute(
                                    imageUrl: details.image!,
                                    title: details.name,
                                    heroTag: 'imprint-image-${details.id}',
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 250,
                                    height: 220,
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
                                height: 220,
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
                            onOpenInBrowser: () => _openResourceUrlInBrowser(details),
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
                  return _ImprintDetailsSheet(
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
            fontSize: 40,
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

class _ImprintDetailsSheet extends ConsumerWidget {
  const _ImprintDetailsSheet({
    required this.scrollController,
    required this.details,
  });

  final ScrollController scrollController;
  final ImprintDetails details;

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
                  child: _ExpandableImprintDescription(
                    description: description,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ImprintInfoSection(details: details),
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

class _ExpandableImprintDescription extends StatefulWidget {
  const _ExpandableImprintDescription({required this.description});

  final String description;

  @override
  State<_ExpandableImprintDescription> createState() =>
      _ExpandableImprintDescriptionState();
}

class _ExpandableImprintDescriptionState
    extends State<_ExpandableImprintDescription> {
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
                Text('Summary', style: _sectionTitleStyle(context)),
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

class _ImprintInfoSection extends StatelessWidget {
  const _ImprintInfoSection({required this.details});

  final ImprintDetails details;

  @override
  Widget build(BuildContext context) {
    final items = <InfoGridItem>[
      InfoGridItem(label: 'Name', value: details.name),
      if (details.founded != null)
        InfoGridItem(label: 'Founded', value: '${details.founded}'),
      if (details.publisher != null)
        InfoGridItem(label: 'Publisher', value: details.publisher!.name),
      if (details.cvId != null) InfoGridItem(label: 'CV ID', value: '${details.cvId}'),
      if (details.gcdId != null) InfoGridItem(label: 'GCD ID', value: '${details.gcdId}'),
      InfoGridItem(label: 'Metron ID', value: '${details.id}'),
    ];

    return InfoGrid(items: items);
  }
}
