import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/presentation/features/library/providers/library_insights_provider.dart';

class ReadingTrendChart extends StatelessWidget {
  const ReadingTrendChart({super.key, required this.data});

  final List<ReadingTrendPoint> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.isEmpty) return const SizedBox.shrink();

    final maxCount = data
        .map((e) => e.count)
        .fold(0, (prev, curr) => curr > prev ? curr : prev);
    final interval = maxCount > 5 ? (maxCount / 5).ceil().toDouble() : 1.0;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final label = data[index].label;
                  if (label.isEmpty) return const SizedBox.shrink();

                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toInt().toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: (maxCount + 1).toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map(
                    (e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()),
                  )
                  .toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.5),
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: data.length < 15,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: colorScheme.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.primary.withValues(alpha: 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => colorScheme.surfaceContainerHigh,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final point = data[spot.spotIndex];
                  return LineTooltipItem(
                    '${point.count} issues\n${point.label}',
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StatBarTable extends StatelessWidget {
  const StatBarTable({super.key, required this.items, this.color});

  final List<MapEntry<String, int>> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;

    if (items.isEmpty) return const SizedBox.shrink();

    final maxCount = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: items.map((item) {
        final fraction = maxCount > 0 ? item.value / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  item.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 18,
                    child: Stack(
                      children: [
                        Container(color: barColor.withValues(alpha: 0.12)),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            color: barColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${item.value}',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PublisherDistributionChart extends StatelessWidget {
  const PublisherDistributionChart({super.key, required this.publishers});

  final List<MapEntry<String, int>> publishers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (publishers.isEmpty) return const SizedBox.shrink();

    final maxCount = publishers
        .map((e) => e.value)
        .fold(0, (prev, curr) => curr > prev ? curr : prev);

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount.toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.surfaceContainerHigh,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${publishers[groupIndex].key}\n${rod.toY.toInt()} issues',
                  TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= publishers.length) {
                    return const SizedBox.shrink();
                  }
                  final name = publishers[index].key;
                  // Shorten name if too long
                  final displayName = name.length > 10
                      ? '${name.substring(0, 8)}..'
                      : name;

                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: publishers.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: colorScheme.secondary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxCount.toDouble(),
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
