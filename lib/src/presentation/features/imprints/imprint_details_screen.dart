import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';

import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/resource_url_actions.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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

class _ImprintDetailsScreenState
    extends ConsumerState<ImprintDetailsScreen>
    with ResourceUrlActions<ImprintDetails> {
  @override
  String? resourceUrlOf(ImprintDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => 'imprint';

  @override
  String shareSubjectOf(ImprintDetails details) => details.name;

  Future<void> _refreshImprintData(ImprintDetails details) async {
    try {
      final newDetails = await ref
          .read(catalogRepositoryProvider)
          .getImprintDetails(details.id, forceRefresh: true);
      final currentDetails = ref
          .read(imprintDetailsProvider(details.id))
          .asData
          ?.value;
      if (currentDetails != newDetails) {
        ref.invalidate(imprintDetailsProvider(details.id));
      }
      if (mounted) {
        TakionAlerts.success(context, 'Imprint details refreshed');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to refresh imprint details');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(imprintDetailsProvider(widget.imprintId));

    return DetailScreenShell<ImprintDetails>(
      asyncValue: detailsAsync,
      entityType: 'imprint',
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'imprint-image-${d.id}',
      toTitle: (d) => d.name,
      onRefresh: (d) => _refreshImprintData(d),
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
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final contentItems = <InfoGridItem>[
      InfoGridItem(label: 'Name', value: details.name),
      if (details.founded != null)
        InfoGridItem(label: 'Founded', value: '${details.founded}'),
      if (details.publisher != null)
        InfoGridItem(label: 'Publisher', value: details.publisher!.name),
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
