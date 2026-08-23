import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_series_list_provider.dart";
import "package:takion/src/presentation/shared/resource_url_actions.dart";
import "package:takion/src/presentation/shared/detail_refresh_actions.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/series/series_card.dart";
import "package:takion/src/presentation/providers/providers.dart";

@RoutePage()
class PublisherDetailsScreen extends ConsumerStatefulWidget {
  const PublisherDetailsScreen({
    super.key,
    @pathParam required this.publisherId,
    this.initialImageUrl,
  });

  final int publisherId;
  final String? initialImageUrl;

  @override
  ConsumerState<PublisherDetailsScreen> createState() =>
      _PublisherDetailsScreenState();
}

class _PublisherDetailsScreenState extends ConsumerState<PublisherDetailsScreen>
    with
        ResourceUrlActions<PublisherDetails>,
        DetailRefreshActions<PublisherDetails> {
  @override
  String? resourceUrlOf(PublisherDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => "publisher";

  @override
  String shareSubjectOf(PublisherDetails details) => details.name;

  @override
  String get entityLabel => "Publisher";

  @override
  Future<PublisherDetails> fetchDetails() {
    return ref
        .read(catalogRepositoryProvider)
        .getPublisherDetails(widget.publisherId, forceRefresh: true);
  }

  @override
  void invalidateDetails() {
    ref.invalidate(publisherDetailsProvider(widget.publisherId));
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      publisherDetailsProvider(widget.publisherId),
    );

    return DetailScreenShell<PublisherDetails>(
      asyncValue: detailsAsync,
      entityType: "publisher",
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => "publisher-image-${d.id}",
      toTitle: (d) => d.name,
      onRefresh: (_) => refreshDetails(context),
      onShare: (d) => shareResourceUrl(context, d),
      onOpenInBrowser: (d) => openResourceUrlInBrowser(context, d),
      heroWidth: 260,
      heroHeight: 260,
      heroImageAlignment: Alignment.center,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) =>
          _buildPublisherSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildPublisherSheetSlivers(
    PublisherDetails details,
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
      child: _PublisherSeriesSection(publisherId: details.id),
    );
    yield const SliverToBoxAdapter(child: SizedBox(height: 20));
    yield SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _PublisherInfoSection(details: details),
      ),
    );
  }
}

class _PublisherSeriesSection extends ConsumerWidget {
  const _PublisherSeriesSection({required this.publisherId});

  final int publisherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(publisherSeriesListProvider(publisherId));

    return seriesAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: "Series"),
              const SizedBox(height: 12),
              SizedBox(
                height: 256,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SkeletonBox(
                      width: 120,
                      height: 256,
                      borderRadius: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (seriesPage) {
        if (seriesPage.results.isEmpty) return const SizedBox.shrink();

        final previewCount = seriesPage.results.length.clamp(0, 5);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "${seriesPage.count} Series",
                onViewAll: () => context.pushRoute(
                  PublisherSeriesRoute(publisherId: publisherId),
                ),
              ),
              const SizedBox(height: 12),
              HorizontalPreviewSection(
                title: "",
                onViewAll: null,
                itemCount: previewCount,
                height: 256,
                emptyText: "No series available.",
                itemBuilder: (context, index) {
                  final series = seriesPage.results[index];
                  return SeriesCard(
                    series: series,
                    width: 120,
                    onTap: () => context.pushRoute(
                      SeriesDetailsRoute(seriesId: series.id),
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

class _PublisherInfoSection extends StatelessWidget {
  const _PublisherInfoSection({required this.details});

  final PublisherDetails details;

  @override
  Widget build(BuildContext context) {
    final contentItems = <DetailPropertyItem>[
      DetailPropertyItem(label: "Publisher Name", value: details.name),
      if (details.founded != null)
        DetailPropertyItem(label: "Founded", value: "${details.founded}"),
      if (details.country != null && details.country!.trim().isNotEmpty)
        DetailPropertyItem(label: "Country", value: details.country!.trim()),
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
