import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/presentation/shared/widgets/rating_picker.dart';

void main() {
  Widget build({
    required int rating,
    double iconSize = 28,
    VoidCallback? onReset,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: RatingPicker(
            selectedRating: rating,
            enabled: true,
            onChanged: (_) {},
            onReset: onReset ?? () {},
            iconSize: iconSize,
          ),
        ),
      ),
    );
  }

  testWidgets('stars are centered when no rating is set', (tester) async {
    await tester.pumpWidget(build(rating: 0, iconSize: 40));

    final picker = tester.getRect(find.byType(RatingPicker));
    final firstStar = tester.getCenter(find.byIcon(Icons.star_border).first);
    final lastStar = tester.getCenter(find.byIcon(Icons.star_border).last);

    final starGroupCenter = (firstStar.dx + lastStar.dx) / 2;
    expect(starGroupCenter, closeTo(picker.center.dx, 0.1));
  });

  testWidgets('reset icon appears to the left of the stars when rated', (
    tester,
  ) async {
    await tester.pumpWidget(build(rating: 3));

    final firstStar = tester.getCenter(find.byIcon(Icons.star).first);
    final reset = tester.getCenter(
      find.byIcon(Icons.do_not_disturb_on_outlined),
    );
    expect(find.byIcon(Icons.do_not_disturb_on_outlined), findsOneWidget);
    expect(reset.dx, lessThan(firstStar.dx));
  });

  testWidgets('stars do not shift when a rating is set', (tester) async {
    await tester.pumpWidget(build(rating: 0, iconSize: 40));
    final centerBefore = tester.getCenter(find.byIcon(Icons.star_border).first);

    await tester.pumpWidget(build(rating: 3, iconSize: 40));
    final centerAfter = tester.getCenter(find.byIcon(Icons.star).first);

    expect(centerAfter.dx, closeTo(centerBefore.dx, 0.1));
  });

  testWidgets('reset icon triggers onReset when pressed', (tester) async {
    var resetCount = 0;
    await tester.pumpWidget(build(rating: 3, onReset: () => resetCount++));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.do_not_disturb_on_outlined));
    expect(resetCount, 1);
  });
}