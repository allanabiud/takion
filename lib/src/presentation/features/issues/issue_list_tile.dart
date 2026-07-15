import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/scrobble_sheet.dart';
import 'package:takion/src/presentation/logic/string_extensions.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';

class IssueListTile extends ConsumerWidget {
  final IssueList issue;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFirst;
  final bool isLast;
  final bool? isCollected;
  final bool? isRead;
  final int? rating;
  final bool useCardBackground;
  final double horizontalPadding;
  final ItemRole? role;
  final bool allowRemoteHydration;

  const IssueListTile({
    super.key,
    required this.issue,
    this.onTap,
    this.onLongPress,
    this.isFirst = false,
    this.isLast = false,
    this.isCollected,
    this.isRead,
    this.rating,
    this.useCardBackground = false,
    this.horizontalPadding = 12,
    this.role,
    this.allowRemoteHydration = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double imageHeight = 98;
    const double imageWidth = 67;

    // Hydrate if data is incomplete
    final isHydrationNeeded =
        allowRemoteHydration &&
        issue.id != null &&
        (issue.image == null || issue.name.isEmpty || issue.name == 'Unknown');
    final hydratedIssueAsync = isHydrationNeeded
        ? ref.watch(issueDetailsProvider(issue.id!))
        : null;

    ref.watch(entityImageVersionProvider);
    final cache = ref.read(entityImageCacheProvider);
    final cachedImage = issue.id != null
        ? cache.getCached('issue', issue.id!)
        : null;

    final bool isHydrating = hydratedIssueAsync?.isLoading == true;
    final IssueDetails? hydratedIssue = hydratedIssueAsync?.value;
    final String effectiveName = hydratedIssue != null
        ? (hydratedIssue.title?.isNotEmpty == true
              ? hydratedIssue.title!
              : (hydratedIssue.series?.name ?? issue.name))
        : issue.name;

    final IssueList effectiveIssue = hydratedIssue != null
        ? IssueList(
            id: hydratedIssue.id,
            name: effectiveName,
            number: hydratedIssue.number,
            series: null,
            coverDate: hydratedIssue.coverDate,
            storeDate: hydratedIssue.storeDate,
            image: hydratedIssue.image ?? issue.image ?? cachedImage,
            modified: hydratedIssue.modified,
          )
        : issue.copyWith(image: issue.image ?? cachedImage);

    final effectiveOnTap =
        onTap ??
        (effectiveIssue.id == null
            ? null
            : () {
                context.pushRoute(
                  IssueDetailsRoute(
                    issueId: effectiveIssue.id!,
                    initialImageUrl: effectiveIssue.image,
                  ),
                );
              });

    final issueTitle =
        effectiveIssue.name.contains('#${effectiveIssue.number}') ||
            effectiveIssue.number.isEmpty
        ? effectiveIssue.name
        : '${effectiveIssue.name} #${effectiveIssue.number}';
    final effectiveOnLongPress =
        onLongPress ??
        (effectiveIssue.id != null
            ? () => showScrobbleSheet(
                context: context,
                ref: ref,
                issueId: effectiveIssue.id!,
                sheetTitle: issueTitle,
              )
            : null);

    final providerStatus = ref.watch(
      issueCollectionStatusProvider(effectiveIssue.id ?? 0),
    );
    final pullEntryAsync = effectiveIssue.id == null
        ? null
        : ref.watch(issuePullListEntryProvider(effectiveIssue.id!));
    final effectiveIsCollected =
        isCollected ?? providerStatus?.isCollected ?? false;
    final effectiveIsWishlisted = providerStatus?.isWishlisted ?? false;
    final effectiveIsRead = isRead ?? providerStatus?.isRead ?? false;
    final effectiveIsPulled = pullEntryAsync?.asData?.value != null;
    final effectiveRating = rating ?? providerStatus?.rating;
    final isFavorite =
        effectiveIssue.id != null &&
        ref.watch(isIssueFavoriteProvider(effectiveIssue.id!)).asData?.value ==
            true;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (imageWidth * devicePixelRatio).round();

    final Widget leading = isHydrating
        ? Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: effectiveIssue.image != null
                  ? CachedNetworkImage(
                      imageUrl: effectiveIssue.image!,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheWidth,
                      placeholder: (context, url) => Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                        child: Center(
                          child: Text(
                            initials(issueTitle),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: imageWidth,
                      height: imageHeight,
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                      child: Center(
                        child: Text(
                          initials(issueTitle),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          );

    final tileContent = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: isHydrating
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        effectiveIssue.name.contains(
                                  '#${effectiveIssue.number}',
                                ) ||
                                effectiveIssue.number.isEmpty
                            ? effectiveIssue.name
                            : '${effectiveIssue.name} #${effectiveIssue.number}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (effectiveIssue.storeDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            DateFormat.yMMMd().format(
                              effectiveIssue.storeDate!,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            StatusIndicatorIcons(
                              isCollected: effectiveIsCollected,
                              isRead: effectiveIsRead,
                              isPulled: effectiveIsPulled,
                              isWishlisted: effectiveIsWishlisted,
                              iconSize: 16,
                              spacing: 8,
                            ),
                            if (isFavorite) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red,
                              ),
                            ],
                            const Spacer(),
                            if ((effectiveRating ?? 0) > 0)
                              ...List.generate(5, (index) {
                                final value = (effectiveRating ?? 0).clamp(
                                  0,
                                  5,
                                );
                                return Icon(
                                  index < value
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              }),
                          ],
                        ),
                      ),
                      if (role != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(children: [RoleBadge(role: role!)]),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );

    if (useCardBackground) {
      const radius = 24.0;
      return Card(
        margin: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: isLast ? 12 : 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(radius) : Radius.zero,
            bottom: isLast ? const Radius.circular(radius) : Radius.zero,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: effectiveOnTap,
          onLongPress: effectiveOnLongPress,
          child: tileContent,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: isFirst ? 12 : 2,
        bottom: isLast ? 12 : 0,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: effectiveOnTap,
              onLongPress: effectiveOnLongPress,
              child: tileContent,
            ),
          ),
        ],
      ),
    );
  }
}
