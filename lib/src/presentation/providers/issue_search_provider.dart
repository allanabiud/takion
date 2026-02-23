import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final issueSearchResultsProvider =
    FutureProvider.autoDispose.family<List<IssueList>, String>((ref, query) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.searchIssues(query);
    });
