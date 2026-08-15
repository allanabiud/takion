import "package:flutter/material.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/info_grid.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

class SeriesInfoCard extends StatelessWidget {
  const SeriesInfoCard({super.key, required this.details});

  final SeriesDetails details;

  @override
  Widget build(BuildContext context) {
    final start = details.yearBegan;
    final end = details.yearEnd;
    final years = (start == null && end == null)
        ? null
        : (start != null && end != null)
        ? "$start - $end"
        : (start != null)
        ? "$start - Present"
        : "Until $end";

    final contentItems = <InfoGridItem>[
      if (details.seriesType?.name != null)
        InfoGridItem(label: "Type", value: details.seriesType!.name),
      if (details.status != null)
        InfoGridItem(label: "Status", value: details.status!),
      if (details.volume != null)
        InfoGridItem(label: "Volume", value: "${details.volume}"),
      if (years != null) InfoGridItem(label: "Years", value: years),
      if (details.issueCount != null)
        InfoGridItem(label: "Issues", value: "${details.issueCount}"),
      if (details.imprint?.name != null &&
          details.imprint!.name.trim().isNotEmpty)
        InfoGridItem(label: "Imprint", value: details.imprint!.name.trim()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "DETAILS"),
        const SizedBox(height: 12),
        InfoGrid(items: contentItems),
      ],
    );
  }
}