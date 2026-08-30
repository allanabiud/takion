import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/favorites_provider.dart";
import "package:takion/src/presentation/features/reading_lists/providers/reading_list_item_status_provider.dart";
import "package:takion/src/presentation/features/reading_lists/reading_list_card.dart";

void main() {
  testWidgets(
    "ReadingListCard does not show attribution badge when attribution source is empty or whitespace",
    (tester) async {
      final list = LocalReadingList(
        id: "test-list-1",
        title: "Test Reading List",
        description: "Description",
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        items: const [],
        metronSourceId: 123,
        metronAttributionSource: "   ",
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingListEffectiveStatusProvider.overrideWith(
              (ref, l) => const AsyncValue.data((
                readCount: 0,
                totalCount: 0,
                progress: 0.0,
              )),
            ),
            isReadingListFavoriteProvider.overrideWith(
              (ref, id) => Stream.value(false),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReadingListCard(
                list: list,
                alreadyExists: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Test Reading List"), findsOneWidget);
      expect(find.text("Added"), findsOneWidget);
      expect(find.text("   "), findsNothing);
    },
  );

  testWidgets(
    "ReadingListCard shows attribution badge when attribution source is valid",
    (tester) async {
      final list = LocalReadingList(
        id: "test-list-2",
        title: "Crisis on Infinite Earths",
        description: "Description",
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        items: const [],
        metronSourceId: 456,
        metronAttributionSource: "CBRO",
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingListEffectiveStatusProvider.overrideWith(
              (ref, l) => const AsyncValue.data((
                readCount: 0,
                totalCount: 0,
                progress: 0.0,
              )),
            ),
            isReadingListFavoriteProvider.overrideWith(
              (ref, id) => Stream.value(false),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReadingListCard(
                list: list,
                alreadyExists: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Crisis on Infinite Earths"), findsOneWidget);
      expect(find.text("Added"), findsOneWidget);
      expect(find.text("CBRO"), findsOneWidget);
    },
  );

  testWidgets(
    "ReadingListCard in Metron browse mode does not show Added badge when alreadyExists is false",
    (tester) async {
      final list = LocalReadingList(
        id: "metron-789",
        title: "Secret Wars",
        description: "",
        isOrdered: true,
        contentType: ListContentType.issue,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        items: const [],
        metronSourceId: 789,
        metronListType: "EVENT",
        metronAttributionSource: "CMRO",
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingListEffectiveStatusProvider.overrideWith(
              (ref, l) => const AsyncValue.data((
                readCount: 0,
                totalCount: 0,
                progress: 0.0,
              )),
            ),
            isReadingListFavoriteProvider.overrideWith(
              (ref, id) => Stream.value(false),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReadingListCard(
                list: list,
                isMetronBrowse: true,
                alreadyExists: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Secret Wars"), findsOneWidget);
      expect(find.text("Added"), findsNothing);
      expect(find.text("EVENT • CMRO"), findsOneWidget);
    },
  );
}
