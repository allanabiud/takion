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
  final ItemRole? role;
  final bool compact;
  final int? seriesId;
  final String? seriesName;
  final String? issueNumber;
  final String? heroTag;

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
    this.role,
    this.compact = false,
    this.seriesId,
    this.seriesName,
    this.issueNumber,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite =
        issueId != null &&
        ref.watch(favoriteIssueIdsProvider).asData?.value.contains(issueId!) ==
            true;
    final id = issueId;
    final hasExplicitStatus =
        isCollected != null && isWishlisted != null && isRead != null;
    final providerStatus = id == null || hasExplicitStatus
        ? null
        : ref.watch(issueCollectionStatusProvider(id));
    final pullEntryAsync = id == null || isPulled != null
        ? null
        : ref.watch(issuePullListEntryProvider(id));

    final effectiveIsCollected =
        isCollected ?? providerStatus?.isCollected ?? false;
    final effectiveIsWishlisted =
        isWishlisted ?? providerStatus?.isWishlisted ?? false;
    final effectiveIsRead = isRead ?? providerStatus?.isRead ?? false;
    final effectiveIsPulled = isPulled ?? pullEntryAsync?.asData?.value != null;

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

    if (heroTag != null) {
      cardContent = Hero(tag: heroTag!, child: cardContent);
    }

    return RepaintBoundary(
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
  }
}
