import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';

import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_details_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/resource_url_actions.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/providers/providers.dart';

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
    with ResourceUrlActions<UniverseDetails> {
  @override
  String? resourceUrlOf(UniverseDetails details) => details.resourceUrl;

  @override
  String get resourceLabel => 'universe';

  @override
  String shareSubjectOf(UniverseDetails details) => details.name;

  Future<void> _refreshUniverseData(UniverseDetails details) async {
    try {
      final newDetails = await ref
          .read(catalogRepositoryProvider)
          .getUniverseDetails(details.id, forceRefresh: true);
      final currentDetails = ref
          .read(universeDetailsProvider(details.id))
          .asData
          ?.value;
      if (currentDetails != newDetails) {
        ref.invalidate(universeDetailsProvider(details.id));
      }
      if (mounted) {
        TakionAlerts.success(context, 'Universe details refreshed');
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to refresh universe details');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(universeDetailsProvider(widget.universeId));

    return DetailScreenShell<UniverseDetails>(
      asyncValue: detailsAsync,
      entityType: 'universe',
      loadingImageUrl: widget.initialImageUrl,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'universe-image-${d.id}',
      toTitle: (d) => d.name,
      toSubtitle: (d) => d.designation,
      onRefresh: (d) => _refreshUniverseData(d),
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
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;

    final contentItems = <InfoGridItem>[
      InfoGridItem(label: 'Name', value: details.name),
      if (details.designation != null && details.designation!.trim().isNotEmpty)
        InfoGridItem(label: 'Designation', value: details.designation!),
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
