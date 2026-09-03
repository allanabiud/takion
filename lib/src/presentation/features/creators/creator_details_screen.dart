import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/creators/providers/creator_details_provider.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/favorite_toggle_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

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

class _CreatorDetailsScreenState extends ConsumerState<CreatorDetailsScreen>
    with
        ResourceUrlActions<CreatorDetails>,
        FavoriteToggleActions,
        DetailRefreshActions<CreatorDetails> {
  @override
  String? resourceUrlOf(CreatorDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "creator";

  @override
  String shareSubjectOf(CreatorDetails details) => details.name;

  @override
  String get entityLabel => "Creator";

  @override
  Future<CreatorDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getCreatorDetails(widget.creatorId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(creatorDetailsProvider(widget.creatorId));
  }

  Future<void> _toggleFavorite() {
    return toggleFavoriteWithUndo(
      context,
      isFavorite: ref.read(isCreatorFavoriteProvider(widget.creatorId).future),
      toggle: () async {
        final repository = ref.read(favoritesRepositoryProvider);
        await repository.toggleCreatorFavorite(widget.creatorId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(creatorDetailsProvider(widget.creatorId));
    final isFavoriteAsync = ref.watch(
      isCreatorFavoriteProvider(widget.creatorId),
    );
    final isFavorite = isFavoriteAsync.asData?.value ?? false;

    return DetailScreenShell<CreatorDetails>(
      asyncValue: detailsAsync,
      loadingImageUrl: widget.initialImageUrl,
      entityType: "creator",
      initialChildSize: 0.60,
      headerHeight: 350,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => "creator-image-${d.id}",
      toTitle: (d) => d.name,
      toSubtitle: (d) =>
          d.alias.isNotEmpty ? d.alias.map((a) => "@$a").join(", ") : null,
      onRefresh: (_) => refreshDetails(context),
      onRetry: () => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      circular: true,
      heroWidth: 260,
      heroHeight: 260,
      toTrailingHeaderAction: (d) => FavoriteToggleButton(
        isFavorite: isFavorite,
        onToggleFavorite: _toggleFavorite,
        compact: true,
      ),
      sheetContentBuilder: (context, data, ref) {
        final description = data.desc?.trim();
        final hasDescription = description != null && description.isNotEmpty;

        return [
          if (hasDescription) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpandableDescription(description: description),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CreatorInfoCard(details: data),
            ),
          ),
        ];
      },
    );
  }
}

class _CreatorInfoCard extends StatelessWidget {
  const _CreatorInfoCard({required this.details});

  final CreatorDetails details;

  String? _dateValue(DateTime? date) {
    if (date == null) return null;
    return DateFormatter.comicDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final birthValue = _dateValue(details.birth);
    final deathValue = _dateValue(details.death);

    final contentItems = <DetailPropertyItem>[
      if (birthValue != null)
        DetailPropertyItem(label: "Birth Date", value: birthValue),
      if (deathValue != null)
        DetailPropertyItem(label: "Date of Passing", value: deathValue),
      if (details.alias.isNotEmpty)
        DetailPropertyItem(label: "Aliases", value: details.alias.join(", ")),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contentItems.isNotEmpty) ...[
          DetailsPropertyCard(title: "DETAILS", items: contentItems),
          const SizedBox(height: 20),
        ],
        DatabaseIdsSection(
          metronId: details.id,
          comicVineId: details.cvId,
          gcdId: details.gcdId,
          modifiedAt: details.modified,
        ),
      ],
    );
  }
}
