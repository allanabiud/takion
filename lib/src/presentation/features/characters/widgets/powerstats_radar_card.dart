import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class PowerStatsRadarCard extends StatelessWidget {
  const PowerStatsRadarCard({super.key, required this.powerstats});

  final SuperHeroPowerStats powerstats;

  static const _labels = [
    "Intelligence",
    "Strength",
    "Speed",
    "Durability",
    "Power",
    "Combat",
  ];

  Color _getStatColor(int value, ThemeData theme) {
    if (value < 40) {
      return theme.colorScheme.error;
    } else if (value < 70) {
      return theme.brightness == Brightness.dark
          ? Colors.amber.shade400
          : Colors.amber.shade800;
    } else {
      return theme.brightness == Brightness.dark
          ? Colors.greenAccent.shade400
          : Colors.green.shade700;
    }
  }

  double _getLabelOffset(int index) {
    if (index == 0 || index == 3) {
      return 0.08;
    }
    return 0.25;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final values = <double>[
      (powerstats.intelligence ?? 0).toDouble(),
      (powerstats.strength ?? 0).toDouble(),
      (powerstats.speed ?? 0).toDouble(),
      (powerstats.durability ?? 0).toDouble(),
      (powerstats.power ?? 0).toDouble(),
      (powerstats.combat ?? 0).toDouble(),
    ];

    final total = values.fold<double>(0, (sum, v) => sum + v).toInt();
    final avg = (total / (values.isEmpty ? 1 : values.length)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "POWERSTATS"),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 270,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: const [
                      RadarEntry(value: 0),
                      RadarEntry(value: 100),
                      RadarEntry(value: 0),
                      RadarEntry(value: 100),
                      RadarEntry(value: 0),
                      RadarEntry(value: 100),
                    ],
                    fillColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    entryRadius: 0,
                  ),
                  RadarDataSet(
                    dataEntries: [
                      for (final value in values) RadarEntry(value: value),
                    ],
                    fillColor: theme.colorScheme.primary.withValues(
                      alpha: 0.25,
                    ),
                    borderColor: theme.colorScheme.primary,
                    borderWidth: 2.5,
                    entryRadius: 4,
                  ),
                ],
                radarShape: RadarShape.polygon,
                radarBackgroundColor: Colors.transparent,
                radarBorderData: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                gridBorderData: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                  width: 1,
                ),
                tickCount: 5,
                isMinValueAtCenter: true,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 0,
                ),
                getTitle: (index, angle) {
                  final label = _labels[index];
                  final valInt = values[index].toInt();
                  final valColor = _getStatColor(valInt, theme);

                  return RadarChartTitle(
                    text: "$label: ",
                    children: [
                      TextSpan(
                        text: "$valInt",
                        style: TextStyle(
                          color: valColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    positionPercentageOffset: _getLabelOffset(index),
                  );
                },
                titleTextStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                radarTouchData: RadarTouchData(enabled: false),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatColor(avg, theme).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatColor(avg, theme).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Average Power Level: ",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "$avg / 100",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getStatColor(avg, theme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            Text(
              "via SuperHero API",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
