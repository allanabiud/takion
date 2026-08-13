import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_details_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/library/providers/favorites_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

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

class _CreatorDetailsScreenState extends ConsumerState<CreatorDetailsScreen> {
  Uri? _resourceUri(CreatorDetails details) {
    final resourceUrl = details.resourceUrl?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> _shareResourceUrl(CreatorDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, 'creator');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: details.name),
    );
  }

  Future<void> _openResourceUrlInBrowser(CreatorDetails details) async {
    final uri = _resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, 'creator');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, 'creator');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final isFavorite = await ref.read(
        isCreatorFavoriteProvider(widget.creatorId).future,
      );

      await repository.toggleCreatorFavorite(widget.creatorId);

      if (mounted) {
        final added = !isFavorite;
        (added ? TakionAlerts.successWithUndo : TakionAlerts.infoWithUndo)(
          context,
          added ? 'Added to Favourites' : 'Removed from Favourites',
          icon: Icons.favorite,
          actionLabel: 'Undo',
          onUndo: () async {
            await repository.toggleCreatorFavorite(widget.creatorId);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.error(context, 'Failed to update favourites');
      }
    }
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
      entityType: 'creator',
      initialChildSize: 0.60,
      headerHeight: 350,
      toImageUrl: (d) => d.image,
      toHeroTag: (d) => 'creator-image-${d.id}',
      toTitle: (d) => d.name,
      toSubtitle: (d) =>
          d.alias.isNotEmpty ? d.alias.map((a) => '@$a').join(', ') : null,
      onRefresh: (d) async {
        try {
          final newDetails = await ref
              .read(catalogRepositoryProvider)
              .getCreatorDetails(d.id, forceRefresh: true);
          final currentDetails = ref
              .read(creatorDetailsProvider(d.id))
              .asData
              ?.value;
          if (currentDetails != newDetails) {
            ref.invalidate(creatorDetailsProvider(d.id));
          }
          if (context.mounted) {
            TakionAlerts.success(context, 'Creator details refreshed');
          }
        } catch (e) {
          if (context.mounted) {
            TakionAlerts.error(context, 'Failed to refresh creator details');
          }
        }
      },
      onShare: (d) => _shareResourceUrl(d),
      onOpenInBrowser: (d) => _openResourceUrlInBrowser(d),
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
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpandableDescription(description: description),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

  @override
  Widget build(BuildContext context) {
    final modifiedValue = _modifiedValue();
    final hasModified = modifiedValue != null && modifiedValue.isNotEmpty;
    final birthValue = _dateValue(details.birth);
    final deathValue = _dateValue(details.death);

    final contentItems = <InfoGridItem>[
      if (birthValue != null) InfoGridItem(label: 'Birth', value: birthValue),
      if (deathValue != null) InfoGridItem(label: 'Death', value: deathValue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contentItems.isNotEmpty) ...[
          const SectionHeader(title: 'DETAILS'),
          const SizedBox(height: 12),
          InfoGrid(items: contentItems),
          const SizedBox(height: 16),
        ],
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
}
