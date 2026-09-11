import "package:drift/drift.dart" show driftRuntimeOptions;
import "package:drift/native.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/core/session/session_coordinator.dart";
import "package:takion/src/core/sync/metron_sync_manager.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

class MockMetronAccountService extends Mock implements MetronAccountService {}
class MockMetronSyncManager extends Mock implements MetronSyncManager {}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;
  late MockMetronAccountService mockMetronService;
  late MockMetronSyncManager mockSyncManager;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockMetronService = MockMetronAccountService();
    mockSyncManager = MockMetronSyncManager();

    container = ProviderContainer(
      overrides: [
        driftDatabaseProvider.overrideWithValue(db),
        metronAccountServiceProvider.overrideWithValue(mockMetronService),
        metronSyncManagerProvider.overrideWithValue(mockSyncManager),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group("SessionCoordinator", () {
    test("initial state is booting", () {
      final coordinator = container.read(sessionCoordinatorProvider);
      expect(coordinator.state, equals(SessionState.booting));
    });

    test("setState transitions and logs state", () {
      final coordinator = container.read(sessionCoordinatorProvider);
      coordinator.setState(SessionState.onboarding);
      expect(coordinator.state, equals(SessionState.onboarding));
    });

    test("validateMetronConnectionIfNeeded returns null when unauthenticated", () async {
      final coordinator = container.read(sessionCoordinatorProvider);
      final result = await coordinator.validateMetronConnectionIfNeeded();
      expect(result, isNull);
    });

    test("syncMetronIfNeeded returns false when not authenticated", () async {
      final coordinator = container.read(sessionCoordinatorProvider);
      final result = await coordinator.syncMetronIfNeeded();
      expect(result, isFalse);
    });

    test("onAuthStatusChanged transitions state appropriately", () {
      final coordinator = container.read(sessionCoordinatorProvider);
      coordinator.onAuthStatusChanged(AuthStatus.unauthenticated, AuthStatus.authenticated);
      expect(coordinator.state, equals(SessionState.validating));

      coordinator.onAuthStatusChanged(AuthStatus.authenticated, AuthStatus.unauthenticated);
      expect(coordinator.state, equals(SessionState.unauthenticated));
    });
  });
}
