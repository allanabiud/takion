import "package:flutter/material.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/details_property_card.dart";

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
        ? "$start – $end"
        : (start != null)
        ? "$start – Present"
        : "Until $end";

    final contentItems = <DetailPropertyItem>[
      if (details.status != null && details.status!.trim().isNotEmpty)
        DetailPropertyItem(
          label: "Status",
          badge: PublicationStatusBadge(status: details.status!.trim()),
        ),
      if (details.seriesType?.name != null &&
          details.seriesType!.name.trim().isNotEmpty)
        DetailPropertyItem(
          label: "Type",
          badge: FormatBadge(format: details.seriesType!.name.trim()),
        ),
      if (details.volume != null)
        DetailPropertyItem(label: "Volume", value: "Vol. ${details.volume}"),
      if (years != null)
        DetailPropertyItem(label: "Publication Run", value: years),
      if (details.issueCount != null)
        DetailPropertyItem(
          label: "Total Issues",
          value: "${details.issueCount} issues",
        ),
      if (details.imprint?.name != null &&
          details.imprint!.name.trim().isNotEmpty)
        DetailPropertyItem(
          label: "Imprint",
          value: details.imprint!.name.trim(),
        ),
    ];

    return DetailsPropertyCard(
      title: "DETAILS",
      items: contentItems,
    );
  }
}