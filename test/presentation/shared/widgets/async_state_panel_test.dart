import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/core/errors/app_failure.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";

void main() {
  group("AsyncStatePanel", () {
    testWidgets("renders loading state with message", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AsyncStatePanel.loading(message: "Loading issues..."),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("Loading issues..."), findsOneWidget);
    });

    testWidgets("renders NetworkFailure correctly", (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStatePanel.fromFailure(
              failure: const NetworkFailure("timeout"),
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text("No Connection"), findsOneWidget);
      expect(
        find.text("Network connection issue. Please check your internet connection."),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);

      await tester.tap(find.text("Retry"));
      expect(retryCalled, isTrue);
    });

    testWidgets("renders AuthFailure correctly", (tester) async {
      var loginCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStatePanel.fromFailure(
              failure: const AuthFailure(isExpired: true),
              onAction: () => loginCalled = true,
            ),
          ),
        ),
      );

      expect(find.text("Session Expired"), findsOneWidget);
      expect(find.text("Log In"), findsOneWidget);
      await tester.tap(find.text("Log In"));
      expect(loginCalled, isTrue);
    });

    testWidgets("renders ServerFailure correctly", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStatePanel.fromFailure(
              failure: const ServerFailure(503),
            ),
          ),
        ),
      );

      expect(find.text("Server Error (503)"), findsOneWidget);
      expect(find.text("Server error (503). Please try again later."), findsOneWidget);
    });
  });
}
