import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/series.dart';

class SeriesListTile extends StatelessWidget {
  final Series series;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const SeriesListTile({
    super.key,
    required this.series,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 24.0;

    return Card(
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: isLast ? 12 : 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(radius) : Radius.zero,
          bottom: isLast ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(8),
        leading: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.library_books,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          series.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Began in ${series.yearBegan ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
