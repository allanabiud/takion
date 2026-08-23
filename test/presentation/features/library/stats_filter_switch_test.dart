import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/my_comics_screen.dart";
import "package:takion/src/presentation/features/library/read_screen.dart";
import "package:takion/src/presentation/features/library/widgets/reading_goal_card.dart";
import "package:takion/src/presentation/features/library/widgets/stat_card.dart";
import "package:takion/src/presentation/features/settings/providers/reading_goal_provider.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class _FakeReadingGoalNotifier extends ReadingGoalNotifier {
  final ReadingGoal? goal;
  _FakeReadingGoalNotifier(this.goal);

  @override
  Future<ReadingGoal?> build() async => goal;
}

void main() {
  group("Stats tab filter switching", () {
    testWidgets(
      "StatsOverviewCards preserves stat cards without skeletons on filter switch",
      (tester) async {
        final filterNotifier = ValueNotifier<LibraryFilter>(
          LibraryFilter.month,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              libraryBasicStatsProvider.overrideWith((ref, filter) {
                final count = filter == LibraryFilter.month ? 50 : 10;
                return Stream.value(
                  LibraryBasicStats(
                    totalOwned: count,
                    readPercent: 80.0,
                    wishlistCount: 5,
                    subscriptionsCount: 3,
                    pullsInPeriod: 4,
                    readsInPeriod: 12,
                    streakDays: 7,
                    averageRating: 4.5,
                    mostReadSeries: "Batman",
                    mostReadSeriesYear: 2016,
                    filter: filter,
                  ),
                );
              }),
              collectionStatsProvider.overrideWith(
                (ref) => Stream.value(
                  const CollectionStats(
                    totalItems: 50,
                    totalQuantity: 50,
                    readCount: 40,
                    wishlistCount: 5,
                    unreadCount: 10,
                    totalValue: r"$150.00",
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ValueListenableBuilder<LibraryFilter>(
                  valueListenable: filterNotifier,
                  builder: (context, filter, _) {
                    return StatsOverviewCards(filter: filter);
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(StatCard), findsNWidgets(4));
        expect(find.byType(SkeletonBox), findsNothing);

        filterNotifier.value = LibraryFilter.week;
        await tester.pump();

        expect(find.byType(SkeletonBox), findsNothing);
        expect(find.byType(StatCard), findsNWidgets(4));

        await tester.pumpAndSettle();
        expect(find.byType(StatCard), findsNWidgets(4));
        expect(find.byType(SkeletonBox), findsNothing);
      },
    );

    testWidgets(
      "ReadStatsCards preserves stat cards without skeletons on filter switch",
      (tester) async {
        final filterNotifier = ValueNotifier<LibraryFilter>(
          LibraryFilter.month,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              libraryBasicStatsProvider.overrideWith((ref, filter) {
                final reads = filter == LibraryFilter.month ? 25 : 5;
                return Stream.value(
                  LibraryBasicStats(
                    totalOwned: 50,
                    readPercent: 50.0,
                    wishlistCount: 5,
                    subscriptionsCount: 3,
                    pullsInPeriod: 4,
                    readsInPeriod: reads,
                    streakDays: 7,
                    averageRating: 4.5,
                    mostReadSeries: "Batman",
                    mostReadSeriesYear: 2016,
                    filter: filter,
                  ),
                );
              }),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ValueListenableBuilder<LibraryFilter>(
                  valueListenable: filterNotifier,
                  builder: (context, filter, _) {
                    return ReadStatsCards(filter: filter);
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(StatCard), findsNWidgets(4));
        expect(find.byType(SkeletonBox), findsNothing);

        filterNotifier.value = LibraryFilter.allTime;
        await tester.pump();

        expect(find.byType(SkeletonBox), findsNothing);
        expect(find.byType(StatCard), findsNWidgets(4));

        await tester.pumpAndSettle();
        expect(find.byType(StatCard), findsNWidgets(4));
        expect(find.byType(SkeletonBox), findsNothing);
      },
    );

    testWidgets(
      "ReadingGoalCard keeps card rendered and updates smoothly on filter switch",
      (tester) async {
        final filterNotifier = ValueNotifier<LibraryFilter>(
          LibraryFilter.month,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              libraryBasicStatsProvider.overrideWith((ref, filter) {
                final reads = filter == LibraryFilter.month ? 25 : 5;
                return Stream.value(
                  LibraryBasicStats(
                    totalOwned: 50,
                    readPercent: 50.0,
                    wishlistCount: 5,
                    subscriptionsCount: 3,
                    pullsInPeriod: 4,
                    readsInPeriod: reads,
                    streakDays: 7,
                    averageRating: 4.5,
                    mostReadSeries: "Batman",
                    mostReadSeriesYear: 2016,
                    filter: filter,
                  ),
                );
              }),
              readingGoalProvider.overrideWith(
                () => _FakeReadingGoalNotifier(
                  const ReadingGoal(target: 30, period: "monthly"),
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ValueListenableBuilder<LibraryFilter>(
                  valueListenable: filterNotifier,
                  builder: (context, filter, _) {
                    return ReadingGoalCard(filter: filter);
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text("Reading Goal"), findsOneWidget);

        filterNotifier.value = LibraryFilter.week;
        await tester.pump();

        expect(find.text("Reading Goal"), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.text("Reading Goal"), findsOneWidget);
      },
    );
  });
}
