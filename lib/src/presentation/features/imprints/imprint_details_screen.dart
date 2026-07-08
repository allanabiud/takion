import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:takion/src/domain/entities/imprint_details.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/components/detail_screen_shell.dart';
import 'package:takion/src/presentation/components/expandable_description.dart';
import 'package:takion/src/presentation/components/info_grid.dart';
import 'package:takion/src/presentation/components/section_header.dart';

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

class _ImprintDetailsScreenState extends ConsumerState<ImprintDetailsScreen> {
  Uri? _resourceUri(ImprintDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(ImprintDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'imprint');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(ImprintDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'imprint');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'imprint');
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
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
      heroWidth: 250,
      heroHeight: 220,
      initialChildSize: 0.55,
      sheetContentBuilder: (context, d, ref) => _buildImprintSheetSlivers(d, context, ref),
    );
  }

  Iterable<Widget> _buildImprintSheetSlivers(ImprintDetails details, BuildContext context, WidgetRef ref) sync* {
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
