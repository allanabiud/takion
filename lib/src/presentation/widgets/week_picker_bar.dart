import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';

class WeekPickerBar extends ConsumerWidget {
  const WeekPickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekProvider);
    
    // Calculate start of week (Sunday)
    final offset = selectedDate.weekday % 7;
    final startOfWeek = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).subtract(Duration(days: offset));
    
    // Calculate New Comic Book Day (Wednesday = Sunday + 3 days)
    final wednesday = startOfWeek.add(const Duration(days: 3));
    final dateString = DateFormat('MMM dd, yyyy').format(wednesday);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedWeekProvider.notifier).previousWeek(),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Week of $dateString',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
