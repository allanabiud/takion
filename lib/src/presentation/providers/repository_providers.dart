import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/repositories/local_library_repository.dart';
import 'package:takion/src/data/repositories/local_pull_list_repository.dart';
import 'package:takion/src/data/repositories/local_subscription_repository.dart';
import 'package:takion/src/data/repositories/metron_repository_impl.dart';
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
  final hiveService = ref.watch(hiveServiceProvider);
  return LocalLibraryRepository(hiveService);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return LocalSubscriptionRepository(hiveService);
});

final pullListRepositoryProvider = Provider<PullListRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return LocalPullListRepository(hiveService);
});
