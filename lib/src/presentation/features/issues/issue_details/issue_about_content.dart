import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

int _creditPriority(IssueDetailsCredit credit) {
  const primary = [
    'writer',
    'script',
    'artist',
    'penciler',
    'penciller',
    'colorist',
    'letterer',
    'inker',
    'cover',
  ];
  for (final role in credit.roles) {
    final name = role.name.trim().toLowerCase();
    for (var i = 0; i < primary.length; i++) {
      if (name.contains(primary[i])) return i;
    }
  }
  return primary.length;
}

class IssueAboutContent extends ConsumerStatefulWidget {
  const IssueAboutContent({
    super.key,
    required this.issue,
    required this.issueId,
  });

  final IssueDetails issue;
  final int issueId;

  @override
  ConsumerState<IssueAboutContent> createState() => _IssueAboutContentState();
}

class _IssueAboutContentState extends ConsumerState<IssueAboutContent> {
  static const _descriptionMaxLines = 4;
  bool _isDescriptionExpanded = false;

  static bool _isCollectedEdition(String? seriesType) {
    if (seriesType == null) return false;
    final lower = seriesType.toLowerCase();
    return lower.contains('trade paperback') ||
        lower.contains('tpb') ||
        lower.contains('hardcover') ||
        lower.contains('hc') ||
        lower.contains('omnibus') ||
        lower.contains('graphic novel') ||
        lower.contains('gn') ||
        lower.contains('compendium') ||
        lower.contains('digest') ||
        lower.contains('treasury');
  }

