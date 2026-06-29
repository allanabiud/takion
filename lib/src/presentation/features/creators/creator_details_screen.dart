import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/creator_details.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:url_launcher/url_launcher.dart';

String _initials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'[\s\-\/]+'));
  final valid =
      parts.where((p) => p.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(p)).toList();
  if (valid.isEmpty) return '?';
  if (valid.length >= 2) {
    return '${valid[0][0]}${valid[1][0]}'.toUpperCase();
  }
  return valid[0][0].toUpperCase();
}

enum _CreatorMenuAction { share, openInBrowser }

@RoutePage()
class CreatorDetailsScreen extends ConsumerStatefulWidget {
  const CreatorDetailsScreen({
    super.key,
    @pathParam required this.creatorId,
    this.initialImageUrl,
  });

  final int creatorId;
  final String? initialImageUrl;

  @override
  ConsumerState<CreatorDetailsScreen> createState() =>
      _CreatorDetailsScreenState();
}

class _CreatorDetailsScreenState
    extends ConsumerState<CreatorDetailsScreen> {
  Uri? _resourceUri(CreatorDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(CreatorDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'creator');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(CreatorDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'creator');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'creator');
    }
  }

  Future<void> _handleMoreAction(
    _CreatorMenuAction action,
    CreatorDetails details,
  ) async {
    switch (action) {
      case _CreatorMenuAction.share:
        await _shareResourceUrl(details);
      case _CreatorMenuAction.openInBrowser:
        await _openResourceUrlInBrowser(details);
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isCreatorFavoriteProvider(widget.creatorId).future,
      );

      await repository.toggleCreatorFavorite(widget.creatorId);

      ref.invalidate(isCreatorFavoriteProvider(widget.creatorId));
      ref.invalidate(favoriteCreatorsListProvider);

      if (context.mounted) {
        TakionAlerts.success(
          context,
          !isFavorite
              ? 'Creator added to favorites'
              : 'Creator removed from favorites',
        );
      }
    } catch (e) {
      if (context.mounted) {
        TakionAlerts.error(context, 'Failed to update favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(creatorDetailsProvider(widget.creatorId));
    final scaffoldBg = Theme.of(context).colorScheme.surface;

    return detailsAsync.when(
      loading: () => _CreatorDetailsSkeleton(imageUrl: widget.initialImageUrl),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Failed to load creator details: $error')),
      ),
      data: (details) {
        final isFavoriteAsync = ref.watch(
          isCreatorFavoriteProvider(widget.creatorId),
        );
        final isFavorite = isFavoriteAsync.asData?.value ?? false;

        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (details.image != null &&
                        details.image!.isNotEmpty)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: details.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ),
                      )
                    else
                      ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.55),
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
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (details.image != null &&
                              details.image!.isNotEmpty)
                            Hero(
                              tag: 'creator-image-${details.id}',
                              child: GestureDetector(
                                onTap: () => context.pushRoute(
                                  ImagePreviewRoute(
                                    imageUrl: details.image!,
                                    title: details.name,
                                    heroTag:
                                        'creator-image-${details.id}',
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
                                              context, details.name),
                                      errorWidget: (context, url, error) =>
                                          _initialsAvatar(
                                              context, details.name),
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
                          PopupMenuButton<_CreatorMenuAction>(
                            tooltip: 'More options',
                            onSelected: (action) =>
                                _handleMoreAction(action, details),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _CreatorMenuAction.share,
                                child: Text('Share'),
                              ),
                              PopupMenuItem(
                                value: _CreatorMenuAction.openInBrowser,
                                child: Text('Open in Metron'),
                              ),
                            ],
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
                  return _CreatorDetailsSheet(
                    scrollController: scrollController,
                    details: details,
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
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
      child: Center(
        child: Text(
          _initials(name),
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

class _CreatorDetailsSheet extends ConsumerWidget {
  const _CreatorDetailsSheet({
    required this.scrollController,
    required this.details,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final ScrollController scrollController;
  final CreatorDetails details;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasAlias = details.alias.isNotEmpty;
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
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
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
                                  details.alias.map((a) => '@$a').join(', '),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: isFavorite
                              ? FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                                    padding: EdgeInsets.zero,
                                    iconSize: 28,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: onToggleFavorite,
                                  child: const Icon(Icons.favorite),
                                )
                              : FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    iconSize: 28,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: onToggleFavorite,
                                  child: const Icon(Icons.favorite_border),
                                ),
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
                  child: _CreatorDescriptionCard(description: description),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CreatorInfoCard(details: details),
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

class _CreatorDetailsSkeleton extends StatelessWidget {
  const _CreatorDetailsSkeleton({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null && imageUrl!.isNotEmpty
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox.shrink(),
                ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
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
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorDescriptionCard extends StatefulWidget {
  const _CreatorDescriptionCard({required this.description});

  final String description;

  @override
  State<_CreatorDescriptionCard> createState() =>
      _CreatorDescriptionCardState();
}

class _CreatorDescriptionCardState extends State<_CreatorDescriptionCard> {
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
                      _isExpanded
                          ? 'Tap to read less'
                          : 'Tap to read more',
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

class _CreatorInfoCard extends StatelessWidget {
  const _CreatorInfoCard({required this.details});

  final CreatorDetails details;

  String? _dateValue(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
    final birthValue = _dateValue(details.birth);
    final deathValue = _dateValue(details.death);

    final infoItems = <({String label, String value})>[
      (label: 'Metron ID', value: '${details.id}'),
      if (details.cvId != null) (label: 'CV ID', value: '${details.cvId}'),
      if (details.gcdId != null) (label: 'GCD ID', value: '${details.gcdId}'),
      if (birthValue != null) (label: 'Birth', value: birthValue),
      if (deathValue != null) (label: 'Death', value: deathValue),
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
