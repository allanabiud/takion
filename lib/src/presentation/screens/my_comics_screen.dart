import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/collection_issue_list_tile.dart';
import 'package:takion/src/presentation/widgets/paged_list_scaffold.dart';

@RoutePage()
class MyComicsScreen extends ConsumerStatefulWidget {
  const MyComicsScreen({super.key});

  @override
  ConsumerState<MyComicsScreen> createState() => _MyComicsScreenState();
}

class _MyComicsScreenState extends ConsumerState<MyComicsScreen> {
  int _page = 1;

  Future<void> _refreshPage() async {
    ref.invalidate(collectionItemsProvider(_page));
    await ref.read(collectionItemsProvider(_page).future);
  }

  @override
  Widget build(BuildContext context) {
    final pageAsync = ref.watch(collectionItemsProvider(_page));

    return Scaffold(
      appBar: AppBar(title: const Text('My Comics')),
      body: pageAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load comics: $error',
        ),
        data: (pageData) {
          final pageSize = pageData.results.isEmpty ? 100 : pageData.results.length;
          final totalPages = (pageData.count / pageSize).ceil().clamp(1, 9999);
          return PagedListScaffold(
            onRefresh: _refreshPage,
            currentPage: _page,
            totalPages: totalPages,
            hasPrevious: pageData.hasPrevious,
            hasNext: pageData.hasNext,
            onPrevious: () {
              final previousPage = pageData.previousPage;
              if (previousPage == null) return;
              setState(() {
                _page = previousPage;
              });
            },
            onNext: () {
              final nextPage = pageData.nextPage;
              if (nextPage == null) return;
              setState(() {
                _page = nextPage;
              });
            },
            itemCount: pageData.results.length,
            itemBuilder: (context, index) {
              final item = pageData.results[index];
              return CollectionIssueListTile(
                item: item,
                isFirst: index == 0,
                isLast: index == pageData.results.length - 1,
              );
            },
            emptyMessage: 'No comics in your collection yet.',
          );
        },
      ),
    );
  }
}
