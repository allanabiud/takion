import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

/// Bootstraps the application by initializing core services and state management.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge mode for transparent system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final hiveService = HiveService();
  await hiveService.init();

  // Pre-open essential boxes
  await hiveService.openBox('settings_box');
  await hiveService.openBox('auth_box');
  await hiveService.openBox<String>('search_history_box');

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: await builder(),
    ),
  );
}
