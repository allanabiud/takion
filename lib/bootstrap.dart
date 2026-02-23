import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/models/issue_details_dto.dart';
import 'package:takion/src/data/models/series_dto.dart';

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

  // Pre-open essential boxes in parallel to avoid blocking the main thread
  await Future.wait([
    hiveService.openBox('settings_box'),
    hiveService.openBox<String>('auth_box'),
    hiveService.openBox<List>('weekly_releases_box'),
    hiveService.openBox<List>('issue_search_box'),
    hiveService.openBox<int>('cache_meta_box'),
    hiveService.openBox<IssueDetailsDto>('issue_details_box'),
    hiveService.openBox<SeriesDto>('series_details_box'),
  ]);

  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: await builder(),
    ),
  );
}
