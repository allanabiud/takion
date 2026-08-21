import "package:flutter/material.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

class DatabaseIdsSection extends StatelessWidget {
  const DatabaseIdsSection({
    super.key,
    required this.metronId,
    this.comicVineId,
    this.gcdId,
    this.modifiedAt,
  });

  final int metronId;
  final int? comicVineId;
  final int? gcdId;
  final DateTime? modifiedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <Widget>[];

    void addEntry(String label, String value) {
      entries.add(
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.4,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            "$label $value",
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: "monospace",
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    addEntry("Metron", "$metronId");
    if (comicVineId != null) addEntry("CV", "$comicVineId");
    if (gcdId != null) addEntry("GCD", "$gcdId");

    final formattedDate = modifiedAt != null
        ? DateFormatter.isoDateTime(modifiedAt!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "DATABASE IDS"),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: entries),
        if (formattedDate != null) ...[
          const SizedBox(height: 16),
          Text(
            "Last modified: $formattedDate",
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
