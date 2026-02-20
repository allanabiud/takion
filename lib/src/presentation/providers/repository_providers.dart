import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/datasources/metron_local_data_source.dart';
import 'package:takion/src/data/datasources/metron_remote_data_source.dart';
import 'package:takion/src/data/repositories/metron_repository_impl.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';

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
