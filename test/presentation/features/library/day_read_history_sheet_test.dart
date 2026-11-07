import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/features/library/providers/reading_history_provider.dart";
import "package:takion/src/presentation/features/library/widgets/day_read_history_sheet.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/shared/widgets/list_header.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";

void main() {
  group("DayReadHistorySheet Tests", () {
    final targetDate = DateTime(2026, 11, 2, 10, 30);
    final otherDate = DateTime(2026, 11, 1, 14, 0);

    final testEntries = [
      ReadingHistoryEntry(
        id: "log-1",
        issueId: 101,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "1",
        readAt: DateTime(2026, 11, 2, 9, 15),
      ),
      ReadingHistoryEntry(
        id: "log-2",
        issueId: 102,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "2",
        readAt: DateTime(2026, 11, 2, 18, 45),
      ),
      ReadingHistoryEntry(
        id: "log-3",
        issueId: 103,
        seriesId: 11,
        seriesName: "Superman",
        issueNumber: "5",
        readAt: otherDate,
      ),
    ];

    testWidgets("shows read issues for the selected date with ListHeader", (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingHistoryProvider.overrideWith(
              (ref) => Stream.value(testEntries),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDayReadHistorySheet(context, targetDate),
                  child: const Text("Open Sheet"),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text("Open Sheet"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // TakionBottomSheet should be visible with target date as title
      expect(find.byType(TakionBottomSheet), findsOneWidget);
      expect(find.text(DateFormatter.comicDate(targetDate)), findsOneWidget);

      // ListHeader should show "2 read issues"
      expect(find.byType(ListHeader), findsOneWidget);
      expect(find.text("2 read issues"), findsOneWidget);

      // Issues read on Nov 2 should be displayed
      expect(find.text("Batman #1"), findsOneWidget);
      expect(find.text("Batman #2"), findsOneWidget);

      // Superman #5 read on Nov 1 should NOT be displayed
      expect(find.text("Superman #5"), findsNothing);

      // Clean up sheet and pending timers
      Navigator.of(tester.element(find.byType(TakionBottomSheet))).pop();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets("shows empty state when no issues were read on that day", (
      tester,
    ) async {
      final emptyDate = DateTime(2026, 11, 5);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingHistoryProvider.overrideWith(
              (ref) => Stream.value(testEntries),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDayReadHistorySheet(context, emptyDate),
                  child: const Text("Open Sheet"),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text("Open Sheet"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EmptyContentState), findsOneWidget);
      expect(find.text("No issues read on this day."), findsOneWidget);

      // Clean up sheet and pending timers
      Navigator.of(tester.element(find.byType(TakionBottomSheet))).pop();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
