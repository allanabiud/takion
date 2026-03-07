import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/week_picker_bar.dart';

class WeeklyIssueListScaffold extends StatelessWidget {
  final String title;
  final AsyncValue<List<IssueList>> issuesAsync;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<IssueList> Function(List<IssueList>) transformIssues;
  final String Function(Object error)? errorTextBuilder;
  final List<Widget>? appBarActions;

  const WeeklyIssueListScaffold({
    super.key,
    required this.title,
    required this.issuesAsync,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.transformIssues = _identity,
    this.errorTextBuilder,
    this.appBarActions,
  });

  static List<IssueList> _identity(List<IssueList> issues) => issues;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarActions,
        bottom: issuesAsync.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Column(
        children: [
          const WeekPickerBar(),
          Expanded(
            child: issuesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => AsyncStatePanel.error(
                errorMessage: errorTextBuilder?.call(error) ?? 'Error: $error',
              ),
              data: (issues) {
                final visibleIssues = transformIssues(issues);
                if (visibleIssues.isEmpty) {
                  return EmptyContentState(
                    icon: emptyIcon,
                    message: emptyMessage,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: visibleIssues.length,
                  itemBuilder: (context, index) {
                    final issue = visibleIssues[index];
                    return IssueListTile(
                      issue: issue,
                      isFirst: index == 0,
                      isLast: index == visibleIssues.length - 1,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
