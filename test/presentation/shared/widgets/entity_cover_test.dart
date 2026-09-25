import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/entity_cover.dart";

void main() {
  group("EntityCover", () {
    testWidgets("renders favorite icon when isFavorite is true", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EntityCover(
              imageUrl: null,
              placeholderLabel: "SM",
              isFavorite: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets("renders cloud_upload icon when syncStatus is pending", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EntityCover(
              imageUrl: null,
              placeholderLabel: "SM",
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
            body: EntityCover(
              imageUrl: null,
              placeholderLabel: "SM",
              syncStatus: "failed",
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync_problem_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
    });

    testWidgets("renders both role badge and syncStatus when both are present", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EntityCover(
              imageUrl: null,
              placeholderLabel: "SM",
              role: ItemRole.prologue,
              syncStatus: "pending",
            ),
          ),
        ),
      );

      expect(find.text("PROLOGUE"), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    });
  });
}
