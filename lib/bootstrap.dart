import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:takion/src/core/cache/cache_header_store.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/logging/talker_setup.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart' hide ReadingList;
import 'package:takion/src/core/network/dio_client.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:takion/src/core/sync/periodic_sync_manager.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  tz.initializeTimeZones();
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  } catch (e) {
    AppLogger.warning(
      'Failed to initialize local timezone, falling back to UTC',
      error: e,
    );
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
  await NotificationService.instance.init();
  await PeriodicSyncManager.instance.init();

  final db = AppDatabase();
  final cacheHeaderStore = CacheHeaderStore();
  await cacheHeaderStore.init(db);

  runApp(
    ProviderScope(
      overrides: [
        driftDatabaseProvider.overrideWithValue(db),
        cacheHeaderStoreProvider.overrideWithValue(cacheHeaderStore),
      ],
      child: await builder(),
    ),
  );
}
