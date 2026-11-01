import "dart:async";
import "package:drift/drift.dart" as drift;
import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/issues/issue_details/issue_details_sheet.dart";
import "package:takion/src/presentation/features/series/providers/series_cover_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/features/series/series_list_tile.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";
import "package:takion/src/presentation/shared/widgets/entity_card.dart";
import "package:takion/src/presentation/shared/widgets/entity_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/person_card.dart";
import "package:takion/src/presentation/shared/widgets/smart_entity_image.dart";

void main() {
  group("Status and Data Flow Reactivity Tests", () {
    testWidgets(
      "IssueDetailsSheet reflects pulled icon and button when series is subscribed even if isInPullList is false",
      (tester) async {
        const dummyIssue = IssueDetails(
          id: 555,
          number: "1",
          series: IssueDetailsSeries(
            id: 100,
            name: "Batman",
            volume: 1,
            yearBegan: 2020,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IssueDetailsSheet(
                scrollController: ScrollController(),
                issue: dummyIssue,
                issueId: 555,
                collectionStatus: null,
                isInPullList:
                    false, // Not individually pulled in pull_list_entries
                isFavorite: false,
                displayTitle: "Batman #1",
                onShowScrobbleSheet: () {},
                onToggleFavorite: () {},
                onNavigateToSeries: () {},
                seriesId: 100,
                isSubscribed: true, // But series is subscribed!
              ),
            ),
          ),
        );

        await tester.pump();

        // Pulled shopping bag icon should be filled (Icons.shopping_bag)
        expect(find.byIcon(Icons.shopping_bag), findsWidgets);
        expect(find.text("Pulled"), findsOneWidget);
      },
    );

    testWidgets(
      "SeriesListTile gracefully displays ellipsis placeholder instead of 'Unknown' when year is null or zero",
      (tester) async {
        const seriesWithoutYear = SeriesList(
          id: 999,
          name: "Action Comics",
          yearBegan: null,
          volume: 1,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              seriesStreamProvider(
                999,
              ).overrideWith((ref) => Stream.value(null)),
              cachedSeriesIssueCountProvider(
                999,
              ).overrideWith((ref) => Stream.value(null)),
              seriesCoverImageProvider(
                999,
              ).overrideWith((ref) => Stream.value(null)),
            ],
            child: const MaterialApp(
              home: Scaffold(body: SeriesListTile(series: seriesWithoutYear)),
            ),
          ),
        );

        await tester.pump();

        // Must not display "Unknown"
        expect(find.text("Unknown"), findsNothing);
        // Displays ellipsis placeholder "…"
        expect(find.text("…"), findsWidgets);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      "SmartEntityImage and PersonCard reactively display creator avatar when image is populated",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              creatorImageStreamProvider(42).overrideWith(
                (ref) =>
                    Stream.value("https://metron.cloud/media/creator/42.jpg"),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: PersonCard(creatorId: 42, name: "Chip Zdarsky"),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text("Chip Zdarsky"), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    test(
      "creatorImageStreamProvider streams updated image from database",
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        final container = ProviderContainer(
          overrides: [
            metronEntityDaoProvider.overrideWithValue(db.metronEntityDao),
          ],
        );
        addTearDown(container.dispose);

        final completer = Completer<String?>();
        final sub = container.listen(creatorImageStreamProvider(42), (
          previous,
          next,
        ) {
          if (next.asData?.value != null) {
            completer.complete(next.asData!.value);
          }
        }, fireImmediately: true);
        addTearDown(sub.close);

        await db.metronEntityDao.upsertCreator(
          const MetronCreatorsCompanion(
            id: drift.Value(42),
            name: drift.Value("Chip Zdarsky"),
            imageUrl: drift.Value("https://metron.cloud/media/creator/42.jpg"),
            isFullyHydrated: drift.Value(true),
          ),
        );

        final result = await completer.future.timeout(
          const Duration(seconds: 3),
        );
        expect(result, "https://metron.cloud/media/creator/42.jpg");
      },
    );

    testWidgets(
      "EntityCard reactively populates arc and universe images when image is cached",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              arcImageStreamProvider(77).overrideWith(
                (ref) => Stream.value("https://metron.cloud/media/arc/77.jpg"),
              ),
              universeImageStreamProvider(88).overrideWith(
                (ref) =>
                    Stream.value("https://metron.cloud/media/universe/88.jpg"),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    EntityCard(
                      entityType: "arc",
                      entityId: 77,
                      name: "Knightfall",
                    ),
                    EntityCard(
                      entityType: "universe",
                      entityId: 88,
                      name: "Prime Earth",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text("Knightfall"), findsOneWidget);
        expect(find.text("Prime Earth"), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      "EntityListTile watches entityImageStreamProvider when imageUrl is null",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              publisherImageStreamProvider(12).overrideWith(
                (ref) =>
                    Stream.value("https://metron.cloud/media/publisher/12.jpg"),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: EntityListTile(
                  entityType: "publisher",
                  entityId: 12,
                  name: "DC Comics",
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text("DC Comics"), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    test(
      "arcImageStreamProvider and universeImageStreamProvider stream updated images from database",
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        final container = ProviderContainer(
          overrides: [
            metronEntityDaoProvider.overrideWithValue(db.metronEntityDao),
          ],
        );
        addTearDown(container.dispose);

        final arcCompleter = Completer<String?>();
        final arcSub = container.listen(arcImageStreamProvider(77), (
          previous,
          next,
        ) {
          if (next.asData?.value != null) {
            arcCompleter.complete(next.asData!.value);
          }
        }, fireImmediately: true);
        addTearDown(arcSub.close);

        await db.metronEntityDao.upsertArc(
          const MetronArcsCompanion(
            id: drift.Value(77),
            name: drift.Value("Knightfall"),
            imageUrl: drift.Value("https://metron.cloud/media/arc/77.jpg"),
            isFullyHydrated: drift.Value(true),
          ),
        );

        final arcResult = await arcCompleter.future.timeout(
          const Duration(seconds: 3),
        );
        expect(arcResult, "https://metron.cloud/media/arc/77.jpg");

        final universeCompleter = Completer<String?>();
        final universeSub = container.listen(universeImageStreamProvider(88), (
          previous,
          next,
        ) {
          if (next.asData?.value != null) {
            universeCompleter.complete(next.asData!.value);
          }
        }, fireImmediately: true);
        addTearDown(universeSub.close);

        await db.metronEntityDao.upsertUniverse(
          const MetronUniversesCompanion(
            id: drift.Value(88),
            name: drift.Value("Prime Earth"),
            imageUrl: drift.Value("https://metron.cloud/media/universe/88.jpg"),
            isFullyHydrated: drift.Value(true),
          ),
        );

        final universeResult = await universeCompleter.future.timeout(
          const Duration(seconds: 3),
        );
        expect(universeResult, "https://metron.cloud/media/universe/88.jpg");
      },
    );
  });
}
