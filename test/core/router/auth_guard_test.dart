import "package:auto_route/auto_route.dart";
import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/core/router/auth_guard.dart";

class MockNavigationResolver extends Mock implements NavigationResolver {}

class MockStackRouter extends Mock implements StackRouter {}

class TestAuthState extends AuthState {
  final Future<AuthStatus> Function() _onBuild;
  TestAuthState(this._onBuild);

  @override
  Future<AuthStatus> build() => _onBuild();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthorizeMetronRoute());
    registerFallbackValue(<PageRouteInfo>[]);
  });

  group("AuthGuard Characterization Tests", () {
    late MockNavigationResolver resolver;
    late MockStackRouter router;

    setUp(() {
      resolver = MockNavigationResolver();
      router = MockStackRouter();
      when(() => router.replaceAll(any())).thenAnswer((_) async => []);
      when(() => resolver.next(any())).thenReturn(null);
    });

    testWidgets("allows navigation when authState is authenticated", (
      tester,
    ) async {
      late AuthGuard guard;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              () => TestAuthState(() async => AuthStatus.authenticated),
            ),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              guard = AuthGuard(ref);
              return const SizedBox();
            },
          ),
        ),
      );

      guard.onNavigation(resolver, router);
      await tester.pumpAndSettle();

      verify(() => resolver.next(true)).called(1);
      verifyNever(() => router.replaceAll(any()));
    });

    testWidgets(
      "redirects to AuthorizeMetronRoute when authState is unauthenticated",
      (tester) async {
        late AuthGuard guard;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => TestAuthState(() async => AuthStatus.unauthenticated),
              ),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                guard = AuthGuard(ref);
                return const SizedBox();
              },
            ),
          ),
        );

        guard.onNavigation(resolver, router);
        await tester.pumpAndSettle();

        verify(() => router.replaceAll(any())).called(1);
        verify(() => resolver.next(false)).called(1);
      },
    );

    testWidgets(
      "redirects to AuthorizeMetronRoute when authState throws error",
      (tester) async {
        late AuthGuard guard;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () =>
                    TestAuthState(() async => throw Exception("storage error")),
              ),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                guard = AuthGuard(ref);
                return const SizedBox();
              },
            ),
          ),
        );

        guard.onNavigation(resolver, router);
        await tester.pumpAndSettle();

        verify(() => router.replaceAll(any())).called(1);
        verify(() => resolver.next(false)).called(1);
      },
    );
  });
}
