import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/team_details.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final teamDetailsProvider =
    FutureProvider.family<TeamDetails, int>((ref, id) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getTeamDetails(id);
});
