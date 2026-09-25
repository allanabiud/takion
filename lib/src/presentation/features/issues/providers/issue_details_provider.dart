import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";

/// Full response, since normalized tables drop fields like variants and reprints.
final issueDetailsProvider = FutureProvider.autoDispose
    .family<IssueDetails, int>((ref, id) async {
      return ref
          .watch(catalogRepositoryProvider)
          .getIssueDetails(id, forceRefresh: false);
    });
