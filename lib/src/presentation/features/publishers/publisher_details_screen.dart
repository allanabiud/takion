import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/publisher_details.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_series_list_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/components/detail_screen_shell.dart';
import 'package:takion/src/presentation/components/expandable_description.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';
import 'package:takion/src/presentation/components/info_grid.dart';
import 'package:takion/src/presentation/components/section_header.dart';
import 'package:takion/src/presentation/components/horizontal_preview_section.dart';
import 'package:takion/src/presentation/features/series/series_card.dart';

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
    extends ConsumerState<PublisherDetailsScreen> {
  Uri? _resourceUri(PublisherDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(PublisherDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'publisher');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(PublisherDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'publisher');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'publisher');
    }
  }

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
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      heroWidth: 260,
      heroHeight: 260,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) => _buildPublisherSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildPublisherSheetSlivers(PublisherDetails details, BuildContext context, WidgetRef ref) sync* {
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
                    child: SkeletonBox(width: 120, height: 250, borderRadius: 8),
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
        _buildDatabaseIdsSection(context),
        if (hasModified) ...[
          const SizedBox(height: 8),
          Text(
            'Last modified: $modifiedValue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
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

  Widget _buildDatabaseIdsSection(BuildContext context) {
    final entries = <Widget>[];
    void addEntry(String label, String value) {
      entries.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '$label $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    addEntry('Metron', '${details.id}');
    if (details.cvId != null) addEntry('CV', '${details.cvId}');
    if (details.gcdId != null) addEntry('GCD', '${details.gcdId}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DATABASE IDS'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: entries,
        ),
      ],
    );
  }
}
