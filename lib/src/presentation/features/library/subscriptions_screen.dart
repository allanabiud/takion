import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/series/providers/subscription_cards_hydrater.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/domain/common/content_sorting.dart";
import "package:takion/src/presentation/shared/widgets/async_state_panel.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/series/series_subscription_card.dart";

@RoutePage()
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  int _page = 1;
  SeriesListPage? _lastPage;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshPage() async {
    ref.invalidate(subscribedSeriesPageProvider(_page));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final page = ref.read(subscribedSeriesPageProvider(_page)).value;
      if (page == null) return;
      final hydrater = ref.read(subscriptionCardsHydraterProvider);
      unawaited(
        hydrater.hydrate(page.results.map((s) => s.id).toList(growable: false)),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOption = ref.watch(
      sortPreferenceForContextProvider(SortPreferenceContext.subscriptions),
    );
    final pageAsync = ref.watch(subscribedSeriesPageProvider(_page));
    final query = _searchController.text.toLowerCase().trim();

    ref.listen(subscribedSeriesPageProvider(_page), (previous, next) {
      final page = next.value;
      if (page == null) return;
      final seriesIds = page.results.map((s) => s.id).toList(growable: false);
      final hydrater = ref.read(subscriptionCardsHydraterProvider);
      unawaited(hydrater.hydrate(seriesIds));
    });

    if (pageAsync.hasValue) {
      _lastPage = pageAsync.value;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search series...",
                  border: InputBorder.none,
                  isDense: true,
                  filled: false,
                  suffixIcon: IconButton(
                    tooltip: "Close search",
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              )
            : const Text("Subscriptions"),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  tooltip: "Search",
                  onPressed: () => setState(() => _isSearching = true),
                  icon: const Icon(Icons.search),
                ),
              ],
      ),
      body: pageAsync.when(
        loading: () {
          if (_lastPage != null) {
            return _buildContent(_lastPage!, sortOption, isLoading: true);
          }
          return _buildSkeletonList();
        },
        error: (error, _) => const AsyncStatePanel.error(
          errorMessage: "Failed to load subscriptions",
        ),
        data: (pageData) {
          final filtered = _filteredPage(pageData, query);
          return _buildContent(filtered, sortOption, isLoading: false);
        },
      ),
    );
  }

  SeriesListPage _filteredPage(SeriesListPage page, String query) {
    if (query.isEmpty) return page;
    final filteredResults = page.results
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
    return SeriesListPage(
      count: filteredResults.length,
      next: null,
      previous: page.previous,
      results: filteredResults,
      currentPage: _page,
    );
  }

  Widget _buildSkeletonList() {
    return const ShimmerWidget(child: _SubscriptionSkeletonContent());
  }

  Widget _buildContent(
    SeriesListPage pageData,
    ContentSortOption sortOption, {
    required bool isLoading,
  }) {
    final totalPages = (pageData.count / metronDefaultPageSize).ceil().clamp(
      1,
      9999,
    );
    final sortedResults = sortSeries(pageData.results, sortOption);

    return PagedListScaffold(
      onRefresh: _refreshPage,
      currentPage: _page,
      totalPages: totalPages,
      hasPrevious: pageData.hasPrevious,
      hasNext: pageData.hasNext,
      isLoading: isLoading,
      header: ListHeader(
        count: sortedResults.length,
        unit: "series",
        pluralUnit: "series",
        enabled: !isLoading,
        sortLabel: contentSortLabel(sortOption),
        onSortTap: () => showSortBottomSheet(
          context,
          ref,
          SortPreferenceContext.subscriptions,
          contentSortLabel,
        ),
      ),
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
      gridCrossAxisCount: 2,
      gridChildAspectRatio: 0.95,
      bottomSpacing: 36,
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final series = sortedResults[index];
        return Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: SeriesSubscriptionCard(
            key: ValueKey(series.id),
            series: series,
          ),
        );
      },
      emptyMessage: "No subscriptions.",
      emptyIcon: Icons.notifications_outlined,
    );
  }
}

class _SubscriptionSkeletonContent extends StatelessWidget {
  const _SubscriptionSkeletonContent();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: const Stack(
            fit: StackFit.expand,
            children: [
              SkeletonBox(borderRadius: 14),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: SkeletonBox(
                  height: 14,
                  width: double.infinity,
                  borderRadius: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
