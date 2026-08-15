import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/app.dart";

void main() {
  testWidgets("TakionApp can be rendered", (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TakionApp()));
    expect(find.byType(TakionApp), findsOneWidget);
  });
}
