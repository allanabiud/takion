import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/metron_reading_list_detail.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/components/section_header.dart';

class ReadingListDetailsSheetHeader extends StatefulWidget {
  final ReadingList list;
  final MetronReadingListDetail? metronDetail;
  final double progress;
  final int readCount;
  final int totalCount;
  final Widget actions;

  const ReadingListDetailsSheetHeader({
    super.key,
    required this.list,
    this.metronDetail,
    required this.progress,
    required this.readCount,
    required this.totalCount,
    required this.actions,
  });

  @override
  State<ReadingListDetailsSheetHeader> createState() =>
      _ReadingListDetailsSheetHeaderState();
}

class _ReadingListDetailsSheetHeaderState
    extends State<ReadingListDetailsSheetHeader> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = widget.list;
    final hasDescription = list.description.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                list.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildBadges(),
              if (hasDescription) ...[
                const SizedBox(height: 12),
                _buildExpandableDescription(),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.readCount} / ${widget.totalCount} ${list.contentType == ListContentType.series ? 'Series' : 'Issues'} Read',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progress == 1.0
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              widget.actions,
              const Divider(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    final list = widget.list;
    final detail = widget.metronDetail;
    final theme = Theme.of(context);

    if (detail != null) {
      return _buildMetronBadges(detail, theme);
    }

    if (list.metronSourceId != null) {
      return _buildLocalMetronBadges(list, theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildMetronBadges(MetronReadingListDetail detail, ThemeData theme) {
    final badges = <String>[];
    final source = detail.attributionSource?.trim();
    final type = detail.listType?.trim();
    final username = detail.username?.trim();
    final attributionHost =
        Uri.tryParse(detail.attributionUrl ?? '')?.host.trim();

    if (source != null && source.isNotEmpty) {
      badges.add('Source: $source');
    }
    if (username != null && username.isNotEmpty) {
      badges.add('Attribution: @$username');
    } else if (attributionHost != null && attributionHost.isNotEmpty) {
      badges.add('Attribution: $attributionHost');
    }
    if (type != null && type.isNotEmpty) {
      badges.add('Type: $type');
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: badges
          .map(
            (badge) => Chip(
              label: Text(badge, style: theme.textTheme.labelSmall),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLocalMetronBadges(ReadingList list, ThemeData theme) {
    final badges = <String>[];
    final source = list.metronAttributionSource?.trim();
    final type = list.metronListType?.trim();
    final attributionHost =
        Uri.tryParse(list.metronAttributionUrl ?? '')?.host.trim();

    if (source != null && source.isNotEmpty) {
      badges.add('Source: $source');
    }
    if (attributionHost != null && attributionHost.isNotEmpty) {
      badges.add('Attribution: $attributionHost');
    }
    if (type != null && type.isNotEmpty) {
      badges.add('Type: $type');
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: badges
          .map(
            (badge) => Chip(
              label: Text(badge, style: theme.textTheme.labelSmall),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          )
          .toList(),
    );
  }

  Widget _buildExpandableDescription() {
    final theme = Theme.of(context);
    final rawDescription = widget.list.description.trim();
    final textStyle = theme.textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullPainter = TextPainter(
          text: TextSpan(text: rawDescription, style: textStyle),
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final collapsedPainter = TextPainter(
          text: TextSpan(text: rawDescription, style: textStyle),
          maxLines: 4,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = collapsedPainter.didExceedMaxLines;
        final collapsedHeight = isOverflowing
            ? collapsedPainter.height
            : fullPainter.height;
        final heightFactor = fullPainter.height > 0
            ? collapsedHeight / fullPainter.height
            : 1.0;

        return GestureDetector(
          onTap: () => setState(() {
            _isDescriptionExpanded = !_isDescriptionExpanded;
          }),
          child: AnimatedSize(
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
                    heightFactor:
                        _isDescriptionExpanded ? 1.0 : heightFactor,
                    child: Text(rawDescription, style: textStyle),
                  ),
                ),
                if (isOverflowing) ...[
                  const SizedBox(height: 4),
                  Text(
                    _isDescriptionExpanded
                        ? 'Tap to read less'
                        : 'Tap to read more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
