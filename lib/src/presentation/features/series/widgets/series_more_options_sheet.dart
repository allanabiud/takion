import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/reading_lists/add_to_local_reading_list_bottom_sheet.dart";
import "package:takion/src/presentation/features/series/series_issue_bulk_actions.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";

void showSeriesMoreOptionsSheet(
  BuildContext context,
  WidgetRef ref,
  int seriesId, {
  String seriesName = "",
  int? seriesYear,
}) {
  TakionBottomSheet.show<void>(
    context: context,
    title: "More Options",
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text("Add to Reading List"),
          onTap: () {
            Navigator.of(context).pop();
            AddToLocalReadingListBottomSheet.show(
              context: context,
              targetId: "series-$seriesId",
              isSeries: true,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add_check_rounded),
          title: const Text("Bulk Series Actions"),
          onTap: () {
            Navigator.of(context).pop();
            showSeriesIssueBulkActionsSheet(
              context: context,
              ref: ref,
              seriesId: seriesId,
              seriesName: seriesName,
              seriesYear: seriesYear,
            );
          },
        ),
      ],
    ),
  );
}