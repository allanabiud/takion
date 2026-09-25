import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/presentation/shared/widgets/status_indicator_icons.dart";

void main() {
  group("StatusIndicatorIcons", () {
    testWidgets("renders active status icons for collected and read", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicatorIcons(
              isCollected: true,
              isRead: true,
              isPulled: false,
              isWishlisted: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.turned_in_not), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
      expect(find.byIcon(Icons.sync_problem_outlined), findsNothing);
    });

    testWidgets("renders active status icons for pulled and wishlisted", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicatorIcons(
              isCollected: false,
              isRead: false,
              isPulled: true,
              isWishlisted: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_added_outlined), findsOneWidget);
      expect(find.byIcon(Icons.turned_in), findsOneWidget);
    });

    testWidgets("renders tooltips for all status icons", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicatorIcons(
              isCollected: true,
              isRead: true,
              isPulled: true,
              isWishlisted: true,
            ),
          ),
        ),
      );

      expect(find.byTooltip("Pulled"), findsOneWidget);
      expect(find.byTooltip("In collection"), findsOneWidget);
      expect(find.byTooltip("Read"), findsOneWidget);
      expect(find.byTooltip("Wishlisted"), findsOneWidget);
    });
  });
}
