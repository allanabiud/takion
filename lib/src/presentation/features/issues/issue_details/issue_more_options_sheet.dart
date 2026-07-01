import 'package:flutter/material.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';

void showIssueMoreOptionsSheet(
  BuildContext context,
  VoidCallback onNavigateToSeries,
  VoidCallback onAddToReadingList,
  VoidCallback onMyDetails,
  VoidCallback onReadingHistory,
) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'More Options',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
