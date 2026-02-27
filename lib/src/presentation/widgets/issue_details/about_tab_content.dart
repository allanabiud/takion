import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/widgets/people_info_list_tile.dart';

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
  late final TapGestureRecognizer _readMoreRecognizer;
  late final TapGestureRecognizer _readLessRecognizer;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _readMoreRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _isDescriptionExpanded = true;
        });
      };
    _readLessRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _isDescriptionExpanded = false;
        });
      };
  }

  @override
  void dispose() {
    _readMoreRecognizer.dispose();
    _readLessRecognizer.dispose();
    super.dispose();
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
    final linkStyle = textStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: description, style: textStyle),
          maxLines: _descriptionMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = painter.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(description, style: textStyle);
        }

        if (_isDescriptionExpanded) {
          return RichText(
            text: TextSpan(
              style: textStyle,
              children: [
                TextSpan(text: description),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Read less',
                  style: linkStyle,
                  recognizer: _readLessRecognizer,
                ),
              ],
            ),
          );
        }

        const readMoreLabel = 'Read more';
        final suffix = '… $readMoreLabel';
        var low = 0;
        var high = description.length;
        var best = 0;

        while (low <= high) {
          final mid = (low + high) ~/ 2;
          final candidate = '${description.substring(0, mid).trimRight()}$suffix';
          final candidatePainter = TextPainter(
            text: TextSpan(text: candidate, style: textStyle),
            maxLines: _descriptionMaxLines,
            textDirection: Directionality.of(context),
          )..layout(maxWidth: constraints.maxWidth);

          if (candidatePainter.didExceedMaxLines) {
            high = mid - 1;
          } else {
            best = mid;
            low = mid + 1;
          }
        }

        var cutAt = best;
        if (cutAt > 0 && cutAt < description.length) {
          final wordBoundary = description.lastIndexOf(' ', cutAt);
          if (wordBoundary > 0) {
            cutAt = wordBoundary;
          }
        }
        final preview = description.substring(0, cutAt).trimRight();

        return RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: '$preview… '),
              TextSpan(
                text: readMoreLabel,
                style: linkStyle,
                recognizer: _readMoreRecognizer,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIssueMetaSection(BuildContext context) {
    final seriesType = widget.issue.series?.seriesType?.name ?? 'Unknown';
    final pages = widget.issue.page != null ? '${widget.issue.page}' : 'Unknown';
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
    final upcIsbn = (upc != null && upc.isNotEmpty && isbn != null && isbn.isNotEmpty)
        ? '$upc / $isbn'
        : (upc != null && upc.isNotEmpty)
        ? upc
        : (isbn != null && isbn.isNotEmpty)
        ? isbn
        : 'Unknown';

    String formatDate(DateTime? date) {
      if (date == null) return 'Unknown';
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
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
        const SizedBox(height: 10),
        Text(
          '$seriesType • $pages pages • $price',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        _buildStoriesSection(context),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: 10,
              children: gridItems
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenresAndIdsSection(BuildContext context) {
    final imprint = widget.issue.imprint?.name.trim();
    final genres = widget.issue.series?.genres
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

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imprint != null && imprint.isNotEmpty) ...[
            Text(
              'IMPRINT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              imprint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
          ],
          Text(
            'GENRES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            genreText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ...ids.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: '${item.label}: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
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
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text(
          stories.first,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ExpansionTile(
        key: PageStorageKey('issue-stories-${widget.issueId}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          'Stories',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
      ),
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
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reprints',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reprints
                .map(
                  (reprint) => ActionChip(
                    label: Text(labelFor(reprint)),
                    onPressed: () {
                      context.pushRoute(
                        IssueDetailsRoute(issueId: reprint.id),
                      );
                    },
                  ),
                )
                .toList(),
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

  Widget _buildCreatorsSection(BuildContext context) {
    final credits = widget.issue.credits;
    if (credits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: ExpansionTile(
        key: PageStorageKey('issue-creators-${widget.issueId}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          'Creators',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: List.generate(credits.length, (index) {
          final credit = credits[index];
          return PeopleInfoListTile(
            title: _creatorTitle(credit),
            subtitle: _creatorSubtitle(credit),
            isFirst: index == 0,
            isLast: index == credits.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildCharactersSection(BuildContext context) {
    final characters = widget.issue.characters;
    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        key: PageStorageKey('issue-characters-${widget.issueId}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          'Characters',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: List.generate(characters.length, (index) {
          final characterName = characters[index].name.trim();
          return PeopleInfoListTile(
            title: characterName.isNotEmpty ? characterName : 'Unknown Character',
            isFirst: index == 0,
            isLast: index == characters.length - 1,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionSection(context),
        _buildIssueMetaSection(context),
        _buildGenresAndIdsSection(context),
        _buildReprintsSection(context),
        _buildCreatorsSection(context),
        _buildCharactersSection(context),
        const SizedBox(height: 14),
        Text(
          'Modified: ${_formatModified(widget.issue.modified)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
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
