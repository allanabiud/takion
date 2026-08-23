import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/logging/talker_setup.dart";
import "package:takion/src/core/sync/sync_diagnostics.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:talker/talker.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";
import "package:takion/src/presentation/features/settings/widgets/settings_helpers.dart";

void showDeviceLogs(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Device Logs",
    child: _DeviceLogsBody(),
  );
}

class _DeviceLogsBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DeviceLogsBody> createState() => _DeviceLogsBodyState();
}

class _DeviceLogsBodyState extends ConsumerState<_DeviceLogsBody> {
  bool _previewExpanded = false;
  bool _syncPreviewExpanded = false;
  bool _sharing = false;
  bool _copying = false;

  List<String> get _logLines {
    final text = talker.history.text();
    if (text.isEmpty) return [];
    return text.split("\n");
  }

  String _pad(int n) => n.toString().padLeft(2, "0");

  String _formatTimestamp(DateTime dt) {
    return "${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} "
        "${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}";
  }

  Future<String> _buildLogContent(List<String> logLines) async {
    final info = await PackageInfo.fromPlatform();
    final historyLength = talker.history.length;
    final buffer = StringBuffer();
    buffer.writeln("Takion Debug Logs");
    buffer.writeln("=" * 50);
    buffer.writeln();
    buffer.writeln("App Version: ${info.version}+${info.buildNumber}");
    buffer.writeln("Package Name: ${info.packageName}");
    buffer.writeln(
      "Platform: ${Platform.operatingSystem} "
      "${Platform.operatingSystemVersion}",
    );
    buffer.writeln("Device: ${Platform.localHostname}");
    buffer.writeln("Generated: ${_formatTimestamp(DateTime.now())}");
    buffer.writeln("Log Entries: $historyLength");
    buffer.writeln();

    final diagnostics = ref.read(syncDiagnosticsProvider).value;
    if (diagnostics != null) {
      buffer.writeln("--- DRIVE SYNC ---");
      buffer.writeln(
        "Last success: "
        '${diagnostics.lastSuccessTime == null ? 'never' : _formatTimestamp(diagnostics.lastSuccessTime!)}',
      );
      if (diagnostics.lastErrorTime != null) {
        buffer.writeln(
          "Last failure (${_formatTimestamp(diagnostics.lastErrorTime!)})"
          '${diagnostics.lastPhase != null ? ' during ${diagnostics.lastPhase}' : ''}: '
          '${diagnostics.lastError ?? 'unknown'}'
          '${diagnostics.lastErrorDetail != null ? ' (${diagnostics.lastErrorDetail})' : ''}',
        );
      } else {
        buffer.writeln("Last failure: none");
      }
      buffer.writeln("Recent attempts:");
      for (final entry in diagnostics.recentAttempts.take(20)) {
        final elapsed = entry.elapsedMs == null
            ? ""
            : " [${entry.elapsedMs!}ms]";
        buffer.writeln(
          "  ${_formatTimestamp(entry.time)} "
          '${entry.phase} ${entry.success ? 'OK' : 'FAILED'}'
          '${entry.success ? '' : ' ${entry.error ?? ''}'}$elapsed',
        );
      }
      buffer.writeln();
    }

    buffer.writeln("--- LOGS ---");
    for (final line in logLines) {
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  Future<void> _shareLogs() async {
    setState(() => _sharing = true);
    try {
      final logLines = _logLines;
      if (logLines.isEmpty) {
        if (mounted) TakionAlerts.info(context, "No logs to share");
        return;
      }

      final content = await _buildLogContent(logLines);
      final dir = await getTemporaryDirectory();
      final fileName =
          "takion_logs_${DateTime.now().millisecondsSinceEpoch}.log";
      final file = File("${dir.path}/$fileName");
      await file.writeAsString(content);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: "Takion Debug Logs",
          text: "Takion Debug Logs",
        ),
      );
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: "Failed to share logs");
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _copyLogs() async {
    setState(() => _copying = true);
    try {
      final logLines = _logLines;
      if (logLines.isEmpty) {
        if (mounted) TakionAlerts.info(context, "No logs to copy");
        return;
      }

      await Clipboard.setData(ClipboardData(text: logLines.join("\n")));
      if (mounted) TakionAlerts.success(context, "Logs copied to clipboard");
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = talker.history;
    final historyLength = history.length;

    DateTime? oldest;
    DateTime? newest;
    if (history.isNotEmpty) {
      oldest = history.first.time;
      newest = history.last.time;
    }

    final theme = Theme.of(context);
    final maxHistory = talker.settings.maxHistoryItems;
    final isCapped = historyLength >= maxHistory;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSettingsGroup(context, "Overview", [
            _statRow(context, "Total Entries", "$historyLength"),
            if (isCapped)
              _statRow(context, "Retention", "Capped at $maxHistory"),
            if (oldest != null)
              _statRow(
                context,
                "Oldest",
                DateFormatter.relativeDetailed(oldest),
              ),
            if (newest != null)
              _statRow(
                context,
                "Newest",
                DateFormatter.relativeDetailed(newest),
              ),
          ]),
          const SizedBox(height: 16),
          buildSettingsGroup(context, "Actions", [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                "Share Log File",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _sharing ? "Preparing..." : "Share as .log file",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: _sharing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              onTap: _sharing ? null : _shareLogs,
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.copy_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                "Copy Logs to Clipboard",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _copying ? "Copying..." : "Copy all log entries",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: _copying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              onTap: _copying ? null : _copyLogs,
            ),
          ]),
          const SizedBox(height: 16),
          _buildRecentLogsSection(context),
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsSection(BuildContext context) {
    final theme = Theme.of(context);
    final logLines = _logLines;
    final diagnosticsAsync = ref.watch(syncDiagnosticsProvider);
    final diagnostics = diagnosticsAsync.value;

    return buildSettingsGroup(context, "Recent Logs", [
      if (diagnostics != null && diagnostics.lastErrorTime != null) ...[
        _statRow(
          context,
          "Last Failure",
          DateFormatter.relativeDetailed(diagnostics.lastErrorTime!),
        ),
        if (diagnostics.lastPhase != null)
          _statRow(context, "Failed During", diagnostics.lastPhase!),
        if (diagnostics.lastError != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(
              diagnostics.lastError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (diagnostics.lastErrorDetail != null &&
            diagnostics.lastErrorDetail != diagnostics.lastError)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              diagnostics.lastErrorDetail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const Divider(height: 16),
      ],
      _buildPreviewToggle(
        context,
        expanded: _syncPreviewExpanded,
        showLabel: "Show sync preview",
        hideLabel: "Hide sync preview",
        onTap: () =>
            setState(() => _syncPreviewExpanded = !_syncPreviewExpanded),
      ),
      if (_syncPreviewExpanded) ...[
        const SizedBox(height: 4),
        _buildSyncPreview(context, diagnosticsAsync),
      ],
      if (logLines.isNotEmpty) ...[
        const Divider(height: 1),
        _buildPreviewToggle(
          context,
          expanded: _previewExpanded,
          showLabel: "Show preview",
          hideLabel: "Hide preview",
          onTap: () => setState(() => _previewExpanded = !_previewExpanded),
        ),
        if (_previewExpanded) ...[
          const SizedBox(height: 4),
          _buildPreviewBody(
            context,
            logLines
                .sublist(0, logLines.length > 50 ? 50 : logLines.length)
                .join("\n"),
          ),
        ],
      ],
    ]);
  }

  Widget _buildPreviewToggle(
    BuildContext context, {
    required bool expanded,
    required String showLabel,
    required String hideLabel,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              expanded ? hideLabel : showLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBody(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: "monospace",
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSyncPreview(
    BuildContext context,
    AsyncValue<SyncDiagnostics> diagnosticsAsync,
  ) {
    final theme = Theme.of(context);
    switch (diagnosticsAsync) {
      case AsyncValue(:final value?):
        final attempts = value.recentAttempts;
        if (attempts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "No sync attempts recorded yet.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return _buildPreviewBody(
          context,
          attempts
              .map((entry) {
                final elapsed = entry.elapsedMs == null
                    ? ""
                    : " [${entry.elapsedMs!}ms]";
                return "${_formatTimestamp(entry.time)} ${entry.phase} "
                    '${entry.success ? 'OK' : 'FAILED'}'
                    '${entry.success ? '' : ' ${entry.error ?? ''}'}$elapsed';
              })
              .join("\n"),
        );
      case AsyncValue(:final error?):
        return Text(
          "Failed to load sync logs: $error",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
      default:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
    }
  }
}
