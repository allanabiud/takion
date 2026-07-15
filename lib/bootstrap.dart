import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/dto/issue_details_dto.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Bootstraps the application by initializing core services and state management.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final hiveService = HiveService();
  await hiveService.init();

  tz.initializeTimeZones();
  try {
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
  await NotificationService.instance.init();

  // Pre-open essential boxes in parallel to avoid blocking the main thread
  await Future.wait([
    hiveService.openBox('settings_box'),
    hiveService.openBox<String>('metron_account_box'),
    hiveService.openBox<List>('weekly_releases_box'),
    hiveService.openBox<List>('issue_search_box'),
    hiveService.openBox<Map>('issue_search_meta_box'),
    hiveService.openBox<List>('series_search_box'),
    hiveService.openBox<Map>('series_search_meta_box'),
    hiveService.openBox<List>('series_list_box'),
    hiveService.openBox<Map>('series_list_meta_box'),
    hiveService.openBox<List>('series_issue_list_box'),
    hiveService.openBox<Map>('series_issue_list_meta_box'),
    hiveService.openBox<Map>('home_content_box'),
    hiveService.openBox<int>('cache_meta_box'),
    hiveService.openBox<IssueDetailsDto>('issue_details_box'),
    hiveService.openBox<Map>('series_details_box'),
    hiveService.openBox<Map>('local_library_items_box'),
    hiveService.openBox<Map>('local_library_read_logs_box'),
    hiveService.openBox<Map>('local_pull_list_box'),
    hiveService.openBox<Map>('local_subscriptions_box'),
    hiveService.openBox<Map>('local_favorite_series_box'),
    hiveService.openBox<Map>('local_favorite_issues_box'),
    hiveService.openBox<Map>('local_favorite_reading_lists_box'),
    hiveService.openBox<Map>('local_favorite_characters_box'),
    hiveService.openBox<Map>('local_favorite_creators_box'),
    hiveService.openBox<ReadingList>('reading_lists_box'),
    hiveService.openBox<String>('series_name_index_box'),
  ]);

  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: await builder(),
    ),
  );
}
