import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/errors/error_mapper.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/empty_content_state.dart";
import "package:takion/src/presentation/features/issues/issue_list_tile.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class PagedIssueListScaffold extends StatefulWidget {
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
    this.onRefresh,
  });

  final String title;
  final AsyncValue<List<IssueList>> issuesAsync;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<IssueList> Function(List<IssueList>) transformIssues;
  final String Function(Object error)? errorTextBuilder;
  final List<Widget>? appBarActions;
  final Widget? header;
  final Future<void> Function()? onRefresh;

  static List<IssueList> _identity(List<IssueList> issues) => issues;

  @override
  State<PagedIssueListScaffold> createState() => _PagedIssueListScaffoldState();
}

class _PagedIssueListScaffoldState extends State<PagedIssueListScaffold> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.issuesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => AsyncStatePanel.fromFailure(
        failure: ErrorMapper.fromException(error),
      ),
      data: (issues) {
        final visibleIssues = widget.transformIssues(issues);
        if (visibleIssues.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    if (widget.header != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: widget.header,
                      ),
                    Expanded(
                      child: EmptyContentState(
                        icon: widget.emptyIcon,
                        message: widget.emptyMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (widget.header != null) {
          return _PinnedIssueList(
            controller: _scrollController,
            header: widget.header!,
            issues: visibleIssues,
          );
        }

        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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
    );

    if (widget.onRefresh != null) {
      content = RefreshIndicator(onRefresh: widget.onRefresh!, child: content);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.appBarActions,
        bottom: widget.issuesAsync.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      floatingActionButton: ScrollToTopFab(controller: _scrollController),
      body: Column(
        children: [
          const WeekPickerBar(),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _PinnedIssueList extends StatelessWidget {
  const _PinnedIssueList({
    required this.controller,
    required this.header,
    required this.issues,
  });

  final ScrollController controller;
  final Widget header;
  final List<IssueList> issues;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
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
