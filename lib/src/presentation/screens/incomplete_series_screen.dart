import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/missing_series_provider.dart';
import 'package:takion/src/presentation/widgets/async_state_panel.dart';
import 'package:takion/src/presentation/widgets/missing_series_list_tile.dart';
import 'package:takion/src/presentation/widgets/paged_list_scaffold.dart';

@RoutePage()
class IncompleteSeriesScreen extends ConsumerStatefulWidget {
  const IncompleteSeriesScreen({super.key});

  @override
  ConsumerState<IncompleteSeriesScreen> createState() =>
      _IncompleteSeriesScreenState();
}

class _IncompleteSeriesScreenState
    extends ConsumerState<IncompleteSeriesScreen> {
  int _page = 1;

  Future<void> _refreshPage() async {
    ref.invalidate(missingSeriesProvider(_page));
    await ref.read(missingSeriesProvider(_page).future);
  }

  @override
  Widget build(BuildContext context) {
    final pageAsync = ref.watch(missingSeriesProvider(_page));

    return Scaffold(
      appBar: AppBar(title: const Text('Incomplete Series')),
      body: pageAsync.when(
        loading: () => const AsyncStatePanel.loading(),
        error: (error, _) => AsyncStatePanel.error(
          errorMessage: 'Failed to load incomplete series: $error',
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
              final series = pageData.results[index];
              return MissingSeriesListTile(
                series: series,
                isFirst: index == 0,
                isLast: index == pageData.results.length - 1,
              );
            },
            emptyMessage: 'No incomplete series found.',
          );
        },
      ),
    );
  }
}
