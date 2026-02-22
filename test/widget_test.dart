// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/app.dart';
import 'package:hive_ce/hive_ce.dart'; // Import Hive
import 'package:takion/hive_registrar.g.dart'; // Import generated adapters
import 'dart:io'; // For Directory

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('TakionApp can be rendered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TakionApp(),
      ),
    );

    // Verify that TakionApp is rendered. We can look for the title or any unique widget.
    expect(find.byType(TakionApp), findsOneWidget);
    // You can add more specific assertions here if needed, for example,
    // to check for specific text or widgets that should be present on app startup.
    // expect(find.text('Takion'), findsOneWidget);
  });
}
