import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/library/providers/daily_read_activity_provider.dart';

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

        final cellSize = 12.0;
        final cellGap = 3.0;
        final step = cellSize + cellGap;
        final monthLabelHeight = 14.0;
        final gridHeight = 7 * step;
        final totalHeight = monthLabelHeight + 2 + gridHeight;

        // Build weeks data
        final weeks = <List<_DayData>>[];
        final monthLabels = <String>[];
        var maxCount = 0;

        for (var w = 51; w >= 0; w--) {
          final week = <_DayData>[];
          for (var d = 6; d >= 0; d--) {
            final dayDate = today.subtract(Duration(days: w * 7 + d));
            final count = activity[dayDate] ?? 0;
            if (count > maxCount) maxCount = count;
            week.add(
              _DayData(date: dayDate, count: count, isToday: dayDate == today),
            );
          }
          weeks.add(week);

          if (w == 51 || weeks.length == 1) {
            monthLabels.add(_monthAbbr(week[6].date.month));
          } else {
            final prevMonth = weeks[weeks.length - 2][6].date.month;
            final thisMonth = week[6].date.month;
            monthLabels.add(
              thisMonth != prevMonth ? _monthAbbr(thisMonth) : '',
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reading Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentStreak(activity, today)} day streak',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: totalHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Column(
                        children: [
                          SizedBox(height: monthLabelHeight + 2),
                          ...List.generate(7, (i) {
                            final labels = [
                              'Mon',
                              '',
                              'Wed',
                              '',
                              'Fri',
                              '',
                              '',
                            ];
                            return SizedBox(
                              height: step,
                              child: Center(
                                child: Text(
                                  labels[i],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: monthLabelHeight,
                                child: Row(
                                  children: List.generate(52, (w) {
                                    return SizedBox(
                                      width: step,
                                      child: Text(
                                        monthLabels[w],
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontSize: 8,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 2),
                              ...List.generate(7, (row) {
                                return SizedBox(
                                  height: step,
                                  child: Row(
                                    children: List.generate(52, (col) {
                                      final data = weeks[col][row];
                                      final cellColor = maxCount > 0
                                          ? _intensityColor(
                                              theme,
                                              (data.count / maxCount).clamp(
                                                0.0,
                                                1.0,
                                              ),
                                            )
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.4);
                                      return _StreakCell(
                                        size: cellSize,
                                        gap: cellGap,
                                        color: cellColor,
                                        isToday: data.isToday,
                                        theme: theme,
                                      );
                                    }),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _legendCell(theme, 0.0),
                  _legendCell(theme, 0.33),
                  _legendCell(theme, 0.66),
                  _legendCell(theme, 1.0),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  int _currentStreak(Map<DateTime, int> activity, DateTime today) {
    var streak = 0;
    var date = today;
    while (true) {
      if ((activity[date] ?? 0) > 0) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Widget _legendCell(ThemeData theme, double intensity) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: _intensityColor(theme, intensity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _intensityColor(ThemeData theme, double intensity) {
    if (intensity <= 0) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    }
    if (theme.brightness == Brightness.dark) {
      return Color.lerp(
        theme.colorScheme.primary.withValues(alpha: 0.3),
        theme.colorScheme.primary,
        intensity,
      )!;
    }
    return Color.lerp(
      theme.colorScheme.primary.withValues(alpha: 0.2),
      theme.colorScheme.primary,
      intensity,
    )!;
  }
}

class _DayData {
  final DateTime date;
  final int count;
  final bool isToday;
  const _DayData({
    required this.date,
    required this.count,
    required this.isToday,
  });
}

class _StreakCell extends StatelessWidget {
  final double size;
  final double gap;
  final Color color;
  final bool isToday;
  final ThemeData theme;

  const _StreakCell({
    required this.size,
    required this.gap,
    required this.color,
    required this.isToday,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + gap,
      height: size + gap,
      alignment: Alignment.topLeft,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
      ),
    );
  }
}
