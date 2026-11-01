import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/presentation/features/library/providers/daily_read_activity_provider.dart";
import "package:takion/src/presentation/features/library/providers/reading_history_provider.dart";
import "package:takion/src/presentation/features/library/reading_history_screen.dart";
import "package:takion/src/presentation/shared/widgets/section_header.dart";

void main() {
  group("ReadingHistoryScreen & dailyReadActivityProvider Tests", () {
    final testEntries = [
      ReadingHistoryEntry(
        id: "log-1",
        issueId: 101,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "1",
        readAt: DateTime(2026, 11, 1, 10, 0),
      ),
      ReadingHistoryEntry(
        id: "log-2",
        issueId: 102,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "2",
        readAt: DateTime(2026, 10, 15, 14, 0),
      ),
      ReadingHistoryEntry(
        id: "log-3",
        issueId: 103,
        seriesId: 10,
        seriesName: "Batman",
        issueNumber: "3",
        readAt: DateTime(2026, 9, 20, 16, 0),
      ),
    ];

    testWidgets(
      "expanding a date does not collapse another and allows multi-expansion",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              readingHistoryProvider.overrideWith(
                (ref) => Stream.value(testEntries),
              ),
            ],
            child: const MaterialApp(home: ReadingHistoryScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 3 month groups should be rendered: November 2026, October 2026, September 2026
        final sectionHeaders = find.byType(SectionHeader);
        expect(sectionHeaders, findsNWidgets(3));

        // By default, the newest month (November 2026) is expanded
        // Issue #1 is visible
        expect(find.text("Batman #1"), findsOneWidget);
        // October and September issues are collapsed initially
        expect(find.text("Batman #2"), findsNothing);
        expect(find.text("Batman #3"), findsNothing);

        // Tap October 2026 SectionHeader to expand it
        final octoberHeaderFinder = find.ancestor(
          of: find.textContaining("OCTOBER 2026"),
          matching: find.byType(SectionHeader),
        );
        expect(octoberHeaderFinder, findsOneWidget);
        await tester.tap(octoberHeaderFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // November 2026 must STILL be expanded (did not collapse!)
        expect(find.text("Batman #1"), findsOneWidget);
        // October 2026 is now ALSO expanded
        expect(find.text("Batman #2"), findsOneWidget);
        // September 2026 remains collapsed
        expect(find.text("Batman #3"), findsNothing);

        // Tap September 2026 SectionHeader to expand it as well
        final septemberHeaderFinder = find.ancestor(
          of: find.textContaining("SEPTEMBER 2026"),
          matching: find.byType(SectionHeader),
        );
        expect(septemberHeaderFinder, findsOneWidget);
        await tester.tap(septemberHeaderFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // All three groups are now expanded simultaneously
        expect(find.text("Batman #1"), findsOneWidget);
        expect(find.text("Batman #2"), findsOneWidget);
        expect(find.text("Batman #3"), findsOneWidget);

        // Tap October 2026 again to collapse only October
        await tester.tap(octoberHeaderFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // November and September remain expanded, October is collapsed
        expect(find.text("Batman #1"), findsOneWidget);
        expect(find.text("Batman #2"), findsNothing);
        expect(find.text("Batman #3"), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      "Expand all and Collapse all action buttons toggle all date groups",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              readingHistoryProvider.overrideWith(
                (ref) => Stream.value(testEntries),
              ),
            ],
            child: const MaterialApp(home: ReadingHistoryScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap Expand All icon button
        final expandAllButton = find.byTooltip("Expand all");
        expect(expandAllButton, findsOneWidget);
        await tester.tap(expandAllButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // All 3 items should now be visible
        expect(find.text("Batman #1"), findsOneWidget);
        expect(find.text("Batman #2"), findsOneWidget);
        expect(find.text("Batman #3"), findsOneWidget);

        // Now the button should show "Collapse all"
        final collapseAllButton = find.byTooltip("Collapse all");
        expect(collapseAllButton, findsOneWidget);
        await tester.tap(collapseAllButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // All items should be collapsed
        expect(find.text("Batman #1"), findsNothing);
        expect(find.text("Batman #2"), findsNothing);
        expect(find.text("Batman #3"), findsNothing);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    test(
      "dailyReadActivityProvider accurately reflects reading history dates and counts",
      () async {
        final container = ProviderContainer(
          overrides: [
            readingHistoryProvider.overrideWith(
              (ref) => Stream.value(testEntries),
            ),
          ],
        );
        addTearDown(container.dispose);

        final sub = container.listen(
          dailyReadActivityProvider.future,
          (_, _) {},
        );
        addTearDown(sub.close);

        // Read dailyReadActivityProvider future
        final activity = await sub.read();

        // November 1, 2026 has 1 read
        expect(activity[DateTime(2026, 11, 1)], 1);
        // October 15, 2026 has 1 read
        expect(activity[DateTime(2026, 10, 15)], 1);
        // September 20, 2026 has 1 read
        expect(activity[DateTime(2026, 9, 20)], 1);
        // Other dates have no reads
        expect(activity[DateTime(2026, 11, 2)], isNull);
      },
    );
  });
}
