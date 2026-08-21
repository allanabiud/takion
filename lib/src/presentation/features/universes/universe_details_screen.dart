import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/universes/providers/universe_details_provider.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/providers/providers.dart";

@RoutePage()
class UniverseDetailsScreen extends ConsumerStatefulWidget {
  const UniverseDetailsScreen({
    super.key,
    @pathParam required this.universeId,
    this.initialImageUrl,
  });

  final int universeId;
  final String? initialImageUrl;

  @override
  ConsumerState<UniverseDetailsScreen> createState() =>
      _UniverseDetailsScreenState();
}

class _UniverseDetailsScreenState
    extends ConsumerState<UniverseDetailsScreen>
    with
        ResourceUrlActions<UniverseDetails>,
        DetailRefreshActions<UniverseDetails> {
  @override
  String? resourceUrlOf(UniverseDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "universe";

  @override
  String shareSubjectOf(UniverseDetails details) => details.name;

  @override
  String get entityLabel => "Universe";

  @override
  Future<UniverseDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getUniverseDetails(widget.universeId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(universeDetailsProvider(widget.universeId));
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(universeDetailsProvider(widget.universeId));

    return DetailScreenShell<UniverseDetails>(
      asyncValue: detailsAsync,
      entityType: "universe",
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => "universe-image-${d.id}",
      toTitle: (d) => d.name,
      toSubtitle: (d) => d.designation,
      onRefresh: (_) => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      heroWidth: 300,
      heroHeight: 260,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) =>
          _buildUniverseSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildUniverseSheetSlivers(
    UniverseDetails details,
    BuildContext context,
    WidgetRef ref,
  ) sync* {
    final description = details.desc?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    if (hasDescription) {
      yield const SliverToBoxAdapter(child: SizedBox(height: 20));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpandableDescription(description: description),
        ),
      );
    }
    yield const SliverToBoxAdapter(child: SizedBox(height: 20));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _UniverseInfoSection(details: details),
      ),
    );
  }
}

class _UniverseInfoSection extends StatelessWidget {
  const _UniverseInfoSection({required this.details});

  final UniverseDetails details;

  @override
  Widget build(BuildContext context) {
    final contentItems = <DetailPropertyItem>[
      DetailPropertyItem(label: "Universe Name", value: details.name),
      if (details.designation != null && details.designation!.trim().isNotEmpty)
        DetailPropertyItem(label: "Designation", value: details.designation!),
      if (details.publisher != null &&
          details.publisher!.name.trim().isNotEmpty)
        DetailPropertyItem(
          label: "Publisher",
          value: details.publisher!.name.trim(),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsPropertyCard(
          title: "DETAILS",
          items: contentItems,
        ),
        const SizedBox(height: 20),
        DatabaseIdsSection(
          metronId: details.id,
          gcdId: details.gcdId,
          modifiedAt: details.modified,
        ),
      ],
    );
  }
}
