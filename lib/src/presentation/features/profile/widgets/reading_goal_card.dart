import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/settings/providers/reading_goal_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/components/components.dart';

class ReadingGoalCard extends ConsumerWidget {
  final ProfileFilter filter;

  const ReadingGoalCard({super.key, this.filter = ProfileFilter.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(readingGoalProvider);
    final insightsAsync = ref.watch(profileInsightsProvider(filter));

    return goalAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (goal) {
        if (goal == null) return const SizedBox.shrink();

        return insightsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (insights) {
            final progress = insights.readsInPeriod;
            final target = goal.target;
            final percent = target > 0
                ? (progress / target).clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Reading Goal',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 12,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$progress / $target issues (${goal.period})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Goal'),
                          onPressed: () => _showEditGoalSheet(context, ref, goal),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Clear'),
                          onPressed: () async {
                            await ref.read(readingGoalProvider.notifier).clearGoal();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditGoalSheet(BuildContext context, WidgetRef ref, ReadingGoal current) {
    var target = current.target;
    var period = current.period;

    TakionBottomSheet.show<void>(
      context: context,
      title: 'Set Reading Goal',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Target (issues)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: target.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      target = parsed;
                    }
                  },
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'monthly', label: Text('Monthly')),
                    ButtonSegment(value: 'yearly', label: Text('Yearly')),
                  ],
                  selected: {period},
                  onSelectionChanged: (selected) {
                    setModalState(() => period = selected.first);
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(readingGoalProvider.notifier)
                          .setGoal(ReadingGoal(target: target, period: period));
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
