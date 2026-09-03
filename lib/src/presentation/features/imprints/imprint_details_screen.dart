import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/providers/providers.dart";

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

class _ImprintDetailsScreenState extends ConsumerState<ImprintDetailsScreen>
    with
        ResourceUrlActions<ImprintDetails>,
        DetailRefreshActions<ImprintDetails> {
  @override
  String? resourceUrlOf(ImprintDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "imprint";

  @override
  String shareSubjectOf(ImprintDetails details) => details.name;

  @override
  String get entityLabel => "Imprint";

  @override
  Future<ImprintDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getImprintDetails(widget.imprintId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(imprintDetailsProvider(widget.imprintId));
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(imprintDetailsProvider(widget.imprintId));

    return DetailScreenShell<ImprintDetails>(
      asyncValue: detailsAsync,
      entityType: "imprint",
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => "imprint-image-${d.id}",
      toTitle: (d) => d.name,
      onRefresh: (_) => refreshDetails(context),
      onRetry: () => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      heroWidth: 250,
      heroHeight: 220,
      heroImageAlignment: Alignment.center,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) =>
          _buildImprintSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildImprintSheetSlivers(
    ImprintDetails details,
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
        child: _ImprintInfoSection(details: details),
      ),
    );
  }
}

class _ImprintInfoSection extends StatelessWidget {
  const _ImprintInfoSection({required this.details});

  final ImprintDetails details;

  @override
  Widget build(BuildContext context) {
    final contentItems = <DetailPropertyItem>[
      DetailPropertyItem(label: "Imprint Name", value: details.name),
      if (details.founded != null)
        DetailPropertyItem(label: "Founded", value: "${details.founded}"),
      if (details.publisher?.name.isNotEmpty == true)
        DetailPropertyItem(
          label: "Parent Publisher",
          value: details.publisher!.name,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsPropertyCard(title: "DETAILS", items: contentItems),
        const SizedBox(height: 20),
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
