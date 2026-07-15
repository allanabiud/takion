import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/providers/providers.dart';

void showPerformanceMetrics(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Performance Metrics',
    actions: [
      IconButton(
        onPressed: () => ref.read(performanceMetricsProvider).clear(),
        icon: const Icon(Icons.refresh),
        tooltip: 'Reset Metrics',
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final metrics = ref.watch(performanceMetricsProvider);
        return ListenableBuilder(
          listenable: metrics,
          builder: (context, _) {
            final cacheHitRate = metrics.cacheHits.values.fold(
              0,
              (a, b) => a + b,
            );
            final cacheMissRate = metrics.cacheMisses.values.fold(
              0,
              (a, b) => a + b,
            );
            final totalCacheRequests = cacheHitRate + cacheMissRate;
            final cacheEfficiency = totalCacheRequests == 0
                ? 0.0
                : cacheHitRate / totalCacheRequests;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSettingsGroup(context, 'Network Health', [
                    buildSettingsRow(
                      'Total Requests',
                      '${metrics.totalApiRequests}',
                    ),
                    buildSettingsRow(
                      'Rate Limit Hits (429)',
                      '${metrics.http429Count}',
                      color: metrics.http429Count > 0 ? Colors.red : null,
                    ),
                    buildSettingsRow(
                      'Retries after 429',
                      '${metrics.retryAfter429Count}',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  buildSettingsGroup(context, 'Cache Efficiency', [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hit Rate'),
                            Text(
                              '${(cacheEfficiency * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: cacheEfficiency,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    buildSettingsRow('Total Hits', '$cacheHitRate'),
                    buildSettingsRow('Total Misses', '$cacheMissRate'),
                  ]),
                  const SizedBox(height: 16),
                  buildSettingsGroup(
                    context,
                    'Recent Network Activity',
                    metrics.recentApiRecords.isEmpty
                        ? [
                            const Text(
                              'No recent activity',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ]
                        : metrics.recentApiRecords
                              .map(
                                (record) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color:
                                              record.statusCode != null &&
                                                  record.statusCode! < 300
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              record.path,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${record.duration.inMilliseconds}ms • HTTP ${record.statusCode ?? '???'}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                  const SizedBox(height: 16),
                  buildSettingsGroup(
                    context,
                    'Provider Latency (Avg)',
                    metrics.providerCalls.isEmpty
                        ? [
                            const Text(
                              'No provider metrics',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ]
                        : metrics.providerCalls.entries.map((e) {
                            final avg =
                                (metrics.providerTotalMs[e.key] ?? 0) /
                                e.value;
                            return buildSettingsRow(
                              e.key,
                              '${avg.toStringAsFixed(0)}ms',
                            );
                          }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
