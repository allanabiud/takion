import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/common/async_state_panel.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/releases/week_picker_bar.dart';

class WeeklyIssueListScaffold extends StatelessWidget {
  final String title;
  final AsyncValue<List<IssueList>> issuesAsync;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<IssueList> Function(List<IssueList>) transformIssues;
  final String Function(Object error)? errorTextBuilder;
  final List<Widget>? appBarActions;
  final Widget? header;

  const WeeklyIssueListScaffold({
    super.key,
    required this.title,
    required this.issuesAsync,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.transformIssues = _identity,
    this.errorTextBuilder,
    this.appBarActions,
    this.header,
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
                  return Column(
                    children: [
                      if (header != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: header,
                        ),
                      Expanded(
                        child: EmptyContentState(
                          icon: emptyIcon,
                          message: emptyMessage,
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: visibleIssues.length + (header != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (header != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: header,
                      );
                    }
                    final issue =
                        visibleIssues[header != null ? index - 1 : index];
                    return IssueListTile(
                      issue: issue,
                      isFirst: header != null ? index == 1 : index == 0,
                      isLast:
                          index ==
                          (visibleIssues.length + (header != null ? 1 : 0) - 1),
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
