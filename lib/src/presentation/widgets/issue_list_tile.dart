import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/issue.dart';

class IssueListTile extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const IssueListTile({
    super.key,
    required this.issue,
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
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: issue.image != null
              ? CachedNetworkImage(
                  imageUrl: issue.image!,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 90,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 90,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                )
              : Container(
                  width: 60,
                  height: 90,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image, size: 40),
                ),
        ),
        title: Text(
          issue.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (issue.seriesName != null)
              Text(
                issue.seriesName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (issue.storeDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      issue.storeDate!.toIso8601String().split('T').first,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
