import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart" show DateFormat;
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/features/library/providers/daily_read_activity_provider.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class StreakCalendarWidget extends ConsumerStatefulWidget {
  const StreakCalendarWidget({super.key});

  @override
  ConsumerState<StreakCalendarWidget> createState() =>
      _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends ConsumerState<StreakCalendarWidget> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth(DateTime earliestMonth) {
    if (_visibleMonth.isBefore(earliestMonth) ||
        _visibleMonth.isAtSameMomentAs(earliestMonth)) {
      return;
    }
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth(DateTime currentMonth) {
    if (_visibleMonth.isAfter(currentMonth) ||
        _visibleMonth.isAtSameMomentAs(currentMonth)) {
      return;
    }
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(dailyReadActivityProvider);
    final theme = Theme.of(context);

    return activityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (activity) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final currentMonth = DateTime(now.year, now.month);
        final earliestMonth = DateTime(now.year - 1, now.month);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SectionHeader(title: "READING ACTIVITY"),
              const SizedBox(height: 12),
              _buildHeader(theme, currentMonth, earliestMonth),
              const SizedBox(height: 8),
              _buildWeekdayLabels(theme),
              const SizedBox(height: 6),
              _buildGrid(theme, activity, today),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    DateTime currentMonth,
    DateTime earliestMonth,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final canGoBack = _visibleMonth.isAfter(earliestMonth);
    final canGoForward = _visibleMonth.isBefore(currentMonth);

    return Row(
      children: [
        IconButton(
          tooltip: "Previous month",
          onPressed: canGoBack ? () => _goToPreviousMonth(earliestMonth) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat.MMMM(languageCode).format(_visibleMonth),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat.y(languageCode).format(_visibleMonth),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: "Next month",
          onPressed: canGoForward ? () => _goToNextMonth(currentMonth) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(ThemeData theme) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return Row(
      children: List.generate(7, (index) {
        final day = DateFormat.E(
          languageCode,
        ).format(DateTime(2021, 1, 3 + index));
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGrid(
    ThemeData theme,
    Map<DateTime, int> activity,
    DateTime today,
  ) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstDay.weekday % 7;
    final totalCells = ((leadingEmpty + daysInMonth + 6) ~/ 7) * 7;
    final firstGridDay = firstDay.subtract(Duration(days: leadingEmpty));

    return Column(
      children: [
        for (var row = 0; row < totalCells; row += 7)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildCell(
                        theme,
                        DateTime(
                          firstGridDay.year,
                          firstGridDay.month,
                          firstGridDay.day + row + col,
                        ),
                        isInMonth:
                            row + col >= leadingEmpty &&
                            row + col < leadingEmpty + daysInMonth,
                        count:
                            activity[DateTime(
                              firstGridDay.year,
                              firstGridDay.month,
                              firstGridDay.day + row + col,
                            )] ??
                            0,
                        today: today,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
    ThemeData theme,
    DateTime date, {
    required bool isInMonth,
    required int count,
    required DateTime today,
  }) {
    final isToday = date.isAtSameMomentAs(today);
    final isActive = count > 0;
    final radius = BorderRadius.circular(6);

    final Color background;
    final Color foreground;

    if (!isInMonth) {
      background = theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.15,
      );
      foreground = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    } else if (isActive) {
      if (isToday) {
        background = theme.colorScheme.primary.withValues(alpha: 0.55);
      } else {
        background = theme.colorScheme.primary;
      }
      foreground = theme.colorScheme.onPrimary;
    } else {
      background = theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.4,
      );
      foreground = theme.colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: () => _onDayTap(date, count),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          "${date.day}",
          style: theme.textTheme.bodySmall?.copyWith(
            color: foreground,
            fontWeight: isToday
                ? FontWeight.bold
                : (isActive ? FontWeight.w600 : FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _onDayTap(DateTime date, int count) {
    final formatted = DateFormatter.comicDate(date);
    final message = count > 0
        ? '$formatted - $count issue${count == 1 ? '' : 's'} read'
        : "$formatted - No reads";
    TakionAlerts.info(context, message);
  }
}
