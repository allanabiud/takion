import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takion/src/presentation/shared/widgets/rating_picker.dart';

void main() {
  Widget build({required int rating, double iconSize = 28}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: RatingPicker(
            selectedRating: rating,
            enabled: true,
            onChanged: (_) {},
            onReset: () {},
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
    final firstStarBefore = tester.getCenter(find.byType(IconButton).first);
    final lastStarBefore = tester.getCenter(find.byType(IconButton).last);
    final starsBefore = tester.getSize(find.byType(RatingPicker));

    await tester.pumpWidget(build(rating: 3));
    await tester.pump();

    final firstStarAfter = tester.getCenter(find.byType(IconButton).first);
    expect(firstStarAfter, firstStarBefore);
    expect(tester.getSize(find.byType(RatingPicker)), starsBefore);

    expect(find.byIcon(Icons.do_not_disturb_on_outlined), findsOneWidget);
    final resetCenter = tester.getCenter(
      find.byIcon(Icons.do_not_disturb_on_outlined),
    );
    expect(resetCenter.dx, greaterThan(lastStarBefore.dx));
  });

  testWidgets('reset icon overlaps star at small iconSize when rating set',
      (tester) async {
    await tester.pumpWidget(build(rating: 3, iconSize: 18));
    await tester.pump();

    final lastStar = tester.getCenter(find.byType(IconButton).at(4));
    final reset = tester.getCenter(
      find.byIcon(Icons.do_not_disturb_on_outlined),
    );
    expect(reset.dx, greaterThan(lastStar.dx));
  });
}
