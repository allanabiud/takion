import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

/// Full response, since normalized tables drop fields like variants and reprints.
final issueDetailsProvider = FutureProvider.autoDispose
    .family<IssueDetails, int>((ref, id) async {
      final issue = await ref
          .watch(catalogRepositoryProvider)
          .getIssueDetails(id, forceRefresh: false);
      if (issue.image != null && issue.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set("issue", id, issue.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }
      return issue;
    });
