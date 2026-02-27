import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/network/supabase_service.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/repositories/catalog_sync_helper.dart';
import 'package:takion/src/data/repositories/metron_repository_impl.dart';
import 'package:takion/src/data/repositories/supabase_library_repository.dart';
import 'package:takion/src/data/repositories/supabase_pull_list_repository.dart';
import 'package:takion/src/data/repositories/supabase_subscription_repository.dart';
import 'package:takion/src/domain/repositories/catalog_repository.dart';
import 'package:takion/src/domain/repositories/library_repository.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';
import 'package:takion/src/domain/repositories/pull_list_repository.dart';
import 'package:takion/src/domain/repositories/subscription_repository.dart';

final metronRemoteDataSourceProvider = Provider<MetronRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronRemoteDataSourceImpl(dio);
});

final metronLocalDataSourceProvider = Provider<MetronLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return MetronLocalDataSourceImpl(hiveService);
});

final metronRepositoryProvider = Provider<MetronRepository>((ref) {
  final remoteDataSource = ref.watch(metronRemoteDataSourceProvider);
  final localDataSource = ref.watch(metronLocalDataSourceProvider);
  return MetronRepositoryImpl(remoteDataSource, localDataSource);
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return ref.watch(metronRepositoryProvider);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseLibraryRepository(client);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSubscriptionRepository(client);
});

final pullListRepositoryProvider = Provider<PullListRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePullListRepository(client);
});

final catalogSyncHelperProvider = Provider<CatalogSyncHelper>((ref) {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  final releaseService = ref.watch(supabaseCatalogReleaseServiceProvider);
  return CatalogSyncHelper(catalogRepository, releaseService);
});
