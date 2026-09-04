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

    testWidgets("renders cloud_upload icon when syncStatus is pending", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicatorIcons(
              isCollected: true,
              isRead: false,
              isPulled: false,
              isWishlisted: false,
              syncStatus: "pending",
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem_outlined), findsNothing);
    });

    testWidgets("renders sync_problem icon when syncStatus is failed", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicatorIcons(
              isCollected: false,
              isRead: false,
              isPulled: false,
              isWishlisted: true,
              syncStatus: "failed",
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync_problem_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
    });
  });
}
