import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/sync/metron_sync_manager.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/presentation/features/settings/widgets/metron_connection_settings.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";
import "package:takion/src/presentation/providers/rate_limit_status_provider.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";

class FakeRateLimitNotifier extends RateLimitNotifier {
  @override
  RateLimitState build() {
    return const RateLimitState(
      sustainedLimit: 500,
      sustainedRemaining: 480,
      sustainedReset: 3600,
      burstRemaining: 55,
    );
  }
}

class MockMetronSyncManager extends Mock implements MetronSyncManager {}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group("MetronConnectionSettings", () {
    testWidgets("renders Cloud Synchronization and API Usage when connected", (tester) async {
      final now = DateTime(2026, 9, 4, 1, 0);
      final syncState = MetronSyncState(
        status: SyncStatus.success,
        lastSyncedAt: now,
        collectionItemsSynced: 10,
        pullListSeriesSynced: 5,
        wishlistItemsSynced: 2,
      );

      final mockSyncManager = MockMetronSyncManager();
      when(() => mockSyncManager.currentState).thenReturn(syncState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftDatabaseProvider.overrideWithValue(db),
            metronConnectionProvider.overrideWith((ref) async => true),
            metronSyncStateProvider.overrideWith((ref) => Stream.value(syncState)),
            metronSyncManagerProvider.overrideWithValue(mockSyncManager),
            pendingOfflineWritesCountProvider.overrideWith((ref) => Stream.value(0)),
            rateLimitStatusProvider.overrideWith(FakeRateLimitNotifier.new),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MetronConnectionContent(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("METRON SYNCHRONIZATION"), findsOneWidget);
      expect(find.text("Metron Sync"), findsOneWidget);
      expect(find.text("Sync Now"), findsOneWidget);
      expect(find.text("Migrate Local Data to Metron"), findsOneWidget);
      expect(find.text("API USAGE"), findsOneWidget);
      expect(find.text("480"), findsOneWidget);
    });
  });
}
