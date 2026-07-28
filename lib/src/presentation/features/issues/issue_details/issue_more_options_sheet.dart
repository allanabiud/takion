import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

void showIssueMoreOptionsSheet(
  BuildContext context, {
  required int issueId,
  required VoidCallback onNavigateToSeries,
  required VoidCallback onAddToReadingList,
  required VoidCallback onMyDetails,
  required VoidCallback onReadingHistory,
}) {
  TakionBottomSheet.show<void>(
    context: context,
    title: 'More Options',
    child: Consumer(
      builder: (context, ref, _) {
        return Column(
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
        );
      },
    ),
  );
}
