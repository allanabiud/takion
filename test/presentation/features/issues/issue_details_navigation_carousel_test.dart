import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/presentation/features/issues/issue_details/widgets/issue_cover_carousel.dart";

void main() {
  group("IssueCoverCarousel Tests", () {
    testWidgets(
      "renders cover, disables previous button when previousIssueId is null",
      (tester) async {
        bool nextClicked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IssueCoverCarousel(
                currentIssueId: 10,
                currentImageUrl: "https://example.com/cover10.jpg",
                slideDirection: 0,
                previousIssueId: null,
                nextIssueId: 11,
                onPrevious: null,
                onNext: () {
                  nextClicked = true;
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Previous button is disabled
        final prevButtonFinder = find.widgetWithIcon(
          IconButton,
          Icons.chevron_left,
        );
        expect(prevButtonFinder, findsOneWidget);
        final IconButton prevButton = tester.widget(prevButtonFinder);
        expect(prevButton.onPressed, isNull);

        // Next button is enabled and triggers callback
        final nextButtonFinder = find.widgetWithIcon(
          IconButton,
          Icons.chevron_right,
        );
        expect(nextButtonFinder, findsOneWidget);
        await tester.tap(nextButtonFinder);
        expect(nextClicked, isTrue);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      "triggers onNext callback when user swipes left on the carousel",
      (tester) async {
        bool nextTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IssueCoverCarousel(
                currentIssueId: 10,
                currentImageUrl: "https://example.com/cover10.jpg",
                slideDirection: 1,
                previousIssueId: 9,
                nextIssueId: 11,
                onPrevious: () {},
                onNext: () {
                  nextTriggered = true;
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Fling left (drag gesture with velocity from right to left)
        await tester.fling(
          find.byType(IssueCoverCarousel),
          const Offset(-300, 0),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(nextTriggered, isTrue);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets(
      "triggers onPrevious callback when user swipes right on the carousel",
      (tester) async {
        bool prevTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IssueCoverCarousel(
                currentIssueId: 10,
                currentImageUrl: "https://example.com/cover10.jpg",
                slideDirection: -1,
                previousIssueId: 9,
                nextIssueId: 11,
                onPrevious: () {
                  prevTriggered = true;
                },
                onNext: () {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Fling right (drag gesture with velocity from left to right)
        await tester.fling(
          find.byType(IssueCoverCarousel),
          const Offset(300, 0),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(prevTriggered, isTrue);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
      },
    );

    testWidgets("animates transition smoothly when currentIssueId updates", (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IssueCoverCarousel(
              currentIssueId: 10,
              currentImageUrl: "https://example.com/cover10.jpg",
              slideDirection: 0,
              previousIssueId: 9,
              nextIssueId: 11,
            ),
          ),
        ),
      );
      await tester.pump();

      // Update to issue 11
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IssueCoverCarousel(
              currentIssueId: 11,
              currentImageUrl: "https://example.com/cover11.jpg",
              slideDirection: 1,
              previousIssueId: 10,
              nextIssueId: 12,
            ),
          ),
        ),
      );

      // Mid-transition pump (phase 1: exit)
      await tester.pump(const Duration(milliseconds: 80));
      // Transition completes and settles
      await tester.pump(const Duration(milliseconds: 300));

      // After settling, the hero for current issue 11 should be present
      expect(find.byType(Hero), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
