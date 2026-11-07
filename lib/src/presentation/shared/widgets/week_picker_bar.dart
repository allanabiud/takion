import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Week of $dateString",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.chevron_left),
                tooltip: "Previous week",
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(selectedWeekProvider.notifier).previousWeek();
                },
              ),
              IconButton(
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: "Choose date",
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    HapticFeedback.lightImpact();
                    ref.read(selectedWeekProvider.notifier).setDate(picked);
                  }
                },
              ),
              IconButton(
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.chevron_right),
                tooltip: "Next week",
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(selectedWeekProvider.notifier).nextWeek();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
