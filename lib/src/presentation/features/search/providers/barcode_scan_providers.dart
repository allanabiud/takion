import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";

class ScannedIssueState {
  final int issueId;
  final IssueList issue;

  const ScannedIssueState({required this.issueId, required this.issue});
}

class ScannedIssuesNotifier extends Notifier<List<ScannedIssueState>> {
  @override
  List<ScannedIssueState> build() => [];

  void addIssue(IssueList issue) {
    if (issue.id == null) return;
    final exists = state.any((s) => s.issueId == issue.id);
    if (exists) return;
    state = [...state, ScannedIssueState(issueId: issue.id!, issue: issue)];
  }

  void removeIssue(int issueId) {
    state = state.where((s) => s.issueId != issueId).toList();
  }

  void clearAll() {
    state = [];
  }

  List<int> get issueIds => state.map((s) => s.issueId).toList();
}

final scannedIssueIdsProvider =
    NotifierProvider<ScannedIssuesNotifier, List<ScannedIssueState>>(
      ScannedIssuesNotifier.new,
    );
