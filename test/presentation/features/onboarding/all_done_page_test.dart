import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/presentation/features/onboarding/widgets/all_done_page.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

void main() {
  group("AllDonePage", () {
    testWidgets(
      "renders live counts and spinner for active phase and checkmark for completed phase",
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              metronConnectionProvider.overrideWith(
                (ref) => Future.value(true),
              ),
              metronSyncStateProvider.overrideWith(
                (ref) => Stream.value(
                  const MetronSyncState(
                    status: SyncStatus.syncing,
                    currentPhase: "Syncing collection",
                    collectionItemsSynced: 42,
                    pullListSeriesSynced: 0,
                    wishlistItemsSynced: 0,
                  ),
                ),
              ),
              activeSubscriptionsCountProvider.overrideWithValue(0),
              onboardingOwnedCountProvider.overrideWith(
                (ref) => Stream.value(0),
              ),
              onboardingWishlistCountProvider.overrideWith(
                (ref) => Stream.value(0),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(body: AllDonePage(onFinish: () {})),
            ),
          ),
        );

        await tester.pump();

        expect(find.text("Syncing Your Comics..."), findsOneWidget);
        expect(find.text("Collected Issues"), findsOneWidget);
        expect(find.text("42"), findsOneWidget);
      },
    );

    testWidgets(
      "renders all completed counts and finish button when sync finishes",
      (tester) async {
        var finished = false;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              metronConnectionProvider.overrideWith(
                (ref) => Future.value(true),
              ),
              metronSyncStateProvider.overrideWith(
                (ref) => Stream.value(
                  const MetronSyncState(
                    status: SyncStatus.success,
                    currentPhase: "Idle",
                    collectionItemsSynced: 150,
                    pullListSeriesSynced: 12,
                    wishlistItemsSynced: 8,
                  ),
                ),
              ),
              activeSubscriptionsCountProvider.overrideWithValue(0),
              onboardingOwnedCountProvider.overrideWith(
                (ref) => Stream.value(0),
              ),
              onboardingWishlistCountProvider.overrideWith(
                (ref) => Stream.value(0),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: AllDonePage(onFinish: () => finished = true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text("All Done!"), findsOneWidget);
        expect(find.text("150"), findsOneWidget);
        expect(find.text("12"), findsOneWidget);
        expect(find.text("8"), findsOneWidget);
        expect(find.text("Finish Setup"), findsOneWidget);

        await tester.tap(find.text("Finish Setup"));
        expect(finished, isTrue);
      },
    );
  });
}
