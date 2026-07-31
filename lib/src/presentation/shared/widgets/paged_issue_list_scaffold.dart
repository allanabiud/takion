import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/shared/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

class PagedIssueListScaffold extends StatelessWidget {
  const PagedIssueListScaffold({
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

  final String title;
  final AsyncValue<List<IssueList>> issuesAsync;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<IssueList> Function(List<IssueList>) transformIssues;
  final String Function(Object error)? errorTextBuilder;
  final List<Widget>? appBarActions;
  final Widget? header;

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
                errorMessage:
                    errorTextBuilder?.call(error) ?? 'Something went wrong',
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

                if (header != null) {
                  return _PinnedIssueList(
                    header: header!,
                    issues: visibleIssues,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
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

class _PinnedIssueList extends StatelessWidget {
  const _PinnedIssueList({required this.header, required this.issues});

  final Widget header;
  final List<IssueList> issues;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        PinnedListHeader(child: header),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final issue = issues[index];
            return IssueListTile(
              issue: issue,
              isFirst: index == 0,
              isLast: index == issues.length - 1,
            );
          }, childCount: issues.length),
        ),
      ],
    );
  }
}
