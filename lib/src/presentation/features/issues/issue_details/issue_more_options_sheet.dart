import 'package:flutter/material.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';

void showIssueMoreOptionsSheet(
  BuildContext context, {
  required VoidCallback onNavigateToSeries,
  required VoidCallback onAddToReadingList,
  required VoidCallback onMyDetails,
  required VoidCallback onReadingHistory,
  int? seriesId,
  bool? isSubscribed,
  VoidCallback? onToggleSeriesSubscription,
}) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'More Options',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (seriesId != null) ...[
          ListTile(
            leading: Icon(
              isSubscribed == true
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: isSubscribed == true
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            title: Text(
              isSubscribed == true
                  ? 'Unsubscribe from Series'
                  : 'Subscribe to Series',
              style: isSubscribed == true
                  ? TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    )
                  : null,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onToggleSeriesSubscription?.call();
            },
          ),
          const Divider(height: 1),
        ],
        ListTile(
          leading: const Icon(Icons.view_agenda_outlined),
          title: const Text('Go to Series'),
          onTap: () {
            Navigator.of(context).pop();
            onNavigateToSeries();
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to Reading List'),
          onTap: () {
            Navigator.of(context).pop();
            onAddToReadingList();
          },
        ),
        ListTile(
          leading: const Icon(Icons.library_books_outlined),
          title: const Text('My Details'),
          onTap: () {
            Navigator.of(context).pop();
            onMyDetails();
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Reading History'),
          onTap: () {
            Navigator.of(context).pop();
            onReadingHistory();
          },
        ),
      ],
    ),
  );
}
