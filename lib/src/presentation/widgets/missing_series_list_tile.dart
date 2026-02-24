import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/domain/entities/missing_series.dart';

class MissingSeriesListTile extends StatelessWidget {
  const MissingSeriesListTile({
    super.key,
    required this.series,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final MissingSeries series;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  String _yearRange() {
    if (series.yearBegan == null && series.yearEnd == null) return 'Unknown';
    if (series.yearBegan != null && series.yearEnd != null) {
      return '${series.yearBegan}-${series.yearEnd}';
    }
    if (series.yearBegan != null) return '${series.yearBegan}-Present';
    return 'Until ${series.yearEnd}';
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 24.0;
    final publisherName = series.publisher?.name.trim();
    final hasPublisher = publisherName != null && publisherName.isNotEmpty;

    final effectiveOnTap =
        onTap ??
        () {
          context.pushRoute(SeriesDetailsRoute(seriesId: series.id));
        };

    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: isLast ? 12 : 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(radius) : Radius.zero,
          bottom: isLast ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                hasPublisher ? '$publisherName • ${_yearRange()}' : _yearRange(),
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    'Owned ${series.ownedIssues}/${series.totalIssues}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Missing ${series.missingCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${series.completionPercentage}% complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
