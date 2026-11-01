import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/network/rate_limit_interceptor.dart";
import "package:takion/src/core/performance/performance_metrics.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/settings/widgets/settings_helpers.dart";
import "package:takion/src/presentation/providers/providers.dart";

/// One-shot outbox queue health (count + oldest pending age) for the
/// diagnostics sheet.
final outboxTelemetryProvider =
    FutureProvider.autoDispose<OutboxQueueTelemetry>((ref) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.outboxDao.getQueueTelemetry();
    });

/// Number of durable sync jobs waiting to run.
final pendingSyncJobsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(driftDatabaseProvider).syncJobDao.watchPendingCount();
});

String _formatWait(Duration d) {
  if (d <= Duration.zero) return "now";
  if (d.inHours >= 1) return "${d.inHours}h ${d.inMinutes % 60}m";
  if (d.inMinutes >= 1) return "${d.inMinutes}m ${d.inSeconds % 60}s";
  return "${d.inSeconds}s";
}

void showPerformanceMetrics(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Performance & Diagnostics",
    actions: [
      IconButton(
        onPressed: () => _copyDiagnosticsReport(context, ref),
        icon: const Icon(Icons.copy),
        tooltip: "Copy Diagnostics Report",
      ),
      IconButton(
        onPressed: () => ref.read(performanceMetricsProvider).clear(),
        icon: const Icon(Icons.refresh),
        tooltip: "Reset Metrics",
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final metrics = ref.watch(performanceMetricsProvider);
        final rateState = ref.watch(
          rateLimitInterceptorProvider.select((i) => i.state),
        );
        final outboxTelemetry = ref.watch(outboxTelemetryProvider);
        final pendingJobs = ref.watch(pendingSyncJobsCountProvider);

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
            final cacheEfficiency = metrics.cacheHitRatio;
            final outcomes = metrics.cacheOutcomes;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRateQuotaGroup(context, rateState),
                  const SizedBox(height: 16),
                  buildSettingsGroup(context, "Network Health", [
                    buildSettingsRow(
                      "Total Requests",
                      "${metrics.totalApiRequests}",
                    ),
                    buildSettingsRow(
                      "Rate Limit Hits",
                      "${metrics.http429Count}",
                      color: metrics.http429Count > 0 ? Colors.red : null,
                    ),
                    buildSettingsRow(
                      "Retries after 429",
                      "${metrics.retryAfter429Count}",
                    ),
                    buildSettingsRow(
                      "Time Spent Throttled",
                      _formatWait(metrics.rateLimitThrottleDuration),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  buildSettingsGroup(context, "Cache Efficiency", [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Hit Rate (incl. 304)"),
                            Text(
                              "${(cacheEfficiency * 100).toStringAsFixed(1)}%",
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
                    buildSettingsRow(
                      "Cache Hits",
                      "${outcomes[CacheOutcome.cacheHit] ?? 0}",
                    ),
                    buildSettingsRow(
                      "304 Restored",
                      "${outcomes[CacheOutcome.validation304Restored] ?? 0}",
                    ),
                    buildSettingsRow(
                      "200 Fresh Fetches",
                      "${outcomes[CacheOutcome.network200Fresh] ?? 0}",
                    ),
                    buildSettingsRow(
                      "Cache Misses",
                      "${outcomes[CacheOutcome.cacheMiss] ?? 0}",
                    ),
                    buildSettingsRow("Tracked Hits", "$cacheHitRate"),
                    buildSettingsRow("Tracked Misses", "$cacheMissRate"),
                  ]),
                  const SizedBox(height: 16),
                  _buildSyncHealthGroup(
                    context,
                    outboxTelemetry: outboxTelemetry,
                    pendingJobs: pendingJobs,
                    conflictCount: metrics.conflictCount,
                  ),
                  const SizedBox(height: 16),
                  buildSettingsGroup(
                    context,
                    "Recent Network Activity",
                    metrics.recentApiRecords.isEmpty
                        ? [
                            const Text(
                              "No recent activity",
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
                    "Provider Latency",
                    metrics.providerCalls.isEmpty
                        ? [
                            const Text(
                              "No provider metrics",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ]
                        : metrics.providerCalls.entries.map((e) {
                            final avg =
                                (metrics.providerTotalMs[e.key] ?? 0) / e.value;
                            return buildSettingsRow(
                              e.key,
                              "${avg.toStringAsFixed(0)}ms",
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

Widget _buildRateQuotaGroup(BuildContext context, RateLimitState rateState) {
  final blockedUntil = rateState.blockedUntil;
  final now = DateTime.now().toUtc();
  final wait = blockedUntil?.difference(now);

  return buildSettingsGroup(context, "Metron Rate Quota", [
    buildSettingsRow(
      "Burst (per minute)",
      "${rateState.burstRemaining} / ${rateState.burstLimit}",
    ),
    buildSettingsRow(
      "Sustained (per day)",
      "${rateState.sustainedRemaining} / ${rateState.sustainedLimit}",
    ),
    if (blockedUntil != null)
      buildSettingsRow(
        "Rate Limited Until",
        "${blockedUntil.toLocal().toIso8601String().substring(11, 19)}"
            " (${_formatWait(wait ?? Duration.zero)})",
        color: Colors.red,
      )
    else
      buildSettingsRow("Status", "Unthrottled", color: Colors.green),
  ]);
}

Widget _buildSyncHealthGroup(
  BuildContext context, {
  required AsyncValue<OutboxQueueTelemetry> outboxTelemetry,
  required AsyncValue<int> pendingJobs,
  required int conflictCount,
}) {
  return buildSettingsGroup(context, "Sync Health", [
    outboxTelemetry.when(
      loading: () => buildSettingsRow("Outbox", "Loading…"),
      error: (e, _) => buildSettingsRow("Outbox", "Unavailable"),
      data: (telemetry) => Column(
        children: [
          buildSettingsRow(
            "Outbox Pending",
            "${telemetry.pendingCount}",
            color: telemetry.pendingCount > 0 ? Colors.orange : null,
          ),
          buildSettingsRow(
            "Oldest Pending",
            telemetry.pendingCount == 0
                ? "-"
                : _formatWait(telemetry.oldestAge),
          ),
        ],
      ),
    ),
    pendingJobs.when(
      loading: () => buildSettingsRow("Pending Sync Jobs", "Loading…"),
      error: (e, _) => buildSettingsRow("Pending Sync Jobs", "Unavailable"),
      data: (count) => buildSettingsRow(
        "Pending Sync Jobs",
        "$count",
        color: count > 0 ? Colors.orange : null,
      ),
    ),
    buildSettingsRow(
      "Conflicts Resolved",
      "$conflictCount",
      color: conflictCount > 0 ? Colors.orange : null,
    ),
  ]);
}

/// Copies a redacted JSON diagnostics report to the clipboard. The report
/// passes through [LogSanitizer.sanitize] so tokens, authorization headers,
/// and passwords never leave the device in clear text.
Future<void> _copyDiagnosticsReport(BuildContext context, WidgetRef ref) async {
  try {
    final metrics = ref.read(performanceMetricsProvider);
    final rateState = ref.read(rateLimitInterceptorProvider).state;
    final telemetry = await ref.read(outboxTelemetryProvider.future);

    final report = metrics.buildDiagnosticsReport(
      extra: {"rateLimit": rateState.toJson(), "outbox": telemetry.toJson()},
    );

    await Clipboard.setData(ClipboardData(text: report));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diagnostics report copied (sensitive data redacted)"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    AppLogger.error("Failed to copy diagnostics report", error: e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to build diagnostics report")),
      );
    }
  }
}
