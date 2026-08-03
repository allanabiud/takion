import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/logging/talker_setup.dart';
import 'package:talker/talker.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';

void showDeviceLogs(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Device Logs',
    child: _DeviceLogsBody(),
  );
}

class _DeviceLogsBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DeviceLogsBody> createState() => _DeviceLogsBodyState();
}

class _DeviceLogsBodyState extends ConsumerState<_DeviceLogsBody> {
  bool _previewExpanded = false;
  bool _sharing = false;
  bool _copying = false;

  List<String> get _logLines {
    final text = talker.history.text();
    if (text.isEmpty) return [];
    return text.split('\n');
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  Future<String> _buildLogContent(List<String> logLines) async {
    final info = await PackageInfo.fromPlatform();
    final historyLength = talker.history.length;
    final buffer = StringBuffer();
    buffer.writeln('Takion Debug Logs');
    buffer.writeln('=' * 50);
    buffer.writeln();
    buffer.writeln('App Version: ${info.version}+${info.buildNumber}');
    buffer.writeln('Package Name: ${info.packageName}');
    buffer.writeln(
      'Platform: ${Platform.operatingSystem} '
      '${Platform.operatingSystemVersion}',
    );
    buffer.writeln('Device: ${Platform.localHostname}');
    buffer.writeln('Generated: ${_formatTimestamp(DateTime.now())}');
    buffer.writeln('Log Entries: $historyLength');
    buffer.writeln();
    buffer.writeln('--- LOGS ---');
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
        if (mounted) TakionAlerts.info(context, 'No logs to share');
        return;
      }

      final content = await _buildLogContent(logLines);
      final dir = await getTemporaryDirectory();
      final fileName =
          'takion_logs_${DateTime.now().millisecondsSinceEpoch}.log';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Takion Debug Logs',
          text: 'Takion Debug Logs',
        ),
      );
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: 'Failed to share logs');
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
        if (mounted) TakionAlerts.info(context, 'No logs to copy');
        return;
      }

      await Clipboard.setData(ClipboardData(text: logLines.join('\n')));
      if (mounted) TakionAlerts.success(context, 'Logs copied to clipboard');
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = talker.history;
    final historyLength = history.length;
    final logLines = _logLines;

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
          buildSettingsGroup(context, 'Overview', [
            _statRow(context, 'Total Entries', '$historyLength'),
            if (isCapped)
              _statRow(context, 'Retention', 'Capped at $maxHistory'),
            if (oldest != null)
              _statRow(
                context,
                'Oldest',
                DateFormatter.relativeDetailed(oldest),
              ),
            if (newest != null)
              _statRow(
                context,
                'Newest',
                DateFormatter.relativeDetailed(newest),
              ),
          ]),
          const SizedBox(height: 16),
          buildSettingsGroup(context, 'Actions', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                'Share Log File',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _sharing ? 'Preparing...' : 'Share as .log file',
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
                'Copy Logs to Clipboard',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _copying ? 'Copying...' : 'Copy all log entries',
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
          if (logLines.isNotEmpty) ...[
            const SizedBox(height: 16),
            buildSettingsGroup(context, 'Recent Logs', [
              InkWell(
                onTap: () =>
                    setState(() => _previewExpanded = !_previewExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _previewExpanded ? 'Hide preview' : 'Show preview',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _previewExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_previewExpanded)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      logLines
                          .sublist(
                            0,
                            logLines.length > 50 ? 50 : logLines.length,
                          )
                          .join('\n'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
            ]),
          ],
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
}
