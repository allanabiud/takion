import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/image_error_placeholder.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';

class DetailScreenShell<T> extends ConsumerWidget {
  const DetailScreenShell({
    super.key,
    required this.asyncValue,
    this.loadingImageUrl,
    required this.entityType,
    this.initialChildSize = 0.55,
    required this.toImageUrl,
    required this.toHeroTag,
    required this.toTitle,
    this.toSubtitle,
    this.toHeaderExtra,
    this.toTrailingHeaderAction,
    this.onShare,
    this.onOpenInBrowser,
    required this.sheetContentBuilder,
    this.heroWidth = 250,
    this.heroHeight = 250,
    this.heroBorderRadius = 12,
    this.circular = false,
    this.headerHeight = 400,
    this.showHero = true,
    this.headerBackground,
  });

  final AsyncValue<T> asyncValue;
  final String? loadingImageUrl;
  final String entityType;
  final double initialChildSize;
  final String? Function(T data) toImageUrl;
  final String Function(T data) toHeroTag;
  final String Function(T data) toTitle;
  final String? Function(T data)? toSubtitle;
  final Widget? Function(T data)? toHeaderExtra;
  final Widget? Function(T data)? toTrailingHeaderAction;
  final void Function(T data)? onShare;
  final void Function(T data)? onOpenInBrowser;
  final Iterable<Widget> Function(BuildContext context, T data, WidgetRef ref)
  sheetContentBuilder;
  final double heroWidth;
  final double heroHeight;
  final double heroBorderRadius;
  final bool circular;
  final double headerHeight;
  final bool showHero;
  final Iterable<Widget> Function(BuildContext context, T data)?
  headerBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      loading: () => _buildLoading(context),
      error: (error, _) => _buildError(context, error),
      data: (data) => _buildData(context, ref, data),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.colorScheme.surface;
    final hasImage = loadingImageUrl != null && loadingImageUrl!.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage) ...[
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: CachedNetworkImage(
                      imageUrl: loadingImageUrl!,
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
                ] else
                  ColoredBox(color: scaffoldBg),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: initialChildSize,
            minChildSize: initialChildSize,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: [initialChildSize, 0.9],
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
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
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: _buildLoadingBody(context),
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

  Widget _buildLoadingBody(BuildContext context) {
    return ShimmerWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 22, width: 200, borderRadius: 4),
          const SizedBox(height: 24),
          const SkeletonBox(
            height: 14,
            width: double.infinity,
            borderRadius: 4,
          ),
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
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          TakionAlerts.cleanError(
            error,
            fallback: 'Failed to load $entityType details',
          ),
        ),
      ),
    );
  }

  Widget _buildData(BuildContext context, WidgetRef ref, T data) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.colorScheme.surface;
    final imageUrl = toImageUrl(data);
    final heroTag = toHeroTag(data);
    final title = toTitle(data);
    final subtitle = toSubtitle?.call(data);
    final headerExtra = toHeaderExtra?.call(data);
    final trailingHeaderAction = toTrailingHeaderAction?.call(data);
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: headerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (headerBackground != null)
                  ...headerBackground!(context, data)
                else ...[
                  if (hasImage)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, url, error) =>
                            imageErrorPlaceholder(
                              context,
                              url,
                              error,
                              label: null,
                            ),
                      ),
                    )
                  else
                    ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
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
                ],
                if (showHero)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48),
                        if (hasImage)
                          Hero(
                            tag: heroTag,
                            child: GestureDetector(
                              onTap: () => context.pushRoute(
                                ImagePreviewRoute(
                                  imageUrl: imageUrl,
                                  title: title,
                                  heroTag: heroTag,
                                ),
                              ),
                              child: _buildHeroClip(
                                context,
                                data,
                                title,
                                hasImage,
                              ),
                            ),
                          )
                        else
                          _buildHeroClip(context, data, title, hasImage),
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
                        onShare: onShare != null ? () => onShare!(data) : null,
                        onOpenInBrowser: onOpenInBrowser != null
                            ? () => onOpenInBrowser!(data)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: initialChildSize,
            minChildSize: initialChildSize,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: [initialChildSize, 0.9],
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (subtitle != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (trailingHeaderAction != null) ...[
                                    const SizedBox(width: 16),
                                    trailingHeaderAction,
                                  ],
                                ],
                              ),
                              if (headerExtra != null) ...[
                                const SizedBox(height: 12),
                                headerExtra,
                              ],
                            ],
                          ),
                        ),
                      ),
                      ...sheetContentBuilder(context, data, ref),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroClip(
    BuildContext context,
    T data,
    String title,
    bool hasImage,
  ) {
    final imageUrl = hasImage ? toImageUrl(data) : null;

    final child = SizedBox(
      width: heroWidth,
      height: heroHeight,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => bannerPlaceholder(context, title),
              errorWidget: (context, url, error) => imageErrorPlaceholder(
                context,
                url,
                error,
                label: title,
                iconSize: 48,
              ),
            )
          : bannerPlaceholder(context, title),
    );

    if (circular) {
      return ClipOval(child: child);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(heroBorderRadius),
      child: child,
    );
  }

  static Widget bannerPlaceholder(BuildContext context, String name) {
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
