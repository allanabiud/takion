import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";
import "package:takion/src/presentation/features/issues/scrobble_sheet.dart";
import "package:takion/src/domain/common/string_extensions.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";

class IssueCard extends ConsumerWidget {
  final int? issueId;
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final bool? isCollected;
  final bool? isWishlisted;
  final bool? isRead;
  final bool? isPulled;
  final String? syncStatus;
  final ItemRole? role;
  final bool compact;
  final int? seriesId;
  final String? seriesName;
  final String? issueNumber;
  final String? heroTag;
  final String? scope;

  const IssueCard({
    super.key,
    this.issueId,
    this.imageUrl,
    required this.title,
    this.onTap,
    this.onLongPress,
    this.width = 120,
    this.isCollected,
    this.isWishlisted,
    this.isRead,
    this.isPulled,
    this.syncStatus,
    this.role,
    this.compact = false,
    this.seriesId,
    this.seriesName,
    this.issueNumber,
    this.heroTag,
    this.scope,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite =
        issueId != null &&
        ref.watch(favoriteIssueIdsProvider).asData?.value.contains(issueId!) ==
            true;
    final id = issueId;
    final providerStatus = id == null
        ? null
        : ref.watch(issueCollectionStatusProvider(id));
    final pullEntryAsync = id == null
        ? null
        : ref.watch(issuePullListEntryProvider(id));
    final subAsync = seriesId != null
        ? ref.watch(seriesSubscriptionProvider(seriesId!))
        : null;
    final isSubscribed = subAsync?.asData?.value?.isActive == true;

    final effectiveIsCollected =
        providerStatus?.isCollected ?? isCollected ?? false;
    final effectiveIsWishlisted =
        providerStatus?.isWishlisted ?? isWishlisted ?? false;
    final effectiveIsRead = providerStatus?.isRead ?? isRead ?? false;
    final effectiveIsPulled =
        isPulled == true ||
        (pullEntryAsync?.asData?.value != null) ||
        isSubscribed;
    final effectiveSyncStatus = providerStatus?.syncStatus ?? syncStatus;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = width.isInfinite
        ? null
        : (width * devicePixelRatio).round();

    final effectiveOnLongPress =
        onLongPress ??
        (issueId != null
            ? () {
                Feedback.forLongPress(context);
                showScrobbleSheet(
                  context: context,
                  ref: ref,
                  issueId: issueId!,
                  sheetTitle: title,
                  seriesId: seriesId,
                  seriesName: seriesName,
                  issueNumber: issueNumber,
                  imageUrl: imageUrl,
                );
              }
            : null);

    final effectiveHeroTag = heroTag;

    Widget cardContent = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          EntityCover(
            imageUrl: imageUrl,
            placeholderLabel: initials(title),
            isFavorite: isFavorite,
            isRead: effectiveIsRead,
            role: role,
            syncStatus: effectiveSyncStatus,
            cacheWidth: cacheWidth,
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 4 : 6),
            child: compact
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: StatusIndicatorIcons(
                      isCollected: effectiveIsCollected,
                      isRead: effectiveIsRead,
                      isPulled: effectiveIsPulled,
                      isWishlisted: effectiveIsWishlisted,
                      iconSize: 14,
                      spacing: 4,
                    ),
                  )
                : StatusIndicatorIcons(
                    isCollected: effectiveIsCollected,
                    isRead: effectiveIsRead,
                    isPulled: effectiveIsPulled,
                    isWishlisted: effectiveIsWishlisted,
                    iconSize: 16,
                    spacing: 8,
                  ),
          ),
        ],
      ),
    );

    if (effectiveHeroTag != null) {
      cardContent = Hero(tag: effectiveHeroTag, child: cardContent);
    }

    final tileContent = RepaintBoundary(
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: onTap,
          onLongPress: effectiveOnLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cardContent,
              SizedBox(height: compact ? 4 : 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: compact
                    ? theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    return tileContent;
  }
}
