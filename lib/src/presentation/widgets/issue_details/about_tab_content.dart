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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: child,
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

  Widget _buildAdditionalInformationSection(BuildContext context) {
    final seriesType = widget.issue.series?.seriesType?.name ?? 'Unknown';
    final pages = widget.issue.page != null ? '${widget.issue.page}' : 'Unknown';
    final currency = widget.issue.priceCurrency?.trim();
    final priceValue = widget.issue.price?.trim();
    final price = (priceValue != null && priceValue.isNotEmpty)
        ? (currency != null && currency.isNotEmpty ? '$priceValue $currency' : priceValue)
        : 'Unknown';

    final distributorSku = (widget.issue.sku?.trim().isNotEmpty ?? false) ? widget.issue.sku!.trim() : 'N/A';
    final upc = widget.issue.upc?.trim();
    final isbn = widget.issue.isbn?.trim();
    final upcIsbn = (upc != null && upc.isNotEmpty && isbn != null && isbn.isNotEmpty)
        ? '$upc / $isbn'
        : (upc != null && upc.isNotEmpty) ? upc : (isbn != null && isbn.isNotEmpty) ? isbn : 'N/A';

    final imprint = widget.issue.imprint?.name.trim() ?? 'N/A';
    final genres = widget.issue.series?.genres.map((g) => g.name.trim()).where((n) => n.isNotEmpty).toList() ?? [];
    final genreText = genres.isNotEmpty ? genres.join(', ') : 'N/A';

    String formatDate(DateTime? date) => date == null ? 'N/A' : DateFormat.yMMMd().format(date.toLocal());

    final infoItems = <({String label, String value})>[
      (label: 'Format', value: seriesType),
      (label: 'Pages', value: pages),
      (label: 'Price', value: price),
      (label: 'Imprint', value: imprint),
      (label: 'Rating', value: (widget.issue.rating?.name.trim().isNotEmpty ?? false) ? widget.issue.rating!.name.trim() : 'N/A'),
      (label: 'Distributor SKU', value: distributorSku),
      (label: 'UPC / ISBN', value: upcIsbn),
      (label: 'FOC Date', value: formatDate(widget.issue.focDate)),
      (label: 'Cover Date', value: formatDate(widget.issue.coverDate)),
      (label: 'Store Date', value: formatDate(widget.issue.storeDate)),
      (label: 'Metron ID', value: '${widget.issue.id}'),
      if (widget.issue.cvId != null) (label: 'CV ID', value: '${widget.issue.cvId}'),
      if (widget.issue.gcdId != null) (label: 'GCD ID', value: '${widget.issue.gcdId}'),
      (label: 'Genres', value: genreText),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information', style: _sectionTitleStyle(context)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: infoItems.length,
          itemBuilder: (context, index) {
            final item = infoItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
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
        if (hasStories) ...[
          if (hasDescription) const Divider(height: 24),
          _buildSectionCard(context, _buildStoriesSection(context)),
        ],
        if (hasCreators) ...[
          if (hasDescription || hasStories) const Divider(height: 24),
          _buildSectionCard(context, _buildCreatorsSection(context)),
        ],
        if (hasCharacters) ...[
          if (hasDescription || hasStories || hasCreators) const Divider(height: 24),
          _buildSectionCard(context, _buildCharactersSection(context)),
        ],
        if (hasReprints) ...[
          if (hasDescription || hasStories || hasCreators || hasCharacters)
            const Divider(height: 24),
          _buildSectionCard(context, _buildReprintsSection(context)),
        ],
        if (hasDescription ||
            hasStories ||
            hasCreators ||
            hasCharacters ||
            hasReprints)
          const Divider(height: 24),
        _buildSectionCard(context, _buildAdditionalInformationSection(context)),
        const Divider(height: 24),
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