  Widget _buildSectionCard(
    BuildContext context,
    Widget child, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final rawDescription = widget.issue.description?.trim();
    final hasDescription = rawDescription != null && rawDescription.isNotEmpty;

    if (!hasDescription) {
      return Text(
        'No description available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final description = rawDescription;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullPainter = TextPainter(
          text: TextSpan(text: description, style: textStyle),
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final collapsedPainter = TextPainter(
          text: TextSpan(text: description, style: textStyle),
          maxLines: _descriptionMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = collapsedPainter.didExceedMaxLines;
        final collapsedHeight = isOverflowing
            ? collapsedPainter.height
            : fullPainter.height;
        final heightFactor = fullPainter.height > 0
            ? collapsedHeight / fullPainter.height
            : 1.0;

        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'SUMMARY'),
              const SizedBox(height: 8),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  heightFactor: _isDescriptionExpanded ? 1.0 : heightFactor,
                  child: Text(description, style: textStyle),
                ),
              ),
              if (isOverflowing) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  }),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topLeft,
                        child: child,
                      ),
                    ),
                    child: Text(
                      _isDescriptionExpanded
                          ? 'Tap to read less'
                          : 'Tap to read more',
                      key: ValueKey(_isDescriptionExpanded),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<String> _storyNames() {
    final names = <String>[];
    for (final name in widget.issue.names) {
      final cleaned = name.trim();
      if (cleaned.isNotEmpty && !names.contains(cleaned)) {
        names.add(cleaned);
      }
    }
    return names;
  }

  Widget _buildStoriesSection(BuildContext context) {
    final stories = _storyNames();

    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'STORIES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: stories
              .map(
                (story) => Chip(
                  label: Text(
                    story,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReprintsSection(BuildContext context) {
    final reprints = widget.issue.reprints
        .where((reprint) => reprint.id > 0)
        .toList();

    if (reprints.isEmpty) {
      return const SizedBox.shrink();
    }

    final isCollected = _isCollectedEdition(
      widget.issue.series?.seriesType?.name,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: isCollected ? 'REPRINTS' : 'REPRINTED IN'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reprints.map((reprint) {
            final issueText = reprint.issue?.trim();
            final label = issueText != null && issueText.isNotEmpty
                ? issueText
                : 'Issue ${reprint.id}';
            final chipWidth = MediaQuery.of(context).size.width - 48;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: chipWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.pushRoute(IssueDetailsRoute(issueId: reprint.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreatorsSection(BuildContext context) {
    final credits = List<IssueDetailsCredit>.from(widget.issue.credits)
      ..sort((a, b) => _creditPriority(a).compareTo(_creditPriority(b)));
    if (credits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CREATORS'),
        const SizedBox(height: 12),
        HorizontalPreviewSection(
          title: 'Creators',
          itemCount: credits.length,
          height: 150,
          separatorWidth: 0,
          itemBuilder: (context, index) {
            final credit = credits[index];
            final creator = credit.creator?.trim();
            final roles = credit.roles
                .map((r) => r.name.trim())
                .where((n) => n.isNotEmpty)
                .toSet()
                .toList();
            return PersonCard(
              creatorId: credit.id,
              name: creator != null && creator.isNotEmpty
                  ? creator
                  : 'Unknown Creator',
              subtitle: roles.isNotEmpty ? roles.first : null,
              width: 95,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCharactersSection(BuildContext context) {
    final characters = widget.issue.characters;
    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CHARACTERS'),
        const SizedBox(height: 12),
        HorizontalPreviewSection(
          title: 'Characters',
          itemCount: characters.length,
          height: 130,
          separatorWidth: 0,
          itemBuilder: (context, index) {
            final character = characters[index];
            return PersonCard(
              characterId: character.id,
              name: character.name.trim().isNotEmpty
                  ? character.name.trim()
                  : 'Unknown Character',
              width: 95,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    final teams = widget.issue.teams;
    if (teams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'TEAMS'),
        const SizedBox(height: 12),
        HorizontalPreviewSection(
          title: 'Teams',
          itemCount: teams.length,
          height: 155,
          separatorWidth: 0,
          itemBuilder: (context, index) {
            final team = teams[index];
            return EntityCard(
              entityType: 'team',
              entityId: team.id,
              name: team.name.trim().isNotEmpty
                  ? team.name.trim()
                  : 'Unknown Team',
              width: 100,
              onTap: () => context.pushRoute(TeamDetailsRoute(teamId: team.id)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildArcsSection(BuildContext context) {
    final arcs = widget.issue.arcs;
    if (arcs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ARCS'),
        const SizedBox(height: 12),
        HorizontalPreviewSection(
          title: 'Arcs',
          itemCount: arcs.length,
          height: 155,
          separatorWidth: 0,
          itemBuilder: (context, index) {
            final arc = arcs[index];
            return EntityCard(
              entityType: 'arc',
              entityId: arc.id,
              name: arc.name.trim().isNotEmpty
                  ? arc.name.trim()
                  : 'Unknown Arc',
              width: 100,
              onTap: () => context.pushRoute(ArcDetailsRoute(arcId: arc.id)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUniversesSection(BuildContext context) {
    final universes = widget.issue.universes;
    if (universes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'UNIVERSES'),
        const SizedBox(height: 12),
        HorizontalPreviewSection(
          title: 'Universes',
          itemCount: universes.length,
          height: 140,
          separatorWidth: 0,
          itemBuilder: (context, index) {
            final universe = universes[index];
            return EntityCard(
              entityType: 'universe',
              entityId: universe.id,
              name: universe.name.trim().isNotEmpty
                  ? universe.name.trim()
                  : 'Unknown Universe',
              width: 100,
              imageHeight: 80,
              onTap: () => context.pushRoute(
                UniverseDetailsRoute(universeId: universe.id),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInformationSection(BuildContext context) {
    final pages = widget.issue.page;
    final priceValue = widget.issue.price?.trim();
    final currency = widget.issue.priceCurrency?.trim();
    final rating = widget.issue.rating?.name.trim();
    final seriesType = widget.issue.series?.seriesType?.name;
    final distributorSku = widget.issue.sku?.trim();
    final upc = widget.issue.upc?.trim();
    final isbn = widget.issue.isbn?.trim();
    final upcIsbn =
        (upc != null && upc.isNotEmpty && isbn != null && isbn.isNotEmpty)
        ? '$upc / $isbn'
        : (upc != null && upc.isNotEmpty)
        ? upc
        : (isbn != null && isbn.isNotEmpty)
        ? isbn
        : null;

    String? currencySymbol(String? code) {
      switch (code?.toUpperCase()) {
        case 'USD':
          return r'$';
        case 'GBP':
          return '£';
        case 'EUR':
          return '€';
        case 'JPY':
          return '¥';
        case 'CAD':
          return r'CA$';
        case 'AUD':
          return r'A$';
        default:
          return r'$';
      }
    }

    String? formatDate(DateTime? date) =>
        date == null ? null : DateFormatter.comicDate(date);

    final price = priceValue != null && priceValue.isNotEmpty
        ? '${currencySymbol(currency)}$priceValue'
        : null;

    final allItems = <InfoGridItem>[
      // Format / Pages / Price / Volume / Rating
      if (seriesType != null) InfoGridItem(label: 'Format', value: seriesType),
      if (pages != null) InfoGridItem(label: 'Pages', value: '$pages'),
      if (price != null) InfoGridItem(label: 'Price', value: price),
      if (widget.issue.series?.volume != null)
        InfoGridItem(label: 'Volume', value: '${widget.issue.series!.volume}'),
      if (rating != null && rating.isNotEmpty)
        InfoGridItem(label: 'Rating', value: rating),
      if (widget.issue.altNumber != null &&
          widget.issue.altNumber!.trim().isNotEmpty)
        InfoGridItem(label: 'Alt Number', value: widget.issue.altNumber!),
      // Dates
      if (widget.issue.focDate != null)
        InfoGridItem(
          label: 'FOC Date',
          value: formatDate(widget.issue.focDate)!,
        ),
      if (widget.issue.coverDate != null)
        InfoGridItem(
          label: 'Cover Date',
          value: formatDate(widget.issue.coverDate)!,
        ),
      if (widget.issue.storeDate != null)
        InfoGridItem(
          label: 'Store Date',
          value: formatDate(widget.issue.storeDate)!,
        ),
      // Product codes
      if (distributorSku != null && distributorSku.isNotEmpty)
        InfoGridItem(label: 'Distributor SKU', value: distributorSku),
      if (upcIsbn != null) InfoGridItem(label: 'UPC / ISBN', value: upcIsbn),
    ];

    if (allItems.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    Widget gridCell(InfoGridItem item) {
      final label = Text(
        item.label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      );
      final value = Text(
        item.value,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
      if (item.icon != null) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 20,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [label, const SizedBox(height: 2), value],
              ),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [label, const SizedBox(height: 2), value],
      );
    }

    Widget buildItems(List<InfoGridItem> items) {
      final rows = <Widget>[];
      var i = 0;
      while (i < items.length) {
        final item = items[i];
        if (item.spanFull) {
          rows.add(gridCell(item));
          i++;
        } else {
          final row = <Widget>[Expanded(child: gridCell(item))];
          if (i + 1 < items.length && !items[i + 1].spanFull) {
            row.add(const SizedBox(width: 8));
            row.add(Expanded(child: gridCell(items[i + 1])));
            i += 2;
          } else {
            row.add(const Spacer(flex: 2));
            i++;
          }
          rows.add(Row(children: row));
        }
        if (i < items.length) {
          rows.add(const SizedBox(height: 10));
        }
      }
      return Column(children: rows);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DETAILS'),
        const SizedBox(height: 12),
        buildItems(allItems),
      ],
    );
  }

  Widget _buildIdsSection(BuildContext context) {
    final entries = <Widget>[];
    void addEntry(String label, String value) {
      entries.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
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

    addEntry('Metron', '${widget.issue.id}');
    if (widget.issue.cvId != null) addEntry('CV', '${widget.issue.cvId}');
    if (widget.issue.gcdId != null) addEntry('GCD', '${widget.issue.gcdId}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DATABASE IDS'),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: entries),
      ],
    );
  }

  Widget _buildImprintSection(BuildContext context) {
    final imprint = widget.issue.imprint;
    if (imprint == null || imprint.name.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'IMPRINT'),
        const SizedBox(height: 12),
        ImprintCard(imprintId: imprint.id, name: imprint.name),
      ],
    );
  }

  Widget _buildGenresSection(BuildContext context) {
    final genres = widget.issue.series?.genres;
    if (genres == null || genres.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GENRES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(
                    genre.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.issue.description?.trim().isNotEmpty ?? false;
    final hasStories = _storyNames().isNotEmpty;
    final hasReprints = widget.issue.reprints.any((reprint) => reprint.id > 0);
    final hasCreators = widget.issue.credits.isNotEmpty;
    final hasCharacters = widget.issue.characters.isNotEmpty;
    final hasTeams = widget.issue.teams.isNotEmpty;
    final hasArcs = widget.issue.arcs.isNotEmpty;
    final hasUniverses = widget.issue.universes.isNotEmpty;
    final hasImprint = widget.issue.imprint?.name.trim().isNotEmpty ?? false;
    final hasGenres = widget.issue.series?.genres.isNotEmpty ?? false;

    final sku = widget.issue.sku?.trim();
    final upc = widget.issue.upc?.trim();
    final isbn = widget.issue.isbn?.trim();
    final hasAdditionalInfo =
        widget.issue.series?.seriesType?.name != null ||
        (widget.issue.altNumber?.trim().isNotEmpty ?? false) ||
        widget.issue.series?.volume != null ||
        widget.issue.page != null ||
        (widget.issue.price?.trim().isNotEmpty ?? false) ||
        (widget.issue.rating?.name.trim().isNotEmpty ?? false) ||
        (sku != null && sku.isNotEmpty) ||
        (upc != null && upc.isNotEmpty) ||
        (isbn != null && isbn.isNotEmpty) ||
        widget.issue.focDate != null ||
        widget.issue.coverDate != null ||
        widget.issue.storeDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDescription) ...[
          _buildSectionCard(
            context,
            _buildDescriptionSection(context),
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
        if (hasCreators) ...[
          _buildSectionCard(context, _buildCreatorsSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasCharacters) ...[
          _buildSectionCard(context, _buildCharactersSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasTeams) ...[
          _buildSectionCard(context, _buildTeamsSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasUniverses) ...[
          _buildSectionCard(context, _buildUniversesSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasArcs) ...[
          _buildSectionCard(context, _buildArcsSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasStories) ...[
          _buildSectionCard(context, _buildStoriesSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasAdditionalInfo) ...[
          _buildAdditionalInformationSection(context),
          const SizedBox(height: 16),
        ],
        if (hasReprints) ...[
          _buildSectionCard(context, _buildReprintsSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasImprint) ...[
          _buildSectionCard(context, _buildImprintSection(context)),
          const SizedBox(height: 16),
        ],
        if (hasGenres) ...[
          _buildSectionCard(context, _buildGenresSection(context)),
          const SizedBox(height: 16),
        ],
        _buildIdsSection(context),
        const SizedBox(height: 16),
        Text(
          'Last modified: ${_formatModified(widget.issue.modified)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  String _formatModified(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
