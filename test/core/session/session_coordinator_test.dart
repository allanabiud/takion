import "package:drift/drift.dart" show driftRuntimeOptions;
import "package:drift/native.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/core/session/session_coordinator.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";

class MockMetronAccountService extends Mock implements MetronAccountService {}
class MockSubscriptionPullReconciler extends Mock implements SubscriptionPullReconciler {}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;
  late MockMetronAccountService mockMetronService;
  late MockSubscriptionPullReconciler mockReconciler;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockMetronService = MockMetronAccountService();
    mockReconciler = MockSubscriptionPullReconciler();

    container = ProviderContainer(
      overrides: [
        driftDatabaseProvider.overrideWithValue(db),
        metronAccountServiceProvider.overrideWithValue(mockMetronService),
        subscriptionPullReconcilerProvider.overrideWithValue(mockReconciler),
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

    test("reconcileSubscriptionPulls returns false when not authenticated", () async {
      final coordinator = container.read(sessionCoordinatorProvider);
      final result = await coordinator.reconcileSubscriptionPulls();
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
