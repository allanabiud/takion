import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heatmap_calendar_plus/heatmap_calendar_plus.dart';
import 'package:takion/src/presentation/features/library/providers/daily_read_activity_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

class StreakCalendarWidget extends ConsumerWidget {
  const StreakCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(dailyReadActivityProvider);
    final theme = Theme.of(context);

    return activityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (activity) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SectionHeader(title: 'READING ACTIVITY'),
              const SizedBox(height: 12),
              HeatMap(
                datasets: activity,
                startDate: today.subtract(const Duration(days: 364)),
                endDate: today,
                colorMode: ColorMode.opacity,
                colorsets: {1: theme.colorScheme.primary},
                scrollable: true,
                showText: false,
                showColorTip: false,
                size: 12,
                blockSpacing: 3,
                weekStartsWith: 1,
                reversed: true,
                defaultColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                monthTextStyle: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                ),
                weekTextStyle: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                ),
                onClick: (date) {
                  final count = activity[date] ?? 0;
                  final formatted = '${date.month}/${date.day}/${date.year}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$formatted: $count issue${count == 1 ? '' : 's'} read',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
