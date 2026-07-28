import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart';

final collectionIssueStatusMapProvider = collectionStatusCacheProvider;

final issueCollectionStatusProvider =
    Provider.family<IssueCollectionStatus?, int>((ref, issueId) {
      if (issueId <= 0) return null;
      final cache = ref.watch(collectionStatusCacheProvider);
      return cache.maybeWhen(data: (map) => map[issueId], orElse: () => null);
    });
