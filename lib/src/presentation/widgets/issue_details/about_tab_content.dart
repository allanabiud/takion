import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/widgets/person_info_card.dart';
import 'package:takion/src/presentation/widgets/tappable_link_row.dart';

class IssueAboutTabContent extends StatefulWidget {
  const IssueAboutTabContent({
    super.key,
    required this.issue,
    required this.issueId,
  });

  final IssueDetails issue;
  final int issueId;

  @override
  State<IssueAboutTabContent> createState() => _IssueAboutTabContentState();
}

class _IssueAboutTabContentState extends State<IssueAboutTabContent> {
  static const _descriptionMaxLines = 4;
  bool _isDescriptionExpanded = false;

  TextStyle? _sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    Widget child, {
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(14), child: child),
        ),
      ),
    );
  }

  Widget _buildExpansionTileNoSplash(
    BuildContext context, {
    Key? key,
    required Widget title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: ExpansionTile(
        key: key,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: title,
        children: children,
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final rawDescription = widget.issue.description?.trim();
    final hasDescription = rawDescription != null && rawDescription.isNotEmpty;
    final sectionTitleStyle = _sectionTitleStyle(context);

    if (!hasDescription) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: sectionTitleStyle),
          const SizedBox(height: 6),
          Text(
            'No description available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final description = rawDescription;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: sectionTitleStyle),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final painter = TextPainter(
              text: TextSpan(text: description, style: textStyle),
              maxLines: _descriptionMaxLines,
              textDirection: Directionality.of(context),
            )..layout(maxWidth: constraints.maxWidth);

            final isOverflowing = painter.didExceedMaxLines;

            if (!isOverflowing || _isDescriptionExpanded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: textStyle),
                  if (isOverflowing) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to read less',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: textStyle,
                  maxLines: _descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to read more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildIssueMetaSection(BuildContext context) {
    final seriesType = widget.issue.series?.seriesType?.name ?? 'Unknown';
    final pages = widget.issue.page != null
        ? '${widget.issue.page}'
        : 'Unknown';
    final currency = widget.issue.priceCurrency?.trim();
    final priceValue = widget.issue.price?.trim();

    final price = (priceValue != null && priceValue.isNotEmpty)
        ? (currency != null && currency.isNotEmpty
              ? '$priceValue $currency'
              : priceValue)
        : 'Unknown';

    final distributorSku = (widget.issue.sku?.trim().isNotEmpty ?? false)
        ? widget.issue.sku!.trim()
        : 'Unknown';
    final upc = widget.issue.upc?.trim();
    final isbn = widget.issue.isbn?.trim();
    final upcIsbn =
        (upc != null && upc.isNotEmpty && isbn != null && isbn.isNotEmpty)
        ? '$upc / $isbn'
        : (upc != null && upc.isNotEmpty)
        ? upc
        : (isbn != null && isbn.isNotEmpty)
        ? isbn
        : 'Unknown';

    String formatDate(DateTime? date) {
      if (date == null) return 'Unknown';
      return DateFormat.yMMMd().format(date.toLocal());
    }

    final gridItems = <({String label, String value})>[
      (label: 'Distributor SKU', value: distributorSku),
      (label: 'UPC / ISBN', value: upcIsbn),
      (
        label: 'Rating',
        value: (widget.issue.rating?.name.trim().isNotEmpty ?? false)
            ? widget.issue.rating!.name.trim()
            : 'Unknown',
      ),
      (label: 'FOC Date', value: formatDate(widget.issue.focDate)),
      (label: 'Cover Date', value: formatDate(widget.issue.coverDate)),
      (label: 'Store Date', value: formatDate(widget.issue.storeDate)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$seriesType • $pages pages • $price',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        ...gridItems.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${entry.value.label.toUpperCase()}: ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: entry.value.value),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenresAndIdsSection(BuildContext context) {
    final imprint = widget.issue.imprint?.name.trim();
    final genres =
        widget.issue.series?.genres
            .map((genre) => genre.name.trim())
            .where((name) => name.isNotEmpty)
            .toList() ??
        <String>[];

    final ids = <({String label, String value})>[
      (label: 'METRON ID', value: '${widget.issue.id}'),
      if (widget.issue.cvId != null)
        (label: 'CV ID', value: '${widget.issue.cvId}'),
      if (widget.issue.gcdId != null)
        (label: 'GCD ID', value: '${widget.issue.gcdId}'),
    ];

    final genreText = genres.isNotEmpty ? genres.join(' • ') : 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imprint != null && imprint.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: 'IMPRINT: ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(text: imprint),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              TextSpan(
                text: 'GENRES: ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextSpan(text: genreText),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ...ids.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '${item.label}: ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: item.value),
                ],
              ),
            ),
          ),
        ),
      ],
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

    if (stories.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Story', style: _sectionTitleStyle(context)),
          const SizedBox(height: 8),
          Text(
            stories.first,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return _buildExpansionTileNoSplash(
      context,
      key: PageStorageKey('issue-stories-${widget.issueId}'),
      title: Text('Stories', style: _sectionTitleStyle(context)),
      children: stories
          .map(
            (story) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Text(
                      story,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReprintsSection(BuildContext context) {
    final reprints = widget.issue.reprints
        .where((reprint) => reprint.id > 0)
        .toList();

    if (reprints.isEmpty) {
      return const SizedBox.shrink();
    }

    String labelFor(IssueDetailsReprint reprint) {
      final issueText = reprint.issue?.trim();
      if (issueText != null && issueText.isNotEmpty) return issueText;
      return 'Issue ${reprint.id}';
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: _buildExpansionTileNoSplash(
        context,
        key: PageStorageKey('issue-reprints-${widget.issueId}'),
        title: Text('Reprints', style: _sectionTitleStyle(context)),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reprints
                  .asMap()
                  .entries
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(
                        bottom: item.key == reprints.length - 1 ? 0 : 6,
                      ),
                      child: TappableLinkRow(
                        label: labelFor(item.value),
                        onTap: () {
                          context.pushRoute(
                            IssueDetailsRoute(issueId: item.value.id),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _creatorTitle(IssueDetailsCredit credit) {
    final creator = credit.creator?.trim();
    if (creator != null && creator.isNotEmpty) {
      return creator;
    }
    return 'Unknown Creator';
  }

  String? _creatorSubtitle(IssueDetailsCredit credit) {
    final roles = credit.roles
        .map((role) => role.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (roles.isEmpty) {
      return null;
    }

    return roles.join(' • ');
  }

  Widget _buildPeopleGrid(
    BuildContext context, {
    required String title,
    required List<({String name, String? subtitle})> items,
  }) {
    return _buildExpansionTileNoSplash(
      context,
      key: PageStorageKey('issue-people-grid-$title-${widget.issueId}'),
      title: Text(title, style: _sectionTitleStyle(context)),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == items.length - 1 ? 0 : 8,
                    ),
                    child: PersonInfoCard(
                      name: entry.value.name,
                      subtitle: entry.value.subtitle,
                      placeholderIcon: Icons.person_outline,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorsSection(BuildContext context) {
    final credits = widget.issue.credits;
    if (credits.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = credits
        .map<({String name, String? subtitle})>(
          (credit) =>
              (name: _creatorTitle(credit), subtitle: _creatorSubtitle(credit)),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.zero,
      child: _buildPeopleGrid(context, title: 'Creators', items: items),
    );
  }

  Widget _buildCharactersSection(BuildContext context) {
    final characters = widget.issue.characters;
    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = characters
        .map<({String name, String? subtitle})>(
          (character) => (
            name: character.name.trim().isNotEmpty
                ? character.name.trim()
                : 'Unknown Character',
            subtitle: null,
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.zero,
      child: _buildPeopleGrid(context, title: 'Characters', items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.issue.description?.trim().isNotEmpty ?? false;
    final hasMeta = true;
    final hasStories = _storyNames().isNotEmpty;
    final hasReprints = widget.issue.reprints.any((reprint) => reprint.id > 0);
    final hasCreators = widget.issue.credits.isNotEmpty;
    final hasCharacters = widget.issue.characters.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDescription)
          _buildSectionCard(
            context,
            _buildDescriptionSection(context),
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
          ),
        if (hasDescription &&
            (hasMeta ||
                hasStories ||
                hasReprints ||
                hasCreators ||
                hasCharacters))
          const SizedBox(height: 12),
        if (hasMeta)
          _buildSectionCard(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIssueMetaSection(context),
                _buildGenresAndIdsSection(context),
              ],
            ),
          ),
        if (hasMeta &&
            (hasStories || hasReprints || hasCreators || hasCharacters))
          const SizedBox(height: 12),
        if (hasStories)
          _buildSectionCard(context, _buildStoriesSection(context)),
        if (hasStories && (hasReprints || hasCreators || hasCharacters))
          const SizedBox(height: 12),
        if (hasReprints)
          _buildSectionCard(context, _buildReprintsSection(context)),
        if (hasReprints && (hasCreators || hasCharacters))
          const SizedBox(height: 12),
        if (hasCreators)
          _buildSectionCard(context, _buildCreatorsSection(context)),
        if (hasCreators && hasCharacters) const SizedBox(height: 12),
        if (hasCharacters)
          _buildSectionCard(context, _buildCharactersSection(context)),
        const SizedBox(height: 14),
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
