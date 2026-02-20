import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'issues_provider.g.dart';

@riverpod
Future<List<Issue>> weeklyReleases(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getWeeklyReleases();
}
