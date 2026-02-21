import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';
import 'package:takion/src/domain/entities/issue.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

part 'collection_provider.g.dart';

@riverpod
Future<CollectionStats> collectionStats(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getCollectionStats();
}

@riverpod
Future<Issue?> readingSuggestion(Ref ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  final unreadIssues = await repository.getUnreadIssues();

  if (unreadIssues.isEmpty) return null;

  final random = Random();
  final pickedIssue = unreadIssues[random.nextInt(unreadIssues.length)];

  // Fetch full details to ensure we have the image and other fields
  // which might be missing from the collection list response.
  return repository.getIssueDetails(pickedIssue.id);
}

@riverpod
class CollectionNotifier extends _$CollectionNotifier {
  @override
  Future<Map<int, bool>> build() async {
    // Fetch user collection items to know which issues are owned and their read status
    // For simplicity in this logic, we return a map of issueId -> isRead
    final response = await ref.read(dioProvider).get('collection/');
    final List results = response.data['results'];

    final Map<int, bool> collectionMap = {};
    for (var item in results) {
      final issueId = item['issue']['id'] as int;
      final isRead = item['is_read'] as bool;
      collectionMap[issueId] = isRead;
    }
    return collectionMap;
  }
}
