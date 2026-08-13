import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_series_list_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/resource_url_actions.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/series/series_card.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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

class _PublisherDetailsScreenState
    extends ConsumerState<PublisherDetailsScreen>
    with ResourceUrlActions<PublisherDetails> {
  @override
  String? resourceUrlOf(PublisherDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => 'publisher';

  @override
  String shareSubjectOf(PublisherDetails details) => details.name;

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      publisherDetailsProvider(widget.publisherId),
    );

    return DetailScreenShell<PublisherDetails>(
      asyncValue: detailsAsync,
      entityType: 'publisher',
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'publisher-image-${d.id}',
      toTitle: (d) => d.name,
      onRefresh: (d) async {
        try {
          final newDetails = await ref
              .read(catalogRepositoryProvider)
              .getPublisherDetails(d.id, forceRefresh: true);
          final currentDetails = ref
              .read(publisherDetailsProvider(d.id))
              .asData
              ?.value;
          if (currentDetails != newDetails) {
            ref.invalidate(publisherDetailsProvider(d.id));
          }
          if (context.mounted) {
            TakionAlerts.success(context, 'Publisher details refreshed');
          }
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.error(context, 'Failed to refresh publisher details');
          }
        }
      },
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
      yield const SliverToBoxAdapter(child: SizedBox(height: 16));
      yield SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpandableDescription(description: description),
        ),
      );
    }
    yield const SliverToBoxAdapter(child: SizedBox(height: 16));
    yield SliverToBoxAdapter(
      child: _PublisherSeriesSection(publisherId: details.id),
    );
    yield const SliverToBoxAdapter(child: SizedBox(height: 16));
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
              const SectionHeader(title: 'Series'),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SkeletonBox(
                      width: 120,
                      height: 250,
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
                title: '${seriesPage.count} Series',
                onViewAll: () => context.pushRoute(
                  PublisherSeriesRoute(publisherId: publisherId),
                ),
              ),
              const SizedBox(height: 12),
              HorizontalPreviewSection(
                title: '',
                onViewAll: null,
                itemCount: previewCount,
                height: 250,
                emptyText: 'No series available.',
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
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final contentItems = <InfoGridItem>[
      InfoGridItem(label: 'Name', value: details.name),
      if (details.founded != null)
        InfoGridItem(label: 'Founded', value: '${details.founded}'),
      if (details.country != null)
        InfoGridItem(label: 'Country', value: details.country!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DETAILS'),
        const SizedBox(height: 12),
        InfoGrid(items: contentItems),
        const SizedBox(height: 16),
        DatabaseIdsSection(
          metronId: details.id,
          comicVineId: details.cvId,
          gcdId: details.gcdId,
        ),
        if (hasModified) ...[
          const SizedBox(height: 8),
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  String? _modifiedValue() {
    final modified = details.modified;
    if (modified == null) return null;
    return DateFormatter.isoDateTime(modified);
  }
}
