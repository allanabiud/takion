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

  testWidgets('reset icon does not shift stars and does not overlap', (
    tester,
  ) async {
    await tester.pumpWidget(build(rating: 0));
    final firstStarBefore = tester.getCenter(
      find.byIcon(Icons.star_border).first,
    );
    final lastStarBefore = tester.getCenter(find.byIcon(Icons.star_border).last);
    final starsBefore = tester.getSize(find.byType(RatingPicker));

    await tester.pumpWidget(build(rating: 3));
    await tester.pump();

    final firstStarAfter = tester.getCenter(find.byIcon(Icons.star).first);
    expect(firstStarAfter, firstStarBefore);
    expect(tester.getSize(find.byType(RatingPicker)), starsBefore);

    expect(find.byIcon(Icons.do_not_disturb_on_outlined), findsOneWidget);
    final resetCenter = tester.getCenter(
      find.byIcon(Icons.do_not_disturb_on_outlined),
    );
    expect(resetCenter.dx, lessThan(firstStarBefore.dx));
    expect(resetCenter.dx, lessThan(lastStarBefore.dx));
  });

  testWidgets('reset icon overlaps star at small iconSize when rating set',
      (tester) async {
    await tester.pumpWidget(build(rating: 3, iconSize: 18));
    await tester.pump();

    final lastStar = tester.getCenter(find.byIcon(Icons.star_border).last);
    final reset = tester.getCenter(
      find.byIcon(Icons.do_not_disturb_on_outlined),
    );
    expect(reset.dx, lessThan(lastStar.dx));
  });

  testWidgets('reset icon triggers onReset when pressed', (tester) async {
    var resetCount = 0;
    await tester.pumpWidget(
      build(rating: 3, onReset: () => resetCount++),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.do_not_disturb_on_outlined));
    expect(resetCount, 1);
  });
}
