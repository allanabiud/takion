import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/presentation/shared/widgets/animated_counter_text.dart";

void main() {
  group("AnimatedCounterText", () {
    testWidgets("renders initial numeric value correctly", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedCounterText(value: 42))),
      );

      expect(find.text("42"), findsOneWidget);
    });

    testWidgets("renders initial formatted string value correctly", (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCounterText(text: r"$125.50")),
        ),
      );

      expect(find.text("\$125.50"), findsOneWidget);
    });

    testWidgets("animates between values over duration", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounterText(
              value: 10,
              duration: Duration(milliseconds: 400),
            ),
          ),
        ),
      );

      expect(find.text("10"), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounterText(
              value: 100,
              duration: Duration(milliseconds: 400),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      final animatedText = tester.widget<Text>(find.byType(Text));
      final halfwayVal = int.tryParse(animatedText.data ?? "");
      expect(halfwayVal, isNotNull);
      expect(halfwayVal! > 10 && halfwayVal < 100, isTrue);

      await tester.pumpAndSettle();
      expect(find.text("100"), findsOneWidget);
    });
  });
}
