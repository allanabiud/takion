import 'package:auto_route/auto_route.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:flutter/material.dart' hide RefreshIndicatorTriggerMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/collection_provider.dart';
import 'package:takion/src/presentation/widgets/action_card.dart';
import 'package:takion/src/presentation/widgets/compact_list_tile.dart';
import 'package:takion/src/presentation/widgets/issue_list_tile.dart';

@RoutePage()
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  String _formatValue(String value) {
    final doubleValue = double.tryParse(value) ?? 0.0;
    if (doubleValue >= 1000) {
      return '\$${(doubleValue / 1000).toStringAsFixed(1)}k';
    }
    return '\$${doubleValue.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(collectionStatsProvider);
    final suggestionAsync = ref.watch(readingSuggestionProvider);

    final isLoading = statsAsync.isLoading || suggestionAsync.isLoading;

    return Scaffold(
      appBar: isLoading
          ? AppBar(
              toolbarHeight: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              ),
            )
          : null,
      body: ExpressiveRefreshIndicator(
        displacement: 80,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () async {
          // ignore: unused_result
          await ref.refresh(collectionStatsProvider.future);
          // ignore: unused_result
          await ref.refresh(readingSuggestionProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    ActionCard(
                      icon: Icons.book_outlined,
                      value: statsAsync.when(
                        data: (stats) => stats.totalItems.toString(),
                        loading: () => '--',
                        error: (_, __) => '!',
                      ),
                      label: 'Comics',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    ActionCard(
                      icon: Icons.check_circle_outline,
                      value: statsAsync.when(
                        data: (stats) => stats.readCount.toString(),
                        loading: () => '--',
                        error: (_, __) => '!',
                      ),
                      label: 'Read',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    ActionCard(
                      icon: Icons.monetization_on_outlined,
                      value: statsAsync.when(
                        data: (stats) => _formatValue(stats.totalValue),
                        loading: () => '--',
                        error: (_, __) => '!',
                      ),
                      label: 'Value',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Lists Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Lists',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              CompactListTile(
                icon: Icons.visibility_off_outlined,
                label: 'Unread',
                value: statsAsync.when(
                  data: (stats) =>
                      (stats.totalItems - stats.readCount).toString(),
                  loading: () => null,
                  error: (_, __) => null,
                ),
                isFirst: true,
                onTap: () {},
              ),
              CompactListTile(
                icon: Icons.format_list_bulleted,
                label: 'Reading Lists',
                onTap: () {},
              ),
              CompactListTile(
                icon: Icons.history,
                label: 'Reading History',
                isLast: true,
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // Reading Suggestion Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Reading Suggestion',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              suggestionAsync.when(
                data: (issue) {
                  if (issue == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('No unread comics to suggest!'),
                    );
                  }
                  return IssueListTile(
                    issue: issue,
                    isFirst: true,
                    isLast: true,
                    onTap: () {
                      // Navigate to details (disabled for now as screen is removed)
                    },
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Could not load suggestion: $err'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
