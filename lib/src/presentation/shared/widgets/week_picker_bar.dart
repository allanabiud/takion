import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/features/releases/providers/selected_week_provider.dart";

class WeekPickerBar extends ConsumerWidget {
  const WeekPickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);

    // Start of week (Sunday).
    final offset = selectedDate.weekday % 7;
    final startOfWeek = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: offset));

    // New Comic Book Day (Wednesday).
    final wednesday = startOfWeek.add(const Duration(days: 3));
    final dateString = DateFormatter.comicDate(wednesday);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                ref.read(selectedWeekProvider.notifier).previousWeek(),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(selectedWeekProvider.notifier).setDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Week of $dateString",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      () {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final targetWednesday =
                            DateTime(wednesday.year, wednesday.month, wednesday.day);
                        final diff = targetWednesday.difference(today).inDays;

                        final String badgeText;
                        final Color badgeColor;
                        if (diff == 0) {
                          badgeText = "NCBD • Out Today!";
                          badgeColor = Colors.green;
                        } else if (diff > 0) {
                          badgeText = diff == 1
                              ? "NCBD in 1 day"
                              : "NCBD in $diff days";
                          badgeColor = Theme.of(context).colorScheme.primary;
                        } else {
                          final ago = -diff;
                          badgeText = ago == 1 ? "Released yesterday" : "Released $ago days ago";
                          badgeColor = Theme.of(context).colorScheme.outline;
                        }

                        return Text(
                          badgeText,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        );
                      }(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedWeekProvider.notifier).nextWeek(),
          ),
        ],
      ),
    );
  }
}
