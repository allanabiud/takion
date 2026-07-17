import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';

import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/components/components.dart';

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

class _UniverseDetailsScreenState extends ConsumerState<UniverseDetailsScreen> {
  Uri? _resourceUri(UniverseDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(UniverseDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'universe');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(UniverseDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'universe');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'universe');
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
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      heroWidth: 300,
      heroHeight: 260,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) => _buildUniverseSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildUniverseSheetSlivers(UniverseDetails details, BuildContext context, WidgetRef ref) sync* {
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
      return DateFormatter.isoDateTime(modified);
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
