import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';

class SeriesListTile extends ConsumerWidget {
  final SeriesList series;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final String? heroTag;

  const SeriesListTile({
    super.key,
    required this.series,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 24.0;
    const double iconHeight = 100;
    const double iconWidth = 90;
    final subscriptionAsync = ref.watch(seriesSubscriptionProvider(series.id));
    final isSubscribed = subscriptionAsync.asData?.value?.isActive ?? false;
    final issueCount = series.issueCount ?? 0;

    final cover = Container(
      width: iconWidth,
      height: iconHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.collections_bookmark_outlined,
        size: 40,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heroTag != null ? Hero(tag: heroTag!, child: cover) : cover,
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${series.yearBegan ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 8),
                        Text(
                          '$issueCount ${issueCount == 1 ? 'issue' : 'issues'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isSubscribed
                              ? Icons.notifications_active
                              : Icons.notifications_none_outlined,
                          size: 16,
                          color: isSubscribed
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
