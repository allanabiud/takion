import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

class SeriesGenresCard extends StatelessWidget {
  const SeriesGenresCard({super.key, required this.genres});

  final List<dynamic> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "GENRES"),
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
}
